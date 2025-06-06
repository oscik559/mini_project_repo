# === LangGraph Voice Processor Subgraph ===
# This file contains a fully self-contained LangGraph voice-processing module.
# It includes audio recording, transcription (via Whisper), database logging,
# and session-aware state transitions.

import json
import logging
import os
import tempfile
import time
import uuid
from pathlib import Path
from typing import Any, Dict, Optional

import numpy as np
import psycopg2
import pyttsx3
import sounddevice as sd
import webrtcvad
from mini_project.config.app_config import (
    MAX_TRANSCRIPTION_RETRIES,
    MIN_DURATION_SEC,
    NOISE_CACHE_PATH,
    VOICE_PROCESSING_CONFIG,
    VOICE_TTS_SETTINGS,
)

# NOISE_CACHE_PATH = Path(tempfile.gettempdir()) / "noise_floor_cache.json"
from mini_project.config.constants import WHISPER_LANGUAGE_NAMES
from faster_whisper import WhisperModel
from gtts import gTTS
from langgraph.graph import StateGraph
from playsound import playsound
from scipy.io.wavfile import write

from mini_project.database.connection import get_connection

logger = logging.getLogger("LangGraphVoice")


# === Components ===
class SpeechSynthesizer:
    """
    Handles text-to-speech (TTS) using gTTS or pyttsx3.
    Includes fallback printing if TTS fails.
    """

    def __init__(self):
        self.use_gtts = VOICE_TTS_SETTINGS["use_gtts"]
        self.voice_speed = VOICE_TTS_SETTINGS["speed"]
        self.ping_path = Path(VOICE_TTS_SETTINGS["ping_sound_path"]).resolve()
        self.ding_path = Path(VOICE_TTS_SETTINGS["ding_sound_path"]).resolve()
        self.voice_index = VOICE_TTS_SETTINGS.get("voice_index", 1)
        if not self.use_gtts:
            self.engine = pyttsx3.init()
            voices = self.engine.getProperty("voices")
            self.engine.setProperty("rate", self.voice_speed)
            self.engine.setProperty("voice", voices[self.voice_index].id)

    def speak(self, text: str):
        """Speak the given text using TTS, with fallback if TTS fails."""

        fallback_used = False

        if self.use_gtts:
            try:
                temp_path = (
                    Path(tempfile.gettempdir()) / f"speech_{uuid.uuid4().hex}.mp3"
                )
                gTTS(text=text).save(temp_path)
                playsound(str(temp_path))
                os.remove(temp_path)
            except Exception as e:
                logger.warning(f"[TTS:gTTS] Error: {e}")
                fallback_used = True
        else:
            try:
                self.engine.say(text)
                self.engine.runAndWait()
            except Exception as e:
                logger.warning(f"[TTS:pyttsx3] Error: {e}")
                fallback_used = True

        if fallback_used:
            logger.info(
                f"[TTS-Fallback] Speaking failed. Text output instead:\n🗣️ {text}"
            )
            print(f"🗣️ {text}")

    def play_ding(self):
        try:
            playsound(str(self.ding_path))
        except Exception as e:
            logger.warning(f"[Ding] Failed to play: {e}")


class AudioRecorder:
    """
    Captures voice input using sounddevice and VAD.
    Includes RMS-based noise floor calibration and silence detection.
    """

    def __init__(self):
        self.calibrated = False
        self.config = VOICE_PROCESSING_CONFIG["recording"]
        self.temp_audio_path = self.config["temp_audio_path"]
        self.sampling_rate = self.config["sampling_rate"]
        self.vad = webrtcvad.Vad(3)
        self.noise_floor = None
        self.speech_detected = False
        self.synth = SpeechSynthesizer()

    def calibrate_noise(self):
        if NOISE_CACHE_PATH.exists():
            try:
                with open(NOISE_CACHE_PATH, "r") as f:
                    cached = json.load(f)
                noise = cached.get("noise_floor")
                ts = cached.get("timestamp")
                if (
                    noise and ts and (time.time() - ts < 1 * 3600)
                ):  # valid if < 6 hours old
                    logger.info(f"🔁 Using cached noise floor from cache: {noise:.2f}")
                    self.calibrated = True
                    return noise
                else:
                    logger.info("🕒 Cached noise floor is too old. Recalibrating...")
            except Exception as e:
                logger.warning(f"[Cache] Failed to load noise cache: {e}")

        logger.info("✅ Calibrating ambient noise...")
        noise_rms = []
        with sd.InputStream(
            samplerate=self.sampling_rate, channels=1, dtype="int16"
        ) as stream:
            for _ in range(5):
                frame, _ = stream.read(
                    int(self.sampling_rate * self.config["frame_duration"])
                )
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                noise_rms.append(rms)

        noise_floor = float(np.mean(noise_rms))
        logger.info(f"✅ Noise floor calculated: {noise_floor:.2f}")
        self.calibrated = True

        try:
            if not NOISE_CACHE_PATH.parent.exists():
                NOISE_CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
            with open(NOISE_CACHE_PATH, "w") as f:
                json.dump({"noise_floor": noise_floor, "timestamp": time.time()}, f)
        except Exception as e:
            logger.warning(f"[Cache] Failed to save noise cache: {e}")

        return noise_floor

    def record_audio(self, speak_prompt: bool = False):
        """Records a single utterance and returns (file_path, speech_detected)."""

        self.noise_floor = self.calibrate_noise()
        threshold = self.noise_floor + self.config["amplitude_margin"]
        if speak_prompt:
            try:
                self.synth.speak("Tell me, how can I help you?")
            except Exception as e:
                logger.warning(f"[Recorder] Failed to speak prompt: {e}")
        self.synth.play_ding()
        logger.info(f"📢 Speak now... (threshold: {threshold:.2f})")

        audio = []
        stream = sd.InputStream(
            samplerate=self.sampling_rate, channels=1, dtype="int16"
        )
        with stream:
            start = time.time()
            silence_start = None
            while True:
                frame, _ = stream.read(
                    int(self.sampling_rate * self.config["frame_duration"])
                )
                audio.append(frame)
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                speech = (
                    self.vad.is_speech(frame.tobytes(), self.sampling_rate)
                    and rms > threshold
                )
                if speech:
                    self.speech_detected = True
                    silence_start = None
                elif silence_start is None:
                    silence_start = time.time()
                elif time.time() - silence_start > (
                    self.config["post_speech_silence_duration"]
                    if self.speech_detected
                    else self.config["initial_silence_duration"]
                ):
                    break
                if time.time() - start > self.config["max_duration"]:
                    break
        duration = time.time() - start
        logger.info(f"🎙️ Total recording duration: {duration:.2f} seconds")

        audio = np.concatenate(audio)
        write(self.temp_audio_path, self.sampling_rate, audio)
        return self.temp_audio_path, self.speech_detected


class Transcriber:
    """
    Uses Whisper (via FasterWhisper) to transcribe audio to text.
    Supports automatic translation to English.
    """

    def __init__(self):
        cfg = VOICE_PROCESSING_CONFIG["whisper"]
        self.model = WhisperModel(
            cfg["model"], device=cfg["device"], compute_type=cfg["compute_type"]
        )

    def transcribe_audio(self, path):
        """Transcribes an audio file and returns (text, detected_language)."""

        segments, info = self.model.transcribe(path, beam_size=5)
        logger.info(
            f"📡 Detected language: {info.language}, confidence: {info.language_probability:.2f}"
        )
        if info.language_probability < 0.3:
            logger.warning(
                f"🔴 Low language detection confidence: {info.language_probability:.2f}"
            )
            raise ValueError("Unclear speech or unsupported language.")

        if info.language != "en":
            segments, _ = self.model.transcribe(path, task="translate", beam_size=5)
        text = " ".join([s.text for s in segments])
        if not text.strip():
            raise ValueError("No intelligible speech detected.")
        return text.strip(), WHISPER_LANGUAGE_NAMES.get(info.language, info.language)


class Storage:
    """
    Stores transcribed text and metadata into the PostgreSQL voice_instructions table.
    """

    def store_instruction(
        self,
        session_id,
        detected_language,
        transcribed_text,
        retries: int = 3,
        delay: float = 1.0,
    ):
        for attempt in range(retries):
            try:
                with get_connection() as conn:
                    with conn.cursor() as cursor:
                        cursor.execute(
                            """
                            INSERT INTO voice_instructions (session_id, transcribed_text, language)
                            VALUES (%s, %s, %s)
                            """,
                            (session_id, transcribed_text, detected_language),
                        )
                logger.info("✅ Stored voice instruction in DB")
                return
            except psycopg2.OperationalError as e:
                if "could not connect" in str(e).lower() and attempt < retries - 1:
                    logger.warning(
                        f"Database connection error. Retrying in {delay} seconds..."
                    )
                    time.sleep(delay)
                else:
                    logger.error(f"[PostgreSQL] Operational error: {e}")
                    raise
            except Exception as e:
                logger.error(f"[PostgreSQL] Unexpected error: {e}")
                raise


# === LangGraph Nodes ===
recorder = AudioRecorder()
transcriber = Transcriber()
storage = Storage()


def record_audio_node(state: Dict[str, Any]):
    """LangGraph node: records audio and updates state with file path + speech flag."""

    start_time = time.time()
    path, speech = recorder.record_audio()
    state["temp_audio_path"] = path
    state["speech_detected"] = speech
    duration = time.time() - start_time
    if duration < MIN_DURATION_SEC:
        logger.warning(f"Recording too short ({duration:.2f}s). Treating as no speech.")
        state["speech_detected"] = False
        try:
            os.remove(state["temp_audio_path"])
            logger.info(f"🗑️ Deleted short audio file: {state['temp_audio_path']}")
        except Exception as e:
            logger.warning(f"Could not delete short audio file: {e}")

    return state


def transcribe_audio_node(state):
    """LangGraph node: transcribes audio if speech was detected, updates state with text."""

    if not state.get("speech_detected"):
        try:
            os.remove(state.get("temp_audio_path", ""))
            logger.info("🗑️ Temp file deleted due to no speech.")
        except Exception as e:
            logger.warning(f"Temp file deletion failed: {e}")
        return state

    path = state["temp_audio_path"]
    for attempt in range(MAX_TRANSCRIPTION_RETRIES):
        try:
            text, lang = transcriber.transcribe_audio(path)
            state["transcribed_text"] = text
            state["lang"] = lang
            return state
        except Exception as e:
            logger.warning(f"Attempt {attempt+1}: {e}")
            time.sleep(1)
    return state


def store_voice_log_node(state):
    """LangGraph node: stores transcription to database if available."""

    if state.get("transcribed_text") and state.get("lang"):
        session_id = state.get("session_id") or str(uuid.uuid4())
        state["session_id"] = session_id
        try:
            storage.store_instruction(
                session_id, state["lang"], state["transcribed_text"]
            )
        except Exception as e:
            logger.error(f"Failed to store voice log: {e}")
    return state


def return_voice_state_node(state):
    """LangGraph node: final return step — logs pipeline completion."""

    logger.info("✅ Finished voice input pipeline.")
    return state


# === LangGraph VP Subgraph ===
def get_voice_subgraph():
    """
    Builds and returns the LangGraph voice input subgraph.

    Returns:
        A compiled StateGraph that records, transcribes, stores, and returns voice input.
    """

    from typing import TypedDict

    class VoiceState(TypedDict, total=False):
        temp_audio_path: str
        speech_detected: bool
        transcribed_text: str
        lang: str
        session_id: str

    sg = StateGraph(state_schema=VoiceState)

    sg.add_node("record", record_audio_node)
    sg.add_node("transcribe", transcribe_audio_node)
    sg.add_node("store", store_voice_log_node)
    sg.add_node("return", return_voice_state_node)

    sg.set_entry_point("record")
    sg.add_edge("record", "transcribe")
    sg.add_edge("transcribe", "store")
    sg.add_edge("store", "return")
    sg.set_finish_point("return")

    return sg.compile()


if __name__ == "__main__":
    try:
        subgraph = get_voice_subgraph()
        print(subgraph.get_graph().draw_mermaid())

        result = subgraph.invoke({})  # Optional: pass session_id here
        print("\n🎤 Final state from voice subgraph:")
        for key, value in result.items():
            print(f"  {key}: {value}")

    except KeyboardInterrupt:
        print("\n🛑 Voice input interrupted by user. Exiting gracefully.")

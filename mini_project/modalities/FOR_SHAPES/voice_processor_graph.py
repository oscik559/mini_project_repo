# === LangGraph Voice Processor Subgraph ===
# This file contains a fully self-contained LangGraph voice-processing module.
# It includes audio recording, transcription (via Whisper), database logging,
# and session-aware state transitions.

import os
import time
import uuid
import logging
from typing import Optional, Dict, Any

import numpy as np
import sounddevice as sd
import webrtcvad
from scipy.io.wavfile import write
from faster_whisper import WhisperModel
import psycopg2
import pyttsx3
from gtts import gTTS
from playsound import playsound
from pathlib import Path
import tempfile

from langgraph.graph import StateGraph
from config.app_config import MAX_TRANSCRIPTION_RETRIES, MIN_DURATION_SEC, VOICE_PROCESSING_CONFIG, VOICE_TTS_SETTINGS
from config.constants import WHISPER_LANGUAGE_NAMES
from mini_project.database.connection import get_connection

logger = logging.getLogger("LangGraphVoice")

# === Components ===
class SpeechSynthesizer:
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
        if self.use_gtts:
            try:
                temp_path = Path(tempfile.gettempdir()) / f"speech_{uuid.uuid4().hex}.mp3"
                gTTS(text=text).save(temp_path)
                playsound(str(temp_path))
                os.remove(temp_path)
            except Exception as e:
                logger.error(f"[gTTS] Error: {e}")
        else:
            try:
                self.engine.say(text)
                self.engine.runAndWait()
            except Exception as e:
                logger.error(f"[pyttsx3] Error: {e}")

    def play_ding(self):
        try:
            playsound(str(self.ding_path))
        except Exception as e:
            logger.warning(f"[Ding] Failed to play: {e}")


class AudioRecorder:
    def __init__(self):
        self.config = VOICE_PROCESSING_CONFIG["recording"]
        self.temp_audio_path = self.config["temp_audio_path"]
        self.sampling_rate = self.config["sampling_rate"]
        self.vad = webrtcvad.Vad(3)
        self.noise_floor = None
        self.speech_detected = False
        self.synth = SpeechSynthesizer()

    def calibrate_noise(self):
        logger.info("✅ Calibrating ambient noise...")
        noise_rms = []
        with sd.InputStream(samplerate=self.sampling_rate, channels=1, dtype="int16") as stream:
            end_time = time.time() + self.config["calibration_duration"]
            while time.time() < end_time:
                frame, _ = stream.read(int(self.sampling_rate * self.config["frame_duration"]))
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                noise_rms.append(rms)
        return np.mean(noise_rms)

    def record_audio(self):
        self.noise_floor = self.calibrate_noise()
        threshold = self.noise_floor + self.config["amplitude_margin"]
        self.synth.play_ding()
        logger.info(f"📢 Speak now... (threshold: {threshold:.2f})")

        audio = []
        stream = sd.InputStream(samplerate=self.sampling_rate, channels=1, dtype="int16")
        with stream:
            start = time.time()
            silence_start = None
            while True:
                frame, _ = stream.read(int(self.sampling_rate * self.config["frame_duration"]))
                audio.append(frame)
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                speech = self.vad.is_speech(frame.tobytes(), self.sampling_rate) and rms > threshold
                if speech:
                    self.speech_detected = True
                    silence_start = None
                elif silence_start is None:
                    silence_start = time.time()
                elif time.time() - silence_start > (self.config["post_speech_silence_duration"] if self.speech_detected else self.config["initial_silence_duration"]):
                    break
                if time.time() - start > self.config["max_duration"]:
                    break
        audio = np.concatenate(audio)
        write(self.temp_audio_path, self.sampling_rate, audio)
        return self.temp_audio_path, self.speech_detected


class Transcriber:
    def __init__(self):
        cfg = VOICE_PROCESSING_CONFIG["whisper"]
        self.model = WhisperModel(cfg["model"], device=cfg["device"], compute_type=cfg["compute_type"])

    def transcribe_audio(self, path):
        segments, info = self.model.transcribe(path, beam_size=5)
        if info.language_probability < 0.3:
            raise ValueError("Unclear speech or unsupported language.")
        if info.language != "en":
            segments, _ = self.model.transcribe(path, task="translate", beam_size=5)
        text = " ".join([s.text for s in segments])
        if not text.strip():
            raise ValueError("No intelligible speech detected.")
        return text.strip(), WHISPER_LANGUAGE_NAMES.get(info.language, info.language)


class Storage:
    def store_instruction(self, session_id, detected_language, transcribed_text):
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




# === LangGraph Nodes ===
recorder = AudioRecorder()
transcriber = Transcriber()
storage = Storage()


def record_audio_node(state: Dict[str, Any]):
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
    if state.get("transcribed_text") and state.get("lang"):
        session_id = state.get("session_id") or str(uuid.uuid4())
        state["session_id"] = session_id
        try:
            storage.store_instruction(session_id, state["lang"], state["transcribed_text"])
        except Exception as e:
            logger.error(f"Failed to store voice log: {e}")
    return state

def return_voice_state_node(state):
    logger.info("✅ Finished voice input pipeline.")
    return state


# === LangGraph VP Subgraph ===
def get_voice_subgraph():
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
    subgraph = get_voice_subgraph()
    result = subgraph.invoke({})  # Empty initial state
    print("\n🎤 Final state from voice subgraph:")
    for key, value in result.items():
        print(f"  {key}: {value}")
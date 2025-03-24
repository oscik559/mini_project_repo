# modalities/voice_processor.py

import logging
import os

# import sqlite3
import tempfile
import time
import uuid
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import numpy as np
from pluggy import Result
import pyttsx3
import sounddevice as sd
import webrtcvad
from faster_whisper import WhisperModel
from config.constants import WHISPER_LANGUAGE_NAMES

from gtts import gTTS
from playsound import playsound
from scipy.io.wavfile import write

from config.app_config import (
    VOICE_PROCESSING_CONFIG,
    VOICE_TTS_SETTINGS,
    MAX_TRANSCRIPTION_RETRIES,
    setup_logging,
    logger,
)
from mini_project.database.connection import get_connection
import psycopg2

logging.getLogger("comtypes").setLevel(logging.WARNING)
logger = logging.getLogger("VoiceProcessor")

min_duration_sec = 1.5  # Minimum duration for a valid recording


class SpeechSynthesizer:
    _instance = None  # Singleton instance

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SpeechSynthesizer, cls).__new__(cls)
            cls._instance._init_engine()
        return cls._instance

    def _init_engine(self):
        self.use_gtts = VOICE_TTS_SETTINGS["use_gtts"]
        self.voice_speed = VOICE_TTS_SETTINGS["speed"]
        self.ping_path = Path(VOICE_TTS_SETTINGS["ping_sound_path"]).resolve()
        self.ding_path = Path(VOICE_TTS_SETTINGS["ding_sound_path"]).resolve()
        self.voice_index = VOICE_TTS_SETTINGS.get("voice_index", 1)

        if not self.use_gtts:
            try:
                self.engine = pyttsx3.init()
                voices = self.engine.getProperty("voices")
                self.engine.setProperty("rate", self.voice_speed)
                self.engine.setProperty("voice", voices[self.voice_index].id)
            except Exception as e:
                logger.error(f"[TTS] Error initializing pyttsx3: {e}")

    def play_ping(self):
        try:
            if not self.ping_path.exists():
                raise FileNotFoundError(f"Ping sound file not found: {self.ping_path}")
            playsound(str(self.ping_path))
        except Exception as e:
            logger.warning(f"[Ping Sound] Failed to play: {e}")

    def play_ding(self):
        try:
            if not self.ding_path.exists():
                raise FileNotFoundError(f"Ding sound file not found: {self.ding_path}")
            playsound(str(self.ding_path))
        except Exception as e:
            logger.warning(f"[Ding Sound] Failed to play: {e}")

    def speak(self, text: str):
        if self.use_gtts:
            try:
                temp_path = (
                    Path(tempfile.gettempdir()) / f"speech_{uuid.uuid4().hex}.mp3"
                )
                gTTS(text=text).save(temp_path)
                playsound(str(temp_path))
                os.remove(temp_path)
            except Exception as e:
                logger.error(f"[TTS:gTTS] Error: {e}")
                print(f"[TTS Fallback] {text}")
        else:
            try:
                self.engine.say(text)
                self.engine.runAndWait()
            except Exception as e:
                logger.error(f"[TTS:pyttsx3] Error during speech: {e}")
                print(f"[TTS Fallback] {text}")


class AudioRecorder:

    def __init__(self, synthesizer: Optional[SpeechSynthesizer] = None) -> None:
        self.synthesizer = synthesizer or SpeechSynthesizer()
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["recording"]
        self.temp_audio_path: str = self.config["temp_audio_path"]
        self.sampling_rate: int = self.config["sampling_rate"]
        self.vad = webrtcvad.Vad()
        self.vad.set_mode(3)
        self.speech_detected = False

        if not isinstance(self.sampling_rate, int) or self.sampling_rate <= 0:
            raise ValueError("Sampling rate must be a positive integer.")
        if not isinstance(self.temp_audio_path, str):
            raise ValueError("Temp audio path must be a string.")

    def calibrate_noise(self) -> float:
        logger.info("🔈 Calibrating ambient noise...")
        noise_rms_values: list[float] = []
        stream = sd.InputStream(
            samplerate=self.sampling_rate, channels=1, dtype="int16"
        )
        end_time = time.time() + self.config["calibration_duration"]
        with stream:
            while time.time() < end_time:
                frame, _ = stream.read(
                    int(self.sampling_rate * self.config["frame_duration"])
                )
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                noise_rms_values.append(rms)
        noise_floor = np.mean(noise_rms_values)
        logger.info(
            f"✅ Ambient noise calibration complete. Noise floor: {noise_floor:.2f}"
        )
        return noise_floor

    def record_audio(self) -> None:
        noise_floor = self.calibrate_noise()
        amplitude_threshold = noise_floor + self.config["amplitude_margin"]
        logger.info(
            f"🎚️ Amplitude threshold set to: {amplitude_threshold:.2f} (Noise floor: {noise_floor:.2f} + Margin: {self.config['amplitude_margin']})"
        )

        # 🗣️ Speak the instruction aloud
        try:
            self.synthesizer.speak("Please speak now.")
        except Exception as e:
            logger.warning(f"[Recorder] Failed to speak instruction: {e}")

        logger.info("🗣️ Voice recording: Please speak now...")

        # 🔔 Play ding sound immediately after prompt
        try:
            self.synthesizer.play_ding()
        except Exception as e:
            logger.warning(f"[Recorder] Failed to play ding: {e}")

        audio = []
        start_time = time.time()
        silence_start: Optional[float] = None
        self.speech_detected = False

        stream = sd.InputStream(
            samplerate=self.sampling_rate, channels=1, dtype="int16"
        )
        with stream:
            while True:
                frame, _ = stream.read(
                    int(self.sampling_rate * self.config["frame_duration"])
                )
                audio.append(frame)
                is_speech_vad = self.vad.is_speech(frame.tobytes(), self.sampling_rate)
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                is_speech_amplitude = rms > amplitude_threshold
                logger.debug(
                    f"VAD: {is_speech_vad}, RMS: {rms:.2f}, Amplitude: {is_speech_amplitude}"
                )
                if is_speech_vad and is_speech_amplitude:
                    self.speech_detected = True
                    silence_start = None
                elif silence_start is None:
                    silence_start = time.time()
                else:
                    threshold = (
                        self.config["post_speech_silence_duration"]
                        if self.speech_detected
                        else self.config["initial_silence_duration"]
                    )
                    if time.time() - silence_start > threshold:
                        break
                if time.time() - start_time > self.config["max_duration"]:
                    break
        audio = np.concatenate(audio, axis=0)
        duration = time.time() - start_time
        logger.info(f"🎤 Recording completed. Duration: {duration:.2f} seconds")
        if duration < min_duration_sec:
            logger.warning(
                f"Recording too short ({duration:.2f}s). Treating as no speech."
            )
            self.speech_detected = False  # suppress further processing
            return

        try:
            write(self.temp_audio_path, self.sampling_rate, audio)
            logger.info(f"💾 Audio saved to {self.temp_audio_path}")
        except Exception as e:
            logger.error(f"Error saving audio: {e}")
            raise


class Transcriber:

    def __init__(self) -> None:
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["whisper"]
        self.model = WhisperModel(
            self.config["model"],
            device=self.config["device"],
            compute_type=self.config["compute_type"],
        )

    # =================== only store transcribed_text and language —
    # =================== which means you're storing Swedish text if the speaker used Swedish.

    # def transcribe_audio(self, audio_path: str) -> Tuple[str, str]:
    #     try:
    #         segments, info = self.model.transcribe(audio_path)
    #         original_text = " ".join([segment.text for segment in segments])
    #         detected_language = info.language
    #         return original_text, detected_language
    #     except FileNotFoundError as e:
    #         logger.error(f"Audio file not found: {audio_path}")
    #         raise
    #     except RuntimeError as e:
    #         logger.error(f"Error loading Whisper model: {e}")
    #         raise
    #     except Exception as e:
    #         logger.error(f"Unexpected error during transcription: {e}")
    #         raise

    # =================== Keeps info.language accurate (auto-detected language)
    # =================== Transcribes as English, no matter the input language

    def transcribe_audio(self, audio_path: str) -> Tuple[str, str]:
        try:
            # Transcribe with forced translation to English
            segments, info = self.model.transcribe(audio_path, beam_size=5)
            detected_language = info.language
            language_prob = info.language_probability

            if language_prob < 0.5:
                logger.warning(
                    f"❗ Low language detection confidence: {language_prob:.2f} for '{detected_language}'"
                )
                raise ValueError("Unclear speech or unsupported language.")

            if detected_language != "en":
                # Re-run with translation
                segments, _ = self.model.transcribe(
                    audio_path, task="translate", beam_size=5
                )

            original_text = " ".join([segment.text for segment in segments])
            if not original_text.strip():
                raise ValueError("No intelligible speech detected.")

            language = WHISPER_LANGUAGE_NAMES.get(detected_language, detected_language)
            return original_text, language

        except FileNotFoundError as e:
            logger.error(f"Audio file not found: {audio_path}")
            raise
        except RuntimeError as e:
            logger.error(f"Error loading Whisper model: {e}")
            raise
        except Exception as e:
            logger.error(f"Unexpected error during transcription: {e}")
            raise


class Storage:
    def __init__(self) -> None:
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["database"]
        self.db_path: str = self.config["db_path"]
        self.check_database()

    def check_database(self) -> None:
        pass  # PostgreSQL always exists; no need to create .db file

    def store_instruction(
        self,
        session_id: str,
        detected_language: str,
        transcribed_text: str,
        retries: int = 3,
        delay: float = 1.0,
    ) -> None:
        for attempt in range(retries):
            try:
                conn = get_connection()
                with conn:
                    with conn.cursor() as cursor:
                        cursor.execute(
                            """
                            INSERT INTO voice_instructions (session_id, transcribed_text, language)
                            VALUES (%s, %s, %s)
                            """,
                            (session_id, transcribed_text, detected_language),
                        )
                logger.info(
                    "✅ Voice instruction stored successfully in voice_instructions table."
                )
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
                logger.error(
                    f"[PostgreSQL] Unexpected error storing voice instruction: {e}"
                )
                raise


class VoiceProcessor:
    def __init__(self, session_id: Optional[str] = None) -> None:
        self.recorder = AudioRecorder()
        self.transcriber = Transcriber()
        self.storage = Storage()
        self.session_id = session_id or str(uuid.uuid4())
        self.synthesizer = SpeechSynthesizer()
        self.recorder = AudioRecorder(self.synthesizer)

    def capture_voice(self) -> None:
        try:
            logger.info("🚀 Starting voice capture process...")
            self.recorder.record_audio()

            if not self.recorder.speech_detected:
                logger.info("No speech detected. Skipping transcription and storage.")
                try:
                    os.remove(self.recorder.temp_audio_path)
                    logger.info(
                        f"Deleted temporary audio file: {self.recorder.temp_audio_path}"
                    )
                except Exception as e:
                    logger.error(f"Error deleting temporary audio file: {e}")
                return

            logger.info("📥 Audio recording completed. Starting transcription...")

            for attempt in range(MAX_TRANSCRIPTION_RETRIES):
                try:
                    text, language = self.transcriber.transcribe_audio(
                        self.recorder.temp_audio_path
                    )
                    break  # success
                except ValueError as e:
                    logger.warning(f"Attempt {attempt+1}: {e}")
                    if attempt == MAX_TRANSCRIPTION_RETRIES - 1:
                        logger.info(
                            "❌ Failed to transcribe clearly after retries. Skipping."
                        )
                        return
                    else:
                        time.sleep(1)

            logger.info(f"📝 Transcription completed. Detected language: {language}")
            logger.info("🗃️ Storing voice instruction in the database...")
            self.storage.store_instruction(self.session_id, language, text)
            logger.info("🎉-Voice instruction captured and stored successfully!")

        except KeyboardInterrupt:
            logger.info("Voice capture process interrupted by user.")
        except ValueError as e:
            logger.info(f"⚠️ Skipping transcription: {e}")
            return
        except Exception as e:
            logger.error(f"Error in voice capture process: {e}")


if __name__ == "__main__":
    vp = VoiceProcessor()
    vp.capture_voice()






Result
"""
[2025-03-24 18:19:07] INFO - VoiceProcessor - 🚀 Starting voice capture process...
[2025-03-24 18:19:07] INFO - VoiceProcessor - 🔈 Calibrating ambient noise...
[2025-03-24 18:19:09] INFO - VoiceProcessor - ✅ Ambient noise calibration complete. Noise floor: 7.41
[2025-03-24 18:19:09] INFO - VoiceProcessor - 🎚️ Amplitude threshold set to: 107.41 (Noise floor: 7.41 + Margin: 100)
[2025-03-24 18:19:11] INFO - VoiceProcessor - 🗣️ Voice recording: Please speak now...
[2025-03-24 18:19:19] INFO - VoiceProcessor - 🎤 Recording completed. Duration: 6.37 seconds
[2025-03-24 18:19:19] INFO - VoiceProcessor - 💾 Audio saved to C:\Users\oscik559\Projects\mini_project_repo\assets\temp_audio\voice_recording.wav
[2025-03-24 18:19:19] INFO - VoiceProcessor - 📥 Audio recording completed. Starting transcription...
[2025-03-24 18:19:19] INFO - faster_whisper - 🧠 Processing audio with duration 00:06.330
[2025-03-24 18:19:19] INFO - faster_whisper - 🌐 Detected language 'en' with probability 0.56
[2025-03-24 18:19:20] INFO - VoiceProcessor - 📝 Transcription completed. Detected language: English
[2025-03-24 18:19:20] INFO - VoiceProcessor - 🗃️ Storing voice instruction in the database...
[2025-03-24 18:19:20] INFO - VoiceProcessor - ✅ Voice instruction stored successfully in voice_instructions table.
[2025-03-24 18:19:20] INFO - VoiceProcessor - 🎉 Voice instruction captured and stored successfully!
 """
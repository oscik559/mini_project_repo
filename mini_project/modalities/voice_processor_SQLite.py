# modalities/voice_processor.py

import logging
import os
import sqlite3
import tempfile
import time
import uuid
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import numpy as np
import pyttsx3
import sounddevice as sd
import webrtcvad
from faster_whisper import WhisperModel
from gtts import gTTS
from playsound import playsound
from scipy.io.wavfile import write

from config.app_config import VOICE_PROCESSING_CONFIG, VOICE_TTS_SETTINGS, setup_logging

# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("VoiceProcessor")


class AudioRecorder:
    def __init__(self) -> None:
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
        logger.info("Calibrating ambient noise...")
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
            f"Ambient noise calibration complete. Noise floor: {noise_floor:.2f}"
        )
        return noise_floor

    def record_audio(self) -> None:
        noise_floor = self.calibrate_noise()
        amplitude_threshold = noise_floor + self.config["amplitude_margin"]
        logger.info(
            f"Amplitude threshold set to: {amplitude_threshold:.2f} (Noise floor: {noise_floor:.2f} + Margin: {self.config['amplitude_margin']})"
        )
        logger.info("Voice recording: Please speak now...")

        # 🔔 Play ding sound immediately after prompt
        try:
            SpeechSynthesizer().play_ding()
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
        logger.info(f"Recording completed. Duration: {duration:.2f} seconds")
        try:
            write(self.temp_audio_path, self.sampling_rate, audio)
            logger.info(f"Audio saved to {self.temp_audio_path}")
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

    def transcribe_audio(self, audio_path: str) -> Tuple[str, str]:
        try:
            segments, info = self.model.transcribe(audio_path)
            original_text = " ".join([segment.text for segment in segments])
            detected_language = info.language
            return original_text, detected_language
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
        if not os.path.exists(self.db_path):
            open(self.db_path, "w").close()
            logger.info(f"Created database file: {self.db_path}")
        # self.ensure_table_exists()

    # def ensure_table_exists(self) -> None:
    #     with sqlite3.connect(self.db_path) as conn:
    #         cursor = conn.cursor()
    #         cursor.execute(
    #             """
    #             CREATE TABLE IF NOT EXISTS voice_instructions (
    #                 id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                 session_id TEXT NOT NULL,
    #                 timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    #                 transcribed_text TEXT NOT NULL,
    #                 language TEXT NOT NULL,
    #                 confidence REAL,
    #                 processed BOOLEAN DEFAULT FALSE
    #             )
    #             """
    #         )
    #         conn.commit()
    #         logger.info("Ensured voice_instructions table exists in the database.")

    # def ensure_table_exists(self) -> None:
    #     with sqlite3.connect(self.db_path) as conn:
    #         cursor = conn.cursor()
    #         cursor.execute(
    #             """
    #             CREATE TABLE IF NOT EXISTS instructions (
    #                 id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                 session_id TEXT,
    #                 modality TEXT NOT NULL,
    #                 language TEXT NOT NULL,
    #                 instruction_type TEXT NOT NULL,
    #                 transcribed_text TEXT NOT NULL,
    #                 timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    #             )
    #         """
    #         )
    #         conn.commit()
    #         logger.info("Ensured instructions table exists in the database.")

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
                with sqlite3.connect(self.db_path) as conn:
                    cursor = conn.cursor()
                    cursor.execute(
                        """
                        INSERT INTO voice_instructions (session_id, transcribed_text, language)
                        VALUES (?, ?, ?)
                    """,
                        (
                            session_id,
                            transcribed_text,
                            detected_language,
                        ),
                    )
                    conn.commit()
                    logger.info(
                        "Voice instruction stored successfully in voice_instructions table."
                    )
                    return
            except sqlite3.OperationalError as e:
                if "database is locked" in str(e) and attempt < retries - 1:
                    logger.warning(f"Database locked. Retrying in {delay} seconds...")
                    time.sleep(delay)
                else:
                    logger.error(f"Error storing voice instruction: {e}")
                    raise
            except Exception as e:
                logger.error(f"Unexpected error storing voice instruction: {e}")
                raise


class VoiceProcessor:
    def __init__(self, session_id: Optional[str] = None) -> None:
        self.recorder = AudioRecorder()
        self.transcriber = Transcriber()
        self.storage = Storage()
        self.session_id = session_id or str(uuid.uuid4())

    def capture_voice(self) -> None:
        try:
            logger.info("Starting voice capture process...")
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
            logger.info("Audio recording completed. Starting transcription...")
            text, language = self.transcriber.transcribe_audio(
                self.recorder.temp_audio_path
            )
            logger.info(f"Transcription completed. Detected language: {language}")
            logger.info("Storing voice instruction in the database...")
            self.storage.store_instruction(self.session_id, language, text)
            logger.info("Voice instruction captured and stored successfully!")
        except KeyboardInterrupt:
            logger.info("Voice capture process interrupted by user.")
        except Exception as e:
            logger.error(f"Error in voice capture process: {e}")


class SpeechSynthesizer:
    def __init__(self):
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
            except IndexError:
                logger.warning(
                    f"[TTS] Voice index {self.voice_index} is not valid. Using default voice."
                )
                self.engine = pyttsx3.init()
                self.engine.setProperty("rate", self.voice_speed)
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


if __name__ == "__main__":
    vp = VoiceProcessor()
    vp.capture_voice()

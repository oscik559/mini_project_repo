# scripts/voice_processor.py
import logging
import os
import sqlite3
import time
from datetime import datetime
from typing import Any, Dict, Optional, Tuple

import numpy as np
import sounddevice as sd
import webrtcvad
from faster_whisper import WhisperModel
from scipy.io.wavfile import write

# Import configurations from config.py
from config.app_config import VOICE_PROCESSING_CONFIG
from mini_project.modalities.command_unifier import CommandUnifier

# Setup logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("voice_processor")


# Decoupled AudioRecorder class
class AudioRecorder:
    def __init__(self) -> None:
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["recording"]
        self.temp_audio_path: str = self.config["temp_audio_path"]
        self.sampling_rate: int = self.config["sampling_rate"]
        self.vad = webrtcvad.Vad()
        self.vad.set_mode(3)  # Aggressive mode to filter out background noise
        self.speech_detected = False  # Add this line

        # Validate configuration
        if not isinstance(self.sampling_rate, int) or self.sampling_rate <= 0:
            raise ValueError("Sampling rate must be a positive integer.")
        if not isinstance(self.temp_audio_path, str):
            raise ValueError("Temp audio path must be a string.")

    def calibrate_noise(self) -> float:
        """Calibrates ambient noise and calculates the noise floor."""
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
        """
        Records audio from the user and saves it to a WAV file.
        Stops recording if:
          - No speech is detected for `initial_silence_duration` seconds (before any speech), or
          - After speech is detected, silence lasts for `post_speech_silence_duration` seconds.
        """
        # Step 1: Calibrate ambient noise
        noise_floor = self.calibrate_noise()

        amplitude_threshold = noise_floor + self.config["amplitude_margin"]
        logger.info(
            f"Amplitude threshold set to: {amplitude_threshold:.2f} "
            f"(Noise floor: {noise_floor:.2f} + Margin: {self.config['amplitude_margin']})"
        )

        logger.info("Voice recording: Please speak now...")

        audio = []
        start_time = time.time()
        silence_start: Optional[float] = None
        self.speech_detected = False  # Reset speech detection flag

        stream = sd.InputStream(
            samplerate=self.sampling_rate, channels=1, dtype="int16"
        )
        with stream:
            while True:
                frame, _ = stream.read(
                    int(self.sampling_rate * self.config["frame_duration"])
                )
                audio.append(frame)

                # Use VAD and amplitude threshold to detect speech
                is_speech_vad = self.vad.is_speech(frame.tobytes(), self.sampling_rate)
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                is_speech_amplitude = rms > amplitude_threshold

                if is_speech_vad and is_speech_amplitude:
                    self.speech_detected = True  # Set speech detection flag
                    silence_start = None  # Reset silence timer
                else:
                    if silence_start is None:
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

        # Log recording duration
        duration = time.time() - start_time
        logger.info(f"Recording completed. Duration: {duration:.2f} seconds")

        # Save the recorded audio to a WAV file
        try:
            write(self.temp_audio_path, self.sampling_rate, audio)
            logger.info(f"Audio saved to {self.temp_audio_path}")
        except Exception as e:
            logger.error(f"Error saving audio: {e}")
            raise


# Decoupled Transcriber class
class Transcriber:
    def __init__(self) -> None:
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["whisper"]
        self.model = WhisperModel(
            self.config["model"],
            device=self.config["device"],
            compute_type=self.config["compute_type"],
        )

    def transcribe_audio(self, audio_path: str) -> Tuple[str, str]:
        """Transcribes audio using Whisper."""
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


# Decoupled Storage class
class Storage:
    def __init__(self) -> None:
        self.config: Dict[str, Any] = VOICE_PROCESSING_CONFIG["database"]
        self.db_path: str = self.config["db_path"]
        self.check_database()

    def check_database(self) -> None:
        """Ensure database file and table exist."""
        if not os.path.exists(self.db_path):
            open(self.db_path, "w").close()
            logger.info(f"Created database file: {self.db_path}")
        self.ensure_table_exists()

    def ensure_table_exists(self) -> None:
        """Ensure the instructions table exists in the database."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS instructions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    modality TEXT NOT NULL,
                    language TEXT NOT NULL,
                    instruction_type TEXT NOT NULL,
                    content TEXT NOT NULL,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """
            )
            conn.commit()
            logger.info("Ensured instructions table exists in the database.")

    def store_instruction(
        self,
        modality: str,
        detected_language: str,
        content: str,
        retries: int = 3,
        delay: float = 1.0,
    ) -> None:
        """Stores transcribed instruction in the database with retries."""
        for attempt in range(retries):
            try:
                with sqlite3.connect(self.db_path) as conn:
                    cursor = conn.cursor()
                    cursor.execute(
                        """
                        INSERT INTO instructions (modality, language, instruction_type, content)
                        VALUES (?, ?, ?, ?)
                        """,
                        (modality, detected_language, "voice command", content),
                    )
                    conn.commit()
                    logger.info("Instruction stored successfully.")
                    return  # Exit on success
            except sqlite3.OperationalError as e:
                if "database is locked" in str(e) and attempt < retries - 1:
                    logger.warning(f"Database locked. Retrying in {delay} seconds...")
                    time.sleep(delay)
                else:
                    logger.error(f"Error storing instruction: {e}")
                    raise
            except Exception as e:
                logger.error(f"Unexpected error storing instruction: {e}")
                raise


# VoiceProcessor class to orchestrate the components
# class VoiceProcessor:
#     def __init__(self) -> None:
#         self.recorder = AudioRecorder()
#         self.transcriber = Transcriber()
#         self.storage = Storage()

#     def capture_voice(self) -> None:
#         try:
#             logger.info("Starting voice capture process...")
#             self.recorder.record_audio()

#             # Check if speech was detected during recording
#             if not self.recorder.speech_detected:
#                 logger.info("No speech detected. Skipping transcription and storage.")
#                 try:
#                     os.remove(self.recorder.temp_audio_path)
#                     logger.info(
#                         f"Deleted temporary audio file: {self.recorder.temp_audio_path}"
#                     )
#                 except Exception as e:
#                     logger.error(f"Error deleting temporary audio file: {e}")
#                 return

#             logger.info("Audio recording completed. Starting transcription...")
#             text, language = self.transcriber.transcribe_audio(
#                 self.recorder.config["temp_audio_path"]
#             )
#             logger.info(f"Transcription completed. Detected language: {language}")
#             logger.info("Storing instruction in the database...")
#             self.storage.store_instruction("voice", language, text)
#             logger.info("Voice instruction captured and stored successfully!")
#         except KeyboardInterrupt:
#             logger.info("Voice capture process interrupted by user.")
#         except Exception as e:
#             logger.error(f"Error in voice capture process: {e}")


# In voice_processor.py
class VoiceProcessor:
    def __init__(self, unifier: CommandUnifier):  # Add unifier parameter
        self.recorder = AudioRecorder()
        self.transcriber = Transcriber()
        self.unifier = unifier  # Add reference to unifier

    def capture_voice(self):
        try:
            self.recorder.record_audio()
            if not self.recorder.speech_detected:
                return

            text, language = self.transcriber.transcribe_audio(
                self.recorder.temp_audio_path
            )

            # Send to unifier instead of direct storage
            self.unifier.add_command(
                {
                    "modality": "voice",
                    "timestamp": datetime.now().isoformat(),
                    "command_type": "voice_command",
                    "content": text,
                    "language": language,
                    "confidence": 1.0,  # Could use Whisper confidence if available
                }
            )

        except Exception as e:
            logging.error(f"Error in voice capture process: {e}")


if __name__ == "__main__":
    processor = VoiceProcessor()
    processor.capture_voice()

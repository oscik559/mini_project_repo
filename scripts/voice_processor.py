# Description: This script captures voice commands from the user and stores them in a SQLite database.
import sys
from pathlib import Path

# Ensure the parent directory is included in sys.path for imports
sys.path.append(str(Path(__file__).parent.parent))
from config.config import DB_PATH, TEMP_AUDIO_PATH

import logging
import os
import sqlite3
import time

import numpy as np
import sounddevice as sd
import webrtcvad

from faster_whisper import WhisperModel
from scipy.io.wavfile import write

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("voice_processor")

# Define the VoiceProcessor class
class VoiceProcessor:
    def __init__(self, update_status_callback=None):
        self.db_path = DB_PATH  # Use DB_PATH from config
        self.audio_file_path = os.path.join(TEMP_AUDIO_PATH, "recording.wav")  # Ensure it's a file
        self.model = WhisperModel("large-v3", device="cuda", compute_type="float16")  # Whisper model for transcription
        self.vad = webrtcvad.Vad()
        self.vad.set_mode(1)  # VAD sensitivity
        self.update_status = update_status_callback  # Callback for GUI status updates

        logger.info(f"Using database path: {self.db_path}")  # Debugging: Verify DB path
        self.check_directories()  # Ensure required directories exist
        self.check_database()   # Check if the database file exists

    def check_directories(self):
        """Ensure required directories exist."""
        os.makedirs(TEMP_AUDIO_PATH, exist_ok=True)
        logger.info(f"Verified audio storage path: {TEMP_AUDIO_PATH}")

    def check_database(self):
        """Ensure database file exists."""
        if not os.path.exists(self.db_path):
            open(self.db_path, "w").close()
            logger.info(f"Created database file: {self.db_path}")

    def record_audio(self, max_duration=60, sampling_rate=16000, silence_duration=2):
        """
        Records audio from the user and saves it to a WAV file.

        Args:
            max_duration (int, optional): Maximum recording duration in seconds. Defaults to 60.
            sampling_rate (int, optional): Audio sample rate. Defaults to 16000.
            silence_duration (int, optional): Duration of silence before stopping recording. Defaults to 2.
        """
        logger.info("Voice recording: Please speak now...")

        audio = []
        start_time = time.time()
        silence_start = None
        stream = sd.InputStream(samplerate=sampling_rate, channels=1, dtype="int16")
        with stream:
            while True:
                frame, _ = stream.read(int(sampling_rate * 0.03))  # 30ms frames
                audio.append(frame)
                is_speech = self.vad.is_speech(frame.tobytes(), sampling_rate)
                if is_speech:
                    silence_start = None
                else:
                    if silence_start is None:
                        silence_start = time.time()
                    elif time.time() - silence_start > silence_duration:
                        break
                if time.time() - start_time > max_duration:
                    break

        audio = np.concatenate(audio, axis=0)

        # **Ensure we are saving to a valid file path**
        try:
            write(self.audio_file_path, sampling_rate, audio)
            logger.info(f"Audio saved to {self.audio_file_path}")
        except PermissionError as e:
            logger.error(f"PermissionError: Unable to write to {self.audio_file_path}. Check file permissions.")
        except Exception as e:
            logger.error(f"Unexpected error writing audio file: {e}")

    def store_instruction(self, modality, detected_language, content):
        """
        Stores transcribed voice instruction into the SQLite database.

        Args:
            modality (str): The modality of instruction (e.g., "voice").
            detected_language (str): Language detected in audio.
            content (str): Transcribed instruction text.
        """
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO instructions (modality, language, instruction_type, content)
                VALUES (?, ?, ?, ?)
                """,
                (modality, detected_language, "voice command", content),
            )
            conn.commit()
            conn.close()
            logger.info("Instruction stored successfully.")
        except Exception as e:
            logger.error(f"Error storing instruction in database: {e}")

    def capture_voice(self):
        """
        Captures voice input, transcribes it using Whisper, and stores the instruction in the database.
        """
        self.record_audio()

        try:
            segments, info = self.model.transcribe(self.audio_file_path)
            original_text = " ".join([segment.text for segment in segments])
            detected_language = info.language

            if detected_language != "en":
                # Optionally translate text here
                pass

            self.store_instruction("voice", detected_language, original_text)
            logger.info("Voice instruction captured successfully!")
        except Exception as e:
            logger.error(f"Error during transcription: {e}")


if __name__ == "__main__":
    processor = VoiceProcessor()
    processor.capture_voice()

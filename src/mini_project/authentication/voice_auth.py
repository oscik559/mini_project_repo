# authentication/voice_auth.py
"""
Voice Authentication Module

This module provides a voice authentication system that:
- Records audio using sounddevice.
- Transcribes audio via Google Speech Recognition.
- Captures voice embeddings using resemblyzer.
- Stores voice embeddings in a SQLite database (using upsert) and as a pickle file.

It demonstrates:
- Using context managers for resource handling.
- Consistent error messaging and granular error handling (merged in the script).
- Logging configuration and type annotations.
"""

import logging
import os
import pickle
import re
import sqlite3
import warnings
from contextlib import contextmanager
from typing import List

import sounddevice as sd
from resemblyzer import VoiceEncoder, preprocess_wav
from scipy.io.wavfile import write
from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

from config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH, setup_logging

# Suppress warnings if desired
warnings.filterwarnings("ignore", category=FutureWarning)


# Context manager for handling an audio recording session.
@contextmanager
def audio_session():
    try:
        yield
    finally:
        sd.stop()


class VoiceAuth:
    """
    A class for voice authentication which handles:
    - Audio recording.
    - Transcription.
    - Voice embedding capture.
    - Storing embeddings in a SQLite database and on disk.
    """

    def __init__(
        self,
        db_path: str,
        temp_audio_path: str = TEMP_AUDIO_PATH,
        voice_data_path: str = VOICE_DATA_PATH,
    ) -> None:
        self.db_path = db_path
        self.temp_audio_path = temp_audio_path
        self.voice_data_path = voice_data_path
        self.encoder = VoiceEncoder()
        self._create_directories()
        self._initialize_database()

    def _create_directories(self) -> None:
        """Ensure that the directories for voice data and temporary audio exist."""
        os.makedirs(self.voice_data_path, exist_ok=True)
        os.makedirs(self.temp_audio_path, exist_ok=True)
        logging.info("Directories ensured for voice data and temporary audio.")

    def _initialize_database(self) -> None:
        """Initialize the SQLite database with the required users table."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS users (
                        user_id INTEGER PRIMARY KEY,
                        first_name TEXT NOT NULL,
                        last_name TEXT NOT NULL,
                        liu_id TEXT UNIQUE,
                        email TEXT UNIQUE,
                        preferences TEXT,
                        profile_image_path TEXT,
                        interaction_memory TEXT,
                        face_encoding BLOB,
                        voice_embedding BLOB,
                        created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
                        last_updated TIMESTAMP DEFAULT (datetime('now','localtime'))
                    );
                """
                )
                conn.commit()
            logging.info("Database initialized successfully.")
        except sqlite3.Error as e:
            msg = f"Database initialization error: {e}"
            logging.error(msg)
            raise Exception(msg)

    def _record_audio(
        self, filename: str, prompt: str, duration: int = 5, sampling_rate: int = 16000
    ) -> None:
        """
        Record audio from the microphone and save it to a WAV file.

        Args:
            filename (str): The file path to save the recorded audio.
            prompt (str): The message to display to the user before recording.
            duration (int): Duration of the recording in seconds.
            sampling_rate (int): Sampling rate for the audio recording.
        """
        logging.info(prompt)
        try:
            with audio_session():
                audio = sd.rec(
                    int(duration * sampling_rate),
                    samplerate=sampling_rate,
                    channels=1,
                    dtype="int16",
                )
                sd.wait()
            write(filename, sampling_rate, audio)
            logging.info(f"Audio recorded and saved to {filename}")
        except Exception as e:
            msg = f"Error during audio recording: {e}"
            logging.error(msg)
            raise Exception(msg)

    def _transcribe_audio(self, filename: str) -> str:
        """
        Transcribe recorded audio to text using Google Speech Recognition.

        Args:
            filename (str): The file path of the audio file.

        Returns:
            str: The transcribed text.

        Raises:
            Exception: If transcription fails.
        """
        recognizer = Recognizer()
        try:
            with AudioFile(filename) as source:
                audio = recognizer.record(source)
                text = recognizer.recognize_google(audio)
                logging.info(f"Transcription: {text}")
                return text
        except UnknownValueError:
            msg = "Audio transcription failed: speech was unintelligible."
            logging.error(msg)
            raise Exception(msg)
        except RequestError as e:
            msg = f"Audio transcription failed: API error: {e}"
            logging.error(msg)
            raise Exception(msg)
        except Exception as e:
            msg = f"An unexpected error occurred during transcription: {e}"
            logging.error(msg)
            raise Exception(msg)

    def _capture_voice_embedding(self, audio_path: str) -> List[float]:
        """
        Capture a voice embedding from the recorded audio.

        Args:
            audio_path (str): Path to the audio file.

        Returns:
            List[float]: The voice embedding vector.
        """
        try:
            wav = preprocess_wav(audio_path)
            embedding = self.encoder.embed_utterance(wav)
            logging.info(f"Voice embedding captured, shape: {embedding.shape}")
            return embedding.tolist()
        except Exception as e:
            msg = f"Error capturing voice embedding: {e}"
            logging.error(msg)
            raise Exception(msg)

    @staticmethod
    def _validate_liu_id(liu_id: str) -> bool:
        """
        Validate the LIU ID format.

        Args:
            liu_id (str): The LIU ID to validate.

        Returns:
            bool: True if the LIU ID is valid; False otherwise.
        """
        pattern = r"^[a-z]{5}[0-9]{3}$"
        return bool(re.match(pattern, liu_id))

    def _save_voice_embedding(
        self, liu_id: str, voice_embedding: List[float], first_name: str, last_name: str
    ) -> None:
        """
        Save the voice embedding in the database (using upsert) and as a pickle file.

        Args:
            liu_id (str): The LIU ID of the user.
            voice_embedding (List[float]): The voice embedding vector.
            first_name (str): The user's first name.
            last_name (str): The user's last name.
        """
        voice_file = os.path.join(self.voice_data_path, f"{liu_id}_voice.pkl")
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    INSERT INTO users (liu_id, voice_embedding, first_name, last_name)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT(liu_id) DO UPDATE SET voice_embedding = excluded.voice_embedding
                """,
                    (liu_id, pickle.dumps(voice_embedding), first_name, last_name),
                )
                conn.commit()
            with open(voice_file, "wb") as file:
                pickle.dump(voice_embedding, file)
            logging.info(f"Voice embedding saved for LIU ID: {liu_id}")
        except sqlite3.Error as e:
            msg = f"Error saving voice embedding to database: {e}"
            logging.error(msg)
            raise Exception(msg)
        except Exception as e:
            msg = f"Error saving voice embedding to file: {e}"
            logging.error(msg)
            raise Exception(msg)

    def register_user(self) -> None:
        """
        Register a new user using voice authentication.

        This method:
        - Collects user details.
        - Records a voice statement.
        - Transcribes the statement.
        - Captures the voice embedding.
        - Saves the embedding in the database and as a file.
        """
        logging.info("Starting voice-driven user registration...")
        try:
            first_name = input("Enter your first name: ").strip()
            if not first_name:
                raise Exception("First name cannot be empty.")

            last_name = input("Enter your last name: ").strip()
            if not last_name:
                raise Exception("Last name cannot be empty.")

            liu_id = input("Enter your LIU ID (e.g. abcxy123): ").strip()
            if not self._validate_liu_id(liu_id):
                raise Exception("Invalid LIU ID format.")

            # Record a voice statement.
            statement_audio = os.path.join(
                self.temp_audio_path, f"{liu_id}_statement.wav"
            )
            self._record_audio(
                statement_audio,
                "Please read the following sentence clearly: 'Artificial intelligence enables machines to recognize patterns, process language, and make decisions.'",
                duration=12,
            )

            # Transcribe the audio.
            transcription = self._transcribe_audio(statement_audio)
            if not transcription:
                raise Exception("Audio transcription failed. Please try again.")

            # Capture the voice embedding.
            embedding = self._capture_voice_embedding(statement_audio)
            if not embedding:
                raise Exception("Failed to capture voice embedding.")

            # Save the voice embedding, passing first_name and last_name.
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logging.info(
                f"Registration complete for {first_name} {last_name} (LIU ID: {liu_id})."
            )
        except Exception as e:
            logging.exception("Registration failed.")
            print(f"Registration failed: {e}")


if __name__ == "__main__":
    auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
    auth.register_user()

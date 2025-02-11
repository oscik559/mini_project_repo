"""
Voice Authentication Module

This module provides a voice authentication system that uses OpenCV,
face_recognition, and FAISS for similarity search. It supports:
  - Recording audio,
  - Transcription via Google Speech Recognition,
  - Capturing voice embeddings using resemblyzer,
  - Storing voice embeddings in a database and on file.

NOTE: Currently the script uses sys.path.append for module resolution.
Once you convert this project into a proper package (with a setup.py file),
you should remove the sys.path.append line and update the imports to use absolute
or relative imports appropriately.
"""

import os
import pickle
import re
import sqlite3
import sys
import warnings
from pathlib import Path

# Temporarily add the parent folder to the module search path.
sys.path.append(str(Path(__file__).parent.parent))

import sounddevice as sd
from resemblyzer import VoiceEncoder, preprocess_wav
from scipy.io.wavfile import write
from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH
from db_handler import DatabaseHandler

# Suppress future warnings
warnings.filterwarnings("ignore", category=FutureWarning)

# Configure logging.
import logging
logging.basicConfig(level=logging.DEBUG, format="%(asctime)s [%(levelname)s] %(message)s")


class VoiceAuth:
    def __init__(self, db_path, temp_audio_path, voice_data_path):
        """
        Initialize voice authentication system with configuration paths.

        Args:
            db_path: Path to SQLite database.
            temp_audio_path: Temporary directory for audio recordings.
            voice_data_path: Directory for storing voice embeddings.
        """
        self.DB_PATH = db_path
        self.TEMP_AUDIO_PATH = temp_audio_path
        self.VOICE_DATA_PATH = voice_data_path
        self.encoder = VoiceEncoder()

        self._create_directories()
        self._initialize_database()

    def _create_directories(self):
        """Create required directories if they don't exist."""
        os.makedirs(self.VOICE_DATA_PATH, exist_ok=True)
        os.makedirs(self.TEMP_AUDIO_PATH, exist_ok=True)
        logging.debug("Directories ensured: VOICE_DATA_PATH and TEMP_AUDIO_PATH.")

    def _initialize_database(self):
        """Initialize database with required tables."""
        try:
            conn = sqlite3.connect(self.DB_PATH)
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
            logging.info("Database initialized with required tables.")
        except Exception as e:
            logging.exception("Error initializing database:")
        finally:
            conn.close()

    def _record_audio(self, filename, prompt, duration=5, sampling_rate=16000):
        """
        Record audio and save to file.

        Args:
            filename: Output filename.
            prompt: Message to display to user.
            duration: Recording duration in seconds.
            sampling_rate: Audio sampling rate.
        """
        try:
            logging.info(prompt)
            audio = sd.rec(int(duration * sampling_rate),
                           samplerate=sampling_rate,
                           channels=1,
                           dtype="int16")
            sd.wait()
            write(filename, sampling_rate, audio)
            logging.info(f"Audio saved to {filename}")
        except Exception as e:
            logging.exception("Error during audio recording:")
            raise

    def _transcribe_audio(self, filename):
        """
        Transcribe audio using Google Speech Recognition.

        Args:
            filename: Path to audio file.

        Returns:
            Transcribed text or None if failed.
        """
        recognizer = Recognizer()
        try:
            with AudioFile(filename) as source:
                audio = recognizer.record(source)
                text = recognizer.recognize_google(audio)
                logging.info(f"Transcription: {text}")
                return text
        except UnknownValueError:
            logging.error("Speech recognition could not understand the audio.")
            return None
        except RequestError as e:
            logging.error(f"Error with the Speech Recognition API: {e}")
            return None
        except Exception as e:
            logging.exception("Unexpected error during transcription:")
            return None

    def _capture_voice_embedding(self, audio_path):
        """
        Create voice embedding from audio file.

        Args:
            audio_path: Path to audio file.

        Returns:
            Voice embedding as a list or None if failed.
        """
        try:
            wav = preprocess_wav(audio_path)
            embedding = self.encoder.embed_utterance(wav)
            logging.info(f"Voice embedding captured with shape: {embedding.shape}")
            return embedding.tolist()
        except Exception as e:
            logging.exception("Error capturing voice embedding:")
            return None

    @staticmethod
    def _validate_liu_id(liu_id):
        """
        Validate LIU ID format.

        Args:
            liu_id: ID to validate.

        Returns:
            True if the format is valid, False otherwise.
        """
        pattern = r"^[a-z]{5}[0-9]{3}$"
        return bool(re.match(pattern, liu_id))

    def _save_voice_embedding(self, liu_id, voice_embedding):
        """
        Save voice embedding to the database and to a file.

        Args:
            liu_id: User's LIU ID.
            voice_embedding: Voice embedding to save.
        """
        conn = sqlite3.connect(self.DB_PATH)
        cursor = conn.cursor()
        voice_file = os.path.join(self.VOICE_DATA_PATH, f"{liu_id}_voice.pkl")

        try:
            # Update existing user or insert new user record.
            cursor.execute(
                "UPDATE users SET voice_embedding = ? WHERE liu_id = ?",
                (pickle.dumps(voice_embedding), liu_id),
            )
            if cursor.rowcount == 0:
                cursor.execute(
                    "INSERT INTO users (liu_id, voice_embedding) VALUES (?, ?)",
                    (liu_id, pickle.dumps(voice_embedding)),
                )
            conn.commit()
            with open(voice_file, "wb") as file:
                pickle.dump(voice_embedding, file)
            logging.info(f"Voice embedding saved for LIU ID: {liu_id}")
        except Exception as e:
            logging.exception("Error saving voice embedding:")
        finally:
            conn.close()

    def register_user(self):
        """Main workflow for voice-driven user registration."""
        logging.info("Voice-driven registration started...")
        try:
            first_name = input("Type your first name: ").strip()
            if not first_name:
                raise ValueError("First name cannot be empty.")

            last_name = input("Type your last name: ").strip()
            if not last_name:
                raise ValueError("Last name cannot be empty.")

            liu_id = input("Type your LIU ID (e.g. abcxy123): ").strip()
            if not self._validate_liu_id(liu_id):
                raise ValueError("Invalid LIU ID format.")

            # Voice enrollment process
            statement_audio = os.path.join(self.TEMP_AUDIO_PATH, f"{liu_id}_statement.wav")
            self._record_audio(
                statement_audio,
                "Please read the following sentence clearly: 'Artificial intelligence enables machines to recognize patterns, process language, and make decisions, simulating human intelligence in innovative ways.'",
                duration=12,
            )

            # Verify transcription and provide clear feedback.
            transcription = self._transcribe_audio(statement_audio)
            if not transcription:
                raise ValueError("Audio transcription failed. Please try again.")

            # Capture voice embedding.
            embeddings = self._capture_voice_embedding(statement_audio)
            if not embeddings:
                raise ValueError("Failed to capture voice embeddings.")

            self._save_voice_embedding(liu_id, embeddings)
            logging.info(f"Registration complete for {first_name} {last_name} with LIU ID: {liu_id}.")
        except Exception as e:
            logging.exception(f"Error during registration: {e}")

if __name__ == "__main__":
    # # NOTE: When converting this project into a proper package with setup.py,
    # # remove the sys.path.append line at the top and update the imports accordingly.

    from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

    auth_system = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
    auth_system.register_user()

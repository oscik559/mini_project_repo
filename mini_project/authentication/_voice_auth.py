# authentication/voice_auth_pgSQL.py
"""
This module provides a voice authentication system using PostgreSQL as the database backend.
It includes functionalities for user registration, voice embedding storage, and voice-based user verification.
Classes:
    VoiceAuth:
        A class for handling voice authentication, including:
        - Transcription using Google Speech Recognition.
        - Voice embedding generation using the Resemblyzer library.
        - Storing embeddings in a PostgreSQL database and as pickle files.
        - User registration and login via voice verification.
Functions:
    audio_session():
        A context manager for managing audio recording sessions.
Constants:
    MAX_RETRIES: int
        Maximum number of retries for transcription matching during registration.
    TEMP_AUDIO_PATH: str
        Path to store temporary audio files.
    TRANSCRIPTION_SENTENCE: str
        The sentence users must read for transcription and verification.
    VOICE_DATA_PATH: str
        Path to store voice embedding pickle files.
    VOICE_MATCH_THRESHOLD: float
        Threshold for cosine similarity to determine voice match.
"""


import logging
import os
import pickle
import re
import string
import warnings
from contextlib import contextmanager
from typing import List

import psycopg2
import sounddevice as sd
from resemblyzer import VoiceEncoder, preprocess_wav
from scipy.io.wavfile import write
from sklearn.metrics.pairwise import cosine_similarity
from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

from config.app_config import (
    MAX_RETRIES,
    TEMP_AUDIO_PATH,
    TRANSCRIPTION_SENTENCE,
    VOICE_DATA_PATH,
    VOICE_MATCH_THRESHOLD,
    setup_logging,
)
from mini_project.database.connection import get_connection

# Suppress warnings if desired
warnings.filterwarnings("ignore", category=FutureWarning)
logger = logging.getLogger("VoiceAutSystem")


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
        temp_audio_path: str = TEMP_AUDIO_PATH,
        voice_data_path: str = VOICE_DATA_PATH,
    ) -> None:
        self.temp_audio_path = temp_audio_path
        self.voice_data_path = voice_data_path
        self.encoder = VoiceEncoder()
        self._create_directories()
        self.conn = get_connection()
        self.cursor = self.conn.cursor()

    def _create_directories(self) -> None:
        """Ensure that the directories for voice data and temporary audio exist."""
        os.makedirs(self.voice_data_path, exist_ok=True)
        os.makedirs(self.temp_audio_path, exist_ok=True)
        logger.info("🟢 Directories ensured for voice data and temporary audio.")

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
        logger.info(prompt)
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
            logger.info(f"✅ Audio recorded and saved to {filename}")
        except Exception as e:
            msg = f"🔴 Error during audio recording: {e}"
            logger.error(msg)
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
                logger.info(f"🟢 Transcription: {text}")
                return text
        except UnknownValueError:
            msg = "🔴 Audio transcription failed: speech was unintelligible."
            logger.error(msg)
            raise Exception(msg)
        except RequestError as e:
            msg = f"🔴 Audio transcription failed: API error: {e}"
            logger.error(msg)
            raise Exception(msg)
        except Exception as e:
            msg = f"🔴 An unexpected error occurred during transcription: {e}"
            logger.error(msg)
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
            logger.info(f"✅ Voice embedding captured, shape: {embedding.shape}")
            return embedding.tolist()
        except Exception as e:
            msg = f"🔴 Error capturing voice embedding: {e}"
            logger.error(msg)
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
            self.cursor.execute(
                """
                    INSERT INTO users (liu_id, voice_embedding, first_name, last_name)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT(liu_id) DO UPDATE SET voice_embedding = EXCLUDED.voice_embedding
                """,
                (
                    liu_id,
                    psycopg2.Binary(pickle.dumps([voice_embedding])),
                    first_name,
                    last_name,
                ),
            )
            self.conn.commit()

            with open(voice_file, "wb") as file:
                pickle.dump(voice_embedding, file)

            logger.info(f"✅ Voice embedding saved for LIU ID: {liu_id}")
        except psycopg2.Error as e:
            self.conn.rollback()
            logger.error(f"🔴 Error saving voice embedding to database: {e}")
            raise
        except Exception as e:
            logger.error(f"🔴 Error saving voice embedding to file: {e}")
            raise

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
        logger.info("🟡 Starting voice-driven user registration...")
        try:
            first_name = input("🟡 Enter your first name: ").strip()
            if not first_name:
                raise Exception("First name cannot be empty.")

            last_name = input("🟡 Enter your last name: ").strip()
            if not last_name:
                raise Exception("Last name cannot be empty.")

            liu_id = input("🟡 Enter your LIU ID (e.g. abcxy123): ").strip()
            if not self._validate_liu_id(liu_id):
                raise Exception("Invalid LIU ID format.")

            # Record a voice statement.
            statement_audio = os.path.join(
                self.temp_audio_path, f"{liu_id}_statement.wav"
            )

            # Retry loop
            max_attempts = MAX_RETRIES
            for attempt in range(1, max_attempts + 1):
                self._record_audio(
                    statement_audio,
                    f"🟡 Please read the following sentence clearly: '{TRANSCRIPTION_SENTENCE}'",
                    duration=12,
                )

                # Transcribe the audio.
                transcription = self._transcribe_audio(statement_audio)
                if not transcription:
                    logger.info("🔴 Audio Transcription failed. Trying again...")
                    continue

                # Compare transcription
                if self._normalize_text(transcription) == self._normalize_text(
                    TRANSCRIPTION_SENTENCE
                ):
                    break
                else:
                    logger.info(
                        f"🔴 Your transcription didn't match the expected sentence. Attempt {attempt}/{max_attempts}"
                    )
            else:
                raise Exception(
                    "🔴 Maximum attempts reached. Registration failed due to mismatched transcription."
                )

            # Capture the voice embedding.
            embedding = self._capture_voice_embedding(statement_audio)
            if not embedding:
                raise Exception("Failed to capture voice embedding.")

            # Save the voice embedding, passing first_name and last_name.
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logger.info(
                f"✅ Registration complete for {first_name} {last_name} (LIU ID: {liu_id})."
            )
        except Exception as e:
            logger.exception("🔴 Registration failed.")
            logger.info(f"🔴 Registration failed: {e}")

    def _normalize_text(self, text: str) -> str:
        """Lowercase, remove punctuation, and normalize whitespace."""
        # return "".join(
        #     char for char in text.lower() if char not in string.punctuation
        # ).strip()
        return "".join(
            text.lower().translate(str.maketrans("", "", string.punctuation)).split()
        )

    def register_voice_for_user(
        self, first_name: str, last_name: str, liu_id: str, duration: int = 8
    ) -> None:
        """
        Record a voice statement for an already-registered user.
        This method does not prompt for personal details, instead it uses the provided first_name,
        last_name, and liu_id. It records audio, transcribes (if desired), captures the voice embedding,
        and updates the user record with the voice embedding.
        """
        try:
            # Construct the file path for the voice statement.
            voice_statement_audio = os.path.join(
                self.temp_audio_path, f"{liu_id}_voice.wav"
            )

            # Record a voice statement.
            self._record_audio(
                voice_statement_audio,
                "Please speak a short voice statement for registration:",
                duration=duration,
                sampling_rate=16000,  # or use your configured sampling_rate
            )

            # (Optional) Transcribe the audio and log the transcription.
            transcription = self._transcribe_audio(voice_statement_audio)
            logger.info("🟢 Voice transcription: %s", transcription)

            # Capture the voice embedding.
            embedding = self._capture_voice_embedding(voice_statement_audio)
            if not embedding:
                raise Exception("Failed to capture voice embedding.")

            # Save the voice embedding: update the database and save the pickle file.
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logger.info("✅ Voice embedding recorded and saved for LIU ID: %s", liu_id)
        except Exception as e:
            logger.error("🔴 Voice registration for user failed: %s", e)
            raise

    def verify_user_by_voice(self, liu_id: str, audio_path: str) -> bool:
        """
        Verifies whether the voice in the provided audio matches the registered user's embedding.


        Args:
            liu_id (str): The user's LIU ID.
            audio_path (str): Path to the newly recorded voice sample.

        Returns:
            bool: True if match passes the threshold; False otherwise.
        """
        try:
            # Load stored embedding
            stored_path = os.path.join(self.voice_data_path, f"{liu_id}_voice.pkl")
            if not os.path.exists(stored_path):
                raise FileNotFoundError(
                    f"🔴 No stored voice data found for LIU ID: {liu_id}"
                )

            with open(stored_path, "rb") as f:
                stored_embedding = pickle.load(f)

            # Capture new embedding from input audio
            new_embedding = self._capture_voice_embedding(audio_path)

            # Compare using cosine similarity
            similarity = cosine_similarity([new_embedding], [stored_embedding])[0][0]
            logger.info(f"🟢 Voice similarity score: {similarity:.4f}")
            return similarity >= VOICE_MATCH_THRESHOLD
        except Exception as e:
            logger.error(f"🔴 Voice verification failed: {e}")
            return False

    def close(self):
        if self.cursor:
            self.cursor.close()

    def login_user(self) -> None:
        try:
            liu_id = input("Enter your LIU ID: ").strip()
            if not self._validate_liu_id(liu_id):
                raise Exception("Invalid LIU ID format.")

            # Record new audio for verification
            login_audio = os.path.join(self.temp_audio_path, f"{liu_id}_login.wav")
            self._record_audio(
                login_audio,
                f"📣 Please read your verification sentence: {TRANSCRIPTION_SENTENCE}",
                duration=10,
            )

            if self.verify_user_by_voice(liu_id, login_audio):
                logger.info(f"✅ Verification successful for {liu_id}. Welcome back!")
            else:
                logger.info(
                    f"❌ Verification failed. The voice does not match our records."
                )
        except Exception as e:
            logger.exception("🔴 Login failed.")
            logger.error(f"🔴 Login failed: {e}")


if __name__ == "__main__":
    auth = VoiceAuth(TEMP_AUDIO_PATH, VOICE_DATA_PATH)
    # auth.register_user()
    # auth.close()

    print("Choose Action:")
    print("1. Register User")
    print("2. Login via Voice")

    choice = input("Enter 1 or 2: ").strip()

    if choice == "1":
        auth.register_user()
    elif choice == "2":
        auth.login_user()
    else:
        print("Invalid choice.")

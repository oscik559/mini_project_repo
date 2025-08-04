# authentication/_voice_auth.py
"""_voice_auth.py
This module provides the VoiceAuth class for handling voice-based user authentication and registration.
It includes functionality for:
- Recording audio from the user's microphone.
- Transcribing recorded audio to text using Google Speech Recognition.
- Capturing voice embeddings using the Resemblyzer library.
- Storing and retrieving voice embeddings in a PostgreSQL database and as local pickle files.
- Registering new users with voice authentication.
- Registering or updating a user's voice sample.
- Verifying a user's identity by comparing a new voice sample to the stored embedding.
- Handling audio session management and directory setup for audio data.
Classes:
    VoiceAuth: Handles all aspects of voice authentication, including registration, verification, and embedding management.
Functions:
    audio_session: Context manager for safely handling audio recording sessions.
Configuration:
    Uses application configuration for paths, retry limits, and thresholds.
Dependencies:
    - sounddevice
    - resemblyzer
    - scipy
    - speech_recognition
    - psycopg2
    - scikit-learn
    - pickle
    - logging
Usage:
    Run as a script to interactively register or authenticate users via voice.

"""

# ========== Standard Library Imports ==========
import logging  # For structured logging of authentication events
import os  # For file and directory operations
import pickle  # For serializing voice embeddings
import re  # For LIU ID format validation
import string  # For text normalization utilities
import warnings  # For suppressing non-critical warnings
from contextlib import contextmanager  # For audio session resource management
from typing import List  # Type hints for better code documentation

import psycopg2
import sounddevice as sd
from resemblyzer import VoiceEncoder, preprocess_wav
from scipy.io.wavfile import write
from sklearn.metrics.pairwise import cosine_similarity
from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

# ========== Third-Party Library Imports ==========
import numpy as np  # For audio data processing
import psycopg2  # PostgreSQL database connection
import sounddevice as sd  # Audio capture from microphone
import speech_recognition as sr  # Speech-to-text conversion
from resemblyzer import VoiceEncoder, normalize_volume  # Voice embedding generation
from scipy.io import wavfile  # Audio file I/O operations

# ========== Project Configuration Imports ==========
from mini_project.config.app_config import (
    MAX_RETRIES,
    TEMP_AUDIO_PATH,
    TRANSCRIPTION_SENTENCE,
    VOICE_DATA_PATH,
    VOICE_MATCH_THRESHOLD,
    setup_logging,
)
from mini_project.database.connection import get_connection

# ========== Logging and Configuration Setup ==========
setup_logging()  # Initialize logging configuration
logger = logging.getLogger("VoiceAuth")  # Create logger for this module

# Suppress non-critical warnings from external libraries
warnings.filterwarnings("ignore", category=FutureWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning, module="resemblyzer")
# ========== Audio Session Management ==========


@contextmanager
def audio_session():
    """
    Context manager for handling audio recording sessions.

    Ensures proper cleanup of audio resources by stopping sounddevice
    recording when the session ends, even if an error occurs.
    """
    try:
        yield
    finally:
        # Stop any ongoing recording and cleanup
        sd.stop()


# ========== Voice Authentication System ==========


class VoiceAuth:
    """
    A comprehensive voice authentication system that integrates multiple components:

    Core Features:
    - High-quality audio recording with noise handling
    - Speech-to-text transcription using Google's API
    - Voice embedding generation using deep learning
    - Secure storage of voice data in PostgreSQL
    - User identity verification through voice matching

    Technical Components:
    - Audio capture via sounddevice
    - Voice embedding via Resemblyzer
    - Speech recognition via Google Speech-to-Text
    - Database operations via psycopg2
    - File operations for audio and embedding storage
    """

    def __init__(
        self,
        temp_audio_path: str = TEMP_AUDIO_PATH,
        voice_data_path: str = VOICE_DATA_PATH,
    ) -> None:
        """
        Initialize the VoiceAuth system with all required components.

        Args:
            temp_audio_path (str): Directory for temporary audio files
            voice_data_path (str): Directory for persistent voice data storage
        """
        # Set up file system paths
        self.temp_audio_path = temp_audio_path
        self.voice_data_path = voice_data_path

        # Initialize voice processing components
        self.encoder = VoiceEncoder()  # Deep learning model for voice embeddings

        # Ensure required directories exist
        self._create_directories()

        # Establish database connection for user data persistence
        self.conn = get_connection()
        self.cursor = self.conn.cursor()

    # ========== Directory Management ==========

    def _create_directories(self) -> None:
        """
        Ensure that required directories exist for voice data storage.

        Creates directories for:
        - Voice data persistence (embeddings, audio files)
        - Temporary audio processing files
        """
        os.makedirs(self.voice_data_path, exist_ok=True)
        os.makedirs(self.temp_audio_path, exist_ok=True)
        logger.info("🟢 Directories ensured for voice data and temporary audio.")

    # ========== Audio Recording System ==========

    def _record_audio(
        self, filename: str, prompt: str, duration: int = 5, sampling_rate: int = 16000
    ) -> None:
        """
        Record high-quality audio from the microphone with proper session management.

        Args:
            filename (str): Output file path for the recorded audio
            prompt (str): User instruction message displayed before recording
            duration (int): Recording duration in seconds (default: 5)
            sampling_rate (int): Audio sampling rate in Hz (default: 16000)

        Raises:
            Exception: If audio recording or file saving fails
        """
        logger.info(prompt)
        try:
            with audio_session():
                # Record audio with specified parameters
                audio = sd.rec(
                    int(duration * sampling_rate),
                    samplerate=sampling_rate,
                    channels=1,  # Mono recording for voice processing
                    dtype="int16",  # 16-bit audio quality
                )
                sd.wait()  # Block until recording is complete

            # Save recorded audio to WAV file
            write(filename, sampling_rate, audio)
            logger.info(f"✅ Audio recorded and saved to {filename}")
        except Exception as e:
            msg = f"🔴 Error during audio recording: {e}"
            logger.error(msg)
            raise Exception(msg)

    # ========== Speech Recognition System ==========

    def _transcribe_audio(self, filename: str) -> str:
        """
        Convert recorded audio to text using Google Speech Recognition API.

        Args:
            filename (str): Path to the audio file for transcription

        Returns:
            str: Transcribed text from the audio file

        Raises:
            Exception: If transcription fails due to various reasons:
                - Speech was unintelligible
                - API request error
                - Unexpected processing error
        """
        recognizer = Recognizer()
        try:
            # Load audio file and prepare for recognition
            with AudioFile(filename) as source:
                audio = recognizer.record(source)
                # Send to Google Speech API for transcription
                text = recognizer.recognize_google(audio)
                logger.info(f"🟢 Transcription: {text}")
                return text
        except UnknownValueError:
            msg = "🔴 Audio transcription failed: speech was unintelligible."
            logger.info(msg)
            raise Exception(msg)
        except RequestError as e:
            msg = f"🔴 Audio transcription failed: API error: {e}"
            logger.info(msg)
            raise Exception(msg)
        except Exception as e:
            msg = f"🔴 An unexpected error occurred during transcription: {e}"
            logger.info(msg)
            raise Exception(msg)

    # ========== Voice Embedding Generation ==========

    def _capture_voice_embedding(self, audio_path: str) -> List[float]:
        """
        Generate a unique voice embedding from audio using deep learning.

        This method uses the Resemblyzer library to create a numerical
        representation of the speaker's voice characteristics that can
        be used for identity verification.

        Args:
            audio_path (str): Path to the audio file for processing

        Returns:
            List[float]: Voice embedding vector (typically 256-dimensional)

        Raises:
            Exception: If embedding generation fails
        """
        try:
            # Preprocess audio file for optimal embedding generation
            wav = preprocess_wav(audio_path)
            # Generate embedding using pre-trained deep learning model
            embedding = self.encoder.embed_utterance(wav)
            logger.info(f"✅ Voice embedding captured, shape: {embedding.shape}")
            return embedding.tolist()
        except Exception as e:
            msg = f"🔴 Error capturing voice embedding: {e}"
            logger.error(msg)
            raise Exception(msg)

    # ========== Input Validation ==========

    @staticmethod
    def _validate_liu_id(liu_id: str) -> bool:
        """
        Validate LIU ID format according to university standards.

        Expected format: 5 lowercase letters followed by 3 digits (e.g., 'abcde123')

        Args:
            liu_id (str): The LIU ID string to validate

        Returns:
            bool: True if format is valid, False otherwise
        """
        pattern = r"^[a-z]{5}[0-9]{3}$"  # 5 letters + 3 numbers
        return bool(re.match(pattern, liu_id))

    # ========== Database and File Storage ==========

    def _save_voice_embedding(
        self, liu_id: str, voice_embedding: List[float], first_name: str, last_name: str
    ) -> None:
        """
        Persist voice embedding in both database and local file system.

        Uses PostgreSQL upsert to handle both new users and updates to existing users.
        Also saves a local pickle file as backup and for faster access.

        Args:
            liu_id (str): Unique identifier for the user
            voice_embedding (List[float]): The voice embedding vector
            first_name (str): User's first name
            last_name (str): User's last name

        Raises:
            psycopg2.Error: If database operation fails
            Exception: If file operation fails
        """
        voice_file = os.path.join(self.voice_data_path, f"{liu_id}_voice.pkl")
        try:
            # Database operation with upsert (insert or update)
            self.cursor.execute(
                """
                    INSERT INTO users (liu_id, voice_embedding, first_name, last_name)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT(liu_id) DO UPDATE SET voice_embedding = EXCLUDED.voice_embedding
                """,
                (
                    liu_id,
                    psycopg2.Binary(
                        pickle.dumps([voice_embedding])
                    ),  # Serialize for storage
                    first_name,
                    last_name,
                ),
            )
            self.conn.commit()

            # Local file backup for faster access and redundancy
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

    # ========== User Registration Workflows ==========

    def register_user(self) -> None:
        """
        Complete interactive user registration workflow with voice authentication.

        Process includes:
        1. Collect user personal information
        2. Record voice statement with specific sentence
        3. Transcribe and validate speech accuracy
        4. Generate and store voice embedding
        5. Save all data to database and files

        Uses retry mechanism to handle transcription errors and ensure quality.
        """
        logger.info("🟡 Starting voice-driven user registration...")
        try:
            # ========== Personal Information Collection ==========
            first_name = input("🟡 Enter your first name: ").strip()
            if not first_name:
                raise Exception("First name cannot be empty.")

            last_name = input("🟡 Enter your last name: ").strip()
            if not last_name:
                raise Exception("Last name cannot be empty.")

            liu_id = input("🟡 Enter your LIU ID (e.g. abcxy123): ").strip()
            if not self._validate_liu_id(liu_id):
                raise Exception("Invalid LIU ID format.")

            # ========== Voice Recording and Transcription ==========
            # Record a voice statement for both embedding and verification
            statement_audio = os.path.join(
                self.temp_audio_path, f"{liu_id}_statement.wav"
            )

            # Retry loop for accurate transcription
            max_attempts = MAX_RETRIES
            for attempt in range(1, max_attempts + 1):
                self._record_audio(
                    statement_audio,
                    f"🟡 Please read the following sentence clearly: '{TRANSCRIPTION_SENTENCE}'",
                    duration=12,
                )

                # Transcribe and validate the recorded audio
                transcription = self._transcribe_audio(statement_audio)
                if not transcription:
                    logger.info("🔴 Audio Transcription failed. Trying again...")
                    continue

                # Compare transcription with expected sentence
                if self._normalize_text(transcription) == self._normalize_text(
                    TRANSCRIPTION_SENTENCE
                ):
                    break  # Transcription matches, proceed
                else:
                    logger.info(
                        f"🔴 Your transcription didn't match the expected sentence. Attempt {attempt}/{max_attempts}"
                    )
            else:
                # Max attempts reached without successful transcription
                raise Exception(
                    "🔴 Maximum attempts reached. Registration failed due to mismatched transcription."
                )

            # ========== Voice Embedding Generation and Storage ==========
            # Capture the voice embedding from the validated audio
            embedding = self._capture_voice_embedding(statement_audio)
            if not embedding:
                raise Exception("Failed to capture voice embedding.")

            # Save the voice embedding with user information
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logger.info(
                f"✅ Registration complete for {first_name} {last_name} (LIU ID: {liu_id})."
            )
        except Exception as e:
            logger.exception("🔴 Registration failed.")
            logger.info(f"🔴 Registration failed: {e}")

    def register_voice_for_user_from_file(
        self, first_name, last_name, liu_id, audio_path
    ):
        """
        Register voice embedding from a pre-recorded audio file.

        Alternative registration method that bypasses live recording,
        useful for batch processing or web interface uploads.

        Args:
            first_name (str): User's first name
            last_name (str): User's last name
            liu_id (str): User's LIU ID
            audio_path (str): Path to existing audio file

        Returns:
            bool: True if registration successful, False otherwise
        """
        try:
            # Validate input format before processing
            if not self._validate_liu_id(liu_id):
                logger.error("Invalid LIU ID format.")
                return False

            # Generate embedding from provided audio file
            embedding = self._capture_voice_embedding(str(audio_path))
            if not embedding:
                logger.error("Failed to capture voice embedding from file.")
                return False

            # Store embedding in database and local file system
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logger.info(f"✅ Voice embedding registered for {liu_id} from file.")
            return True
        except Exception as e:
            logger.error(f"🔴 Voice registration from file failed: {e}")
            return False

    # ========== Text Processing Utilities ==========

    def _normalize_text(self, text: str) -> str:
        """
        Normalize text for accurate transcription comparison.

        Removes punctuation, converts to lowercase, and normalizes whitespace
        for reliable text matching regardless of minor pronunciation differences.

        Args:
            text (str): Raw text to normalize

        Returns:
            str: Normalized text suitable for comparison
        """
        # Convert to lowercase, remove punctuation, join without spaces
        return "".join(
            text.lower().translate(str.maketrans("", "", string.punctuation)).split()
        )

    def register_voice_for_user(
        self, first_name: str, last_name: str, liu_id: str, duration: int = 8
    ) -> None:
        """
        Record and register voice for an existing user (programmatic interface).

        This method is designed for API/programmatic use where user details
        are already known, skipping interactive input collection.

        Args:
            first_name (str): User's first name
            last_name (str): User's last name
            liu_id (str): User's LIU ID
            duration (int): Recording duration in seconds (default: 8)

        Raises:
            Exception: If voice recording or registration fails
        """
        try:
            # ========== Audio Recording ==========
            # Construct file path for the voice recording
            voice_statement_audio = os.path.join(
                self.temp_audio_path, f"{liu_id}_voice.wav"
            )

            # Record voice sample with specified duration
            self._record_audio(
                voice_statement_audio,
                "Please speak a short voice statement for registration:",
                duration=duration,
                sampling_rate=16000,  # Standard rate for voice processing
            )

            # ========== Optional Transcription ==========
            # Transcribe audio for logging and verification purposes
            transcription = self._transcribe_audio(voice_statement_audio)
            logger.info("🟢 Voice transcription: %s", transcription)

            # ========== Embedding Generation and Storage ==========
            # Generate voice embedding from recorded audio
            embedding = self._capture_voice_embedding(voice_statement_audio)
            if not embedding:
                raise Exception("Failed to capture voice embedding.")

            # Update database and save local files
            self._save_voice_embedding(liu_id, embedding, first_name, last_name)
            logger.info("✅ Voice authentication register for: %s", liu_id)
        except Exception as e:
            logger.error("🔴 Voice registration for user failed: %s", e)
            raise

    # ========== Voice Verification System ==========

    def verify_user_by_voice(self, liu_id: str, audio_path: str) -> bool:
        """
        Authenticate user identity by comparing voice samples using cosine similarity.

        Loads stored voice embedding and compares it against a new recording
        using mathematical similarity measurement to determine if they match.

        Args:
            liu_id (str): User's unique LIU ID
            audio_path (str): Path to new voice sample for verification

        Returns:
            bool: True if voice matches stored embedding above threshold, False otherwise

        Raises:
            FileNotFoundError: If no stored voice data exists for the user
        """
        try:
            # ========== Load Stored Voice Data ==========
            # Locate stored voice embedding file
            stored_path = os.path.join(self.voice_data_path, f"{liu_id}_voice.pkl")
            if not os.path.exists(stored_path):
                raise FileNotFoundError(
                    f"🔴 No stored voice data found for LIU ID: {liu_id}"
                )

            # Load previously saved voice embedding
            with open(stored_path, "rb") as f:
                stored_embedding = pickle.load(f)

            # ========== Generate New Embedding ==========
            # Create embedding from new audio sample
            new_embedding = self._capture_voice_embedding(audio_path)

            # ========== Similarity Comparison ==========
            # Calculate cosine similarity between embeddings
            similarity = cosine_similarity([new_embedding], [stored_embedding])[0][0]
            logger.info(f"🟢 Voice similarity score: {similarity:.4f}")

            # Return True if similarity exceeds configured threshold
            return similarity >= VOICE_MATCH_THRESHOLD
        except Exception as e:
            logger.error(f"🔴 Voice verification failed: {e}")
            return False

    # ========== Resource Management ==========

    def close(self):
        """
        Clean up database resources and connections.

        Ensures proper cleanup of database cursor to prevent connection leaks.
        Should be called when VoiceAuth instance is no longer needed.
        """
        if self.cursor:
            self.cursor.close()

    # ========== Interactive User Workflows ==========

    def login_user(self) -> None:
        """
        Interactive user login workflow with voice verification.

        Process includes:
        1. Collect LIU ID from user input
        2. Record new voice sample
        3. Compare against stored voice embedding
        4. Report authentication success or failure
        """
        try:
            # ========== User Identification ==========
            liu_id = input("Enter your LIU ID: ").strip()
            if not self._validate_liu_id(liu_id):
                raise Exception("Invalid LIU ID format.")

            # ========== Voice Sample Recording ==========
            # Record fresh voice sample for verification
            login_audio = os.path.join(self.temp_audio_path, f"{liu_id}_login.wav")
            self._record_audio(
                login_audio,
                f"📣 Please read your verification sentence: {TRANSCRIPTION_SENTENCE}",
                duration=10,
            )

            # ========== Voice Verification ==========
            # Compare new sample against stored embedding
            if self.verify_user_by_voice(liu_id, login_audio):
                logger.info(f"✅ Verification successful for {liu_id}. Welcome back!")
            else:
                logger.info(
                    f"❌ Verification failed. The voice does not match our records."
                )
        except Exception as e:
            logger.exception("🔴 Login failed.")
            logger.error(f"🔴 Login failed: {e}")


# ========== Main Application Entry Point ==========

if __name__ == "__main__":
    """
    Interactive command-line interface for voice authentication system.

    Provides menu-driven access to:
    - User registration with voice enrollment
    - User login with voice verification
    """
    # Initialize voice authentication system
    auth = VoiceAuth(TEMP_AUDIO_PATH, VOICE_DATA_PATH)

    # Display user options
    print("Choose Action:")
    print("1. Register User")
    print("2. Login via Voice")

    choice = input("Enter 1 or 2: ").strip()

    # Execute selected operation
    if choice == "1":
        auth.register_user()  # Full registration workflow
    elif choice == "2":
        auth.login_user()  # Voice verification workflow
    else:
        print("Invalid choice.")

    # Clean up resources
    auth.close()

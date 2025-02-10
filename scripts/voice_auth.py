# # voice_auth.py

# import os
# import pickle
# import sqlite3
# import sys
# import warnings
# from pathlib import Path

# sys.path.append(str(Path(__file__).parent.parent))

# import sounddevice as sd
# from resemblyzer import VoiceEncoder, preprocess_wav
# from scipy.io.wavfile import write
# from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

# from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

# # Suppress warnings
# warnings.filterwarnings("ignore", category=FutureWarning)

# # Create Directories
# os.makedirs(VOICE_DATA_PATH, exist_ok=True)
# os.makedirs(TEMP_AUDIO_PATH, exist_ok=True)


# # Initialize Database
# def initialize_database(DB_PATH):
#     conn = sqlite3.connect(DB_PATH)
#     cursor = conn.cursor()
#     cursor.execute(
#         """
#         CREATE TABLE IF NOT EXISTS users (
#                     user_id INTEGER PRIMARY KEY,
#                     first_name TEXT NOT NULL,
#                     last_name TEXT NOT NULL,
#                     liu_id TEXT UNIQUE,
#                     email TEXT UNIQUE,
#                     preferences TEXT,
#                     profile_image_path TEXT,
#                     interaction_memory TEXT,
#                     face_encoding BLOB,
#                     voice_embedding BLOB,
#                     created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
#                     last_updated TIMESTAMP DEFAULT (datetime('now','localtime'))
#                 );
#     """
#     )
#     conn.commit()
#     return conn


# # Record Audio and Save to File
# def record_audio_to_file(filename, prompt, duration=5, sampling_rate=16000):
#     try:
#         print(prompt)
#         audio = sd.rec(
#             int(duration * sampling_rate),
#             samplerate=sampling_rate,
#             channels=1,
#             dtype="int16",
#         )
#         sd.wait()  # Wait until recording is finished
#         write(filename, sampling_rate, audio)
#         print(f"Audio saved to {filename}")
#     except Exception as e:
#         print(f"Error during audio recording: {e}")
#         raise


# # Transcribe Audio with SpeechRecognition
# def transcribe_audio_with_speechrecognition(filename):
#     recognizer = Recognizer()
#     try:
#         with AudioFile(filename) as source:
#             audio = recognizer.record(source)
#             text = recognizer.recognize_google(audio)
#             print(f"Transcription: {text}")
#             return text
#     except UnknownValueError:
#         print("Speech recognition could not understand the audio.")
#         return None
#     except RequestError as e:
#         print(f"Error with the Speech Recognition API: {e}")
#         return None


# # Voice Embedding Capture with Resemblyzer
# def capture_voice_embeddings(audio_path):
#     try:
#         encoder = VoiceEncoder()
#         wav = preprocess_wav(audio_path)
#         embedding = encoder.embed_utterance(wav)
#         print(f"Voice Embedding Captured: {embedding.shape}")
#         return embedding.tolist()
#     except Exception as e:
#         print(f"Error capturing voice embedding: {e}")
#         return None


# # Validate LIU ID
# def validate_liu_id(liu_id):
#     import re

#     pattern = r"^[a-z]{5}[0-9]{3}$"
#     return bool(re.match(pattern, liu_id))


# # Save Voice Embedding
# def save_voice_embedding(LIU_id, voice_embedding, conn):
#     cursor = conn.cursor()
#     voice_file = os.path.join(VOICE_DATA_PATH, f"{LIU_id}_voice.pkl")

#     cursor.execute(
#         """
#         UPDATE users SET voice_embedding = ? WHERE LIU_id = ?
#     """,
#         (pickle.dumps(voice_embedding), LIU_id),
#     )

#     if cursor.rowcount == 0:
#         cursor.execute(
#             """
#             INSERT INTO users (liu_id, voice_embedding) VALUES (?, ?)
#         """,
#             (LIU_id, pickle.dumps(voice_embedding)),
#         )

#     conn.commit()

#     with open(voice_file, "wb") as file:
#         pickle.dump(voice_embedding, file)
#     print(f"Voice embedding saved for LIU ID: {LIU_id}")


# # Main Function for Registration
# def voice_registration():
#     conn = initialize_database(DB_PATH)
#     print("Voice-driven registration started...")

#     try:
#         # Step 1: Input First Name
#         first_name = input("Type your first name: ").strip()
#         if not first_name:
#             raise ValueError("First name cannot be empty.")

#         # Step 2: Input Last Name
#         last_name = input("Type your last name: ").strip()
#         if not last_name:
#             raise ValueError("Last name cannot be empty.")

#         # Step 3: Input LIU ID
#         LIU_id = input("Type your LIU ID (e.g. abcde123): ").strip()
#         if not validate_liu_id(LIU_id):
#             raise ValueError(
#                 "Invalid LIU ID format. Please ensure it is in the right format."
#             )

#         # Step 4: Capture Voice Embeddings with Specific Statement
#         statement_audio = os.path.join(TEMP_AUDIO_PATH, f"{LIU_id}_statement.wav")
#         record_audio_to_file(
#             statement_audio,
#             "Please read this sentence clearly: 'Artificial intelligence enables machines to recognize patterns, process language, and make decisions, simulating human intelligence in innovative ways.'",
#             duration=12,
#         )

#         # Transcribe the audio using SpeechRecognition
#         sr_transcription = transcribe_audio_with_speechrecognition(statement_audio)

#         # Extract Voice Embedding
#         embeddings = capture_voice_embeddings(statement_audio)
#         if not embeddings:
#             raise ValueError("Failed to capture voice embeddings.")

#         # Step 5: Save to Database
#         save_voice_embedding(LIU_id, embeddings, conn)
#         print(
#             f"Registration complete for {first_name} {last_name} with LIU ID: {LIU_id}."
#         )
#     except Exception as e:
#         print(f"Error during registration: {e}")
#     finally:
#         conn.close()


# if __name__ == "__main__":
#     voice_registration()


# voice_auth.py

import os
import pickle
import re
import sqlite3
import sys
import warnings
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

import sounddevice as sd
from resemblyzer import VoiceEncoder, preprocess_wav
from scipy.io.wavfile import write
from speech_recognition import AudioFile, Recognizer, RequestError, UnknownValueError

from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

# Suppress warnings
warnings.filterwarnings("ignore", category=FutureWarning)


class VoiceAuth:
    def __init__(self, db_path, temp_audio_path, voice_data_path):
        """
        Initialize voice authentication system with configuration paths.

        Args:
            db_path: Path to SQLite database
            temp_audio_path: Temporary directory for audio recordings
            voice_data_path: Directory for storing voice embeddings
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

    def _initialize_database(self):
        """Initialize database with required tables."""
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
        conn.close()

    def _record_audio(self, filename, prompt, duration=5, sampling_rate=16000):
        """
        Record audio and save to file.

        Args:
            filename: Output filename
            prompt: Message to display to user
            duration: Recording duration in seconds
            sampling_rate: Audio sampling rate
        """
        try:
            print(prompt)
            audio = sd.rec(
                int(duration * sampling_rate),
                samplerate=sampling_rate,
                channels=1,
                dtype="int16",
            )
            sd.wait()
            write(filename, sampling_rate, audio)
            print(f"Audio saved to {filename}")
        except Exception as e:
            print(f"Error during audio recording: {e}")
            raise

    def _transcribe_audio(self, filename):
        """
        Transcribe audio using Google Speech Recognition.

        Args:
            filename: Path to audio file

        Returns:
            Transcribed text or None if failed
        """
        recognizer = Recognizer()
        try:
            with AudioFile(filename) as source:
                audio = recognizer.record(source)
                text = recognizer.recognize_google(audio)
                print(f"Transcription: {text}")
                return text
        except UnknownValueError:
            print("Speech recognition could not understand the audio.")
            return None
        except RequestError as e:
            print(f"Error with the Speech Recognition API: {e}")
            return None

    def _capture_voice_embedding(self, audio_path):
        """
        Create voice embedding from audio file.

        Args:
            audio_path: Path to audio file

        Returns:
            Voice embedding as list or None if failed
        """
        try:
            wav = preprocess_wav(audio_path)
            embedding = self.encoder.embed_utterance(wav)
            print(f"Voice Embedding Captured: {embedding.shape}")
            return embedding.tolist()
        except Exception as e:
            print(f"Error capturing voice embedding: {e}")
            return None

    @staticmethod
    def _validate_liu_id(liu_id):
        """
        Validate LIU ID format.

        Args:
            liu_id: ID to validate

        Returns:
            bool: True if valid format
        """
        pattern = r"^[a-z]{5}[0-9]{3}$"
        return bool(re.match(pattern, liu_id))

    def _save_voice_embedding(self, liu_id, voice_embedding):
        """
        Save voice embedding to database and file.

        Args:
            liu_id: User's LIU ID
            voice_embedding: Voice embedding to save
        """
        conn = sqlite3.connect(self.DB_PATH)
        cursor = conn.cursor()
        voice_file = os.path.join(self.VOICE_DATA_PATH, f"{liu_id}_voice.pkl")

        try:
            # Update existing user or insert new user
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

            # Save embedding to file
            with open(voice_file, "wb") as file:
                pickle.dump(voice_embedding, file)
            print(f"Voice embedding saved for LIU ID: {liu_id}")
        finally:
            conn.close()

    def register_user(self):
        """Main workflow for voice-driven user registration."""
        print("Voice-driven registration started...")

        try:
            # Collect user information
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
            statement_audio = os.path.join(
                self.TEMP_AUDIO_PATH, f"{liu_id}_statement.wav"
            )
            self._record_audio(
                statement_audio,
                "Please read this sentence clearly: 'Artificial intelligence enables machines to recognize patterns, process language, and make decisions, simulating human intelligence in innovative ways.'",
                duration=12,
            )

            # Verify transcription
            if not self._transcribe_audio(statement_audio):
                raise ValueError("Audio transcription failed.")

            # Create and save embedding
            embeddings = self._capture_voice_embedding(statement_audio)
            if not embeddings:
                raise ValueError("Failed to capture voice embeddings.")

            self._save_voice_embedding(liu_id, embeddings)
            print(
                f"Registration complete for {first_name} {last_name} with LIU ID: {liu_id}."
            )

        except Exception as e:
            print(f"Error during registration: {e}")


if __name__ == "__main__":
    # Example usage
    from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

    auth_system = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
    auth_system.register_user()

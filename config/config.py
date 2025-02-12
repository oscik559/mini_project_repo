# config.py

"""
Configuration module for the mini_project application.

This module defines various configuration settings required for the application,
including paths, thresholds, and validation patterns.
"""
import logging
import os
from pathlib import Path

# === Logging Setup ===
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Define the base directory
BASE_DIR = Path(__file__).resolve().parent.parent  # mini_project/ directory path
# DB_PATH = Path(r"\\ad.liu.se\coop\i\industrialrobotsetup\sequences.db")
DB_PATH = BASE_DIR / "database" / "sequences.db"

# Face recognition utilities
FACIAL_DATA_PATH = BASE_DIR / "utils" / "face_encodings"
FACE_CAPTURE_PATH = BASE_DIR / "utils" / "face_capture"

# Face recognition parameters
FACE_MATCH_THRESHOLD = 0.6  # Threshold for face matching
MAX_ENCODINGS_PER_USER = 5  # Maximum number of encodings per user
AUTO_CAPTURE_FRAME_COUNT = (
    5  # Number of consecutive frames with detected face for auto-capture
)

# Voice recognition parameters
VOICE_DATA_PATH = BASE_DIR / "utils" / "voice_embeddings"
VOICE_CAPTURE_PATH = BASE_DIR / "utils" / "voice_capture"

TEMP_AUDIO_PATH = BASE_DIR / "utils" / "temp_audio"

# Camera vision utilities
CAMERA_DATA_PATH = BASE_DIR / "utils" / "camera_data"

# Email and ID validation patterns
LIU_ID_PATTERN = r"^[a-z]{3,5}\d{3}$"  # Example: oscik559
EMAIL_PATTERN = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"

# === Voice Processing Configurations ===
VOICE_PROCESSING_CONFIG = {
    "recording": {
        "temp_audio_path": str(
            TEMP_AUDIO_PATH / "voice_recording.wav"
        ),  # Path to save recorded audio
        "sampling_rate": 16000,  # Audio sample rate (Hz)
        "max_duration": 60,  # Maximum recording duration (seconds)
        "initial_silence_duration": 15,  # Silence allowed before speech starts (seconds)
        "post_speech_silence_duration": 2,  # Silence allowed after speech ends (seconds)
        "calibration_duration": 2,  # Duration for ambient noise calibration (seconds)
        "amplitude_margin": 100,  # Margin above noise floor for speech detection
        "frame_duration": 0.03,  # Duration of each audio frame (seconds)
    },
    "whisper": {
        "model": "large-v3",  # Whisper model to use
        "device": "cuda",  # Device for Whisper (e.g., "cuda" or "cpu")
        "compute_type": "float16",  # Compute type for Whisper
    },
    "database": {
        "db_path": str(DB_PATH),  # Path to the SQLite database
    },
}


# Function to validate paths at runtime
def validate_paths() -> None:
    """
    Validates that all defined paths exist or can be created.
    Raises an exception if any path is invalid.
    """
    paths_to_check = [
        FACIAL_DATA_PATH,
        FACE_CAPTURE_PATH,
        VOICE_DATA_PATH,
        TEMP_AUDIO_PATH,
        CAMERA_DATA_PATH,
        DB_PATH.parent,
    ]

    for path in paths_to_check:
        if not path.exists():
            try:
                path.mkdir(parents=True, exist_ok=True)
                logger.info(f"Created missing directory: {path}")
                print(f"Created missing directory: {path}")
            except OSError as e:
                logger.error(f"Failed to create directory {path}: {e}", exc_info=True)
                raise RuntimeError(f"Failed to create directory {path}: {e}")


# Automatically validate paths when this module is imported
validate_paths()

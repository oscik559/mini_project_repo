# config/app_config.py

"""
Configuration module for the mini_project application.

This module defines various configuration settings required for the application,
including paths, thresholds, and validation patterns.

- for environment variables and the prompt template.
"""

import logging.config
import os
from pathlib import Path

import yaml

# Define the base directory
BASE_DIR = Path(__file__).resolve().parent.parent  # mini_project_repo/ directory path

# Use network share or local database file: be aware of potential issues with file locking on a network share.
# DB_PATH = Path(r"\\ad.liu.se\coop\i\industrialrobotsetup\sequences.db")
DB_PATH = BASE_DIR / "assets" / "db_data" / "sequences.db"

# Use postgreSQL database.
# DB_URL = "dbname=sequences_db user=oscar password=oscik559 host=localhost"
DB_URL = "postgresql://oscar:oscik559@localhost:5432/sequences_db"

DB_BACKUP_PATH = BASE_DIR / "assets" / "db_backups"
PROFILE_BACKUP_PATH = BASE_DIR / "assets" / "db_user_backups"

# Face recognition utilities
FACIAL_DATA_PATH = BASE_DIR / "assets" / "face_encodings"
FACE_CAPTURE_PATH = BASE_DIR / "assets" / "face_capture"
IDENTIFICATION_FRAMES = (
    2  # Constant to control how many frames are used for identification averaging.
)
TIMEDELAY = 1

# Face recognition parameters
FACE_MATCH_THRESHOLD = 0.6  # Threshold for face matching
MAX_ENCODINGS_PER_USER = 5  # Maximum number of encodings per user
AUTO_CAPTURE_FRAME_COUNT = (
    5  # Number of consecutive frames with detected face for auto-capture
)

# Voice recognition parameters
VOICE_DATA_PATH = BASE_DIR / "assets" / "voice_embeddings"
VOICE_CAPTURE_PATH = BASE_DIR / "assets" / "voice_capture"
TRANSCRIPTION_SENTENCE = "Artificial intelligence enables machines to recognize patterns, process language, and make decisions."
MAX_RETRIES = 3
VOICE_MATCH_THRESHOLD = 0.7  # Cosine similarity threshold for identification.

TEMP_AUDIO_PATH = BASE_DIR / "assets" / "temp_audio"

# Camera vision utilities
CAMERA_DATA_PATH = BASE_DIR / "assets" / "camera_data"


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
MAX_TRANSCRIPTION_RETRIES = 1
MIN_DURATION_SEC = 1.5
VOICE_TTS_SETTINGS = {
    "speed": 165,
    "use_gtts": True,
    "ping_sound_path": str(BASE_DIR / "assets" / "sound_effects" / "ping.wav"),
    "ding_sound_path": str(BASE_DIR / "assets" / "sound_effects" / "ding.wav"),
    "voice_index": 2,  # 0 = Hazel, 1 = David, 2 = Zira (example for Windows)
}


# === Gesture Recognition Settings ===
MIN_DETECTION_CONFIDENCE = 0.7
MIN_TRACKING_CONFIDENCE = 0.5
MAX_NUM_HANDS = 2
FRAME_SKIP = 2

# === synchronizer LLM Settings ===
BATCH_SIZE = int(os.getenv("BATCH_SIZE", 1000))
LLM_MAX_RETRIES = int(os.getenv("LLM_MAX_RETRIES", 3))
LLM_MODEL = os.getenv("LLM_MODEL", "mistral:latest")

UNIFY_PROMPT_TEMPLATE = (
    "Role: Command Unifier. Combine voice commands (primary) with gesture cues (supplementary).\n"
    "Rules:\n"
    "1. Preserve ALL details from the voice command.\n"
    "2. Integrate gestures ONLY if they add context (e.g., direction, emphasis).\n"
    "3. NEVER omit voice content unless the gesture explicitly contradicts it.\n"
    "4. Output format: Plain text, no markdown or JSON.\n\n"
    "Examples:\n"
    "- Voice: 'Turn right', Gesture: 'Pointing up' → 'Turn right upward'\n"
    "- Voice: 'Stop', Gesture: '' → 'Stop'\n\n"
    "Voice Instruction: {voice_text}\n"
    "Gesture Instruction: {gesture_text}\n"
    "Unified Command:"
)


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
            except OSError as e:
                logger.error(f"Failed to create directory {path}: {e}", exc_info=True)
                raise RuntimeError(f"Failed to create directory {path}: {e}")


def setup_logging(level: int = logging.INFO) -> None:
    logging.basicConfig(
        level=level,
        # format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        format="[%(levelname)s] %(name)s: %(message)s",
        # datefmt="%Y-%m-%d %H:%M:%S",
        datefmt="%H:%M:%S",
    )


def load_logging_config():
    config_path = Path(__file__).parent / "logging_config.yaml"
    if config_path.exists():
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)
        logging.config.dictConfig(config)
    else:
        setup_logging()


# Set up logging
load_logging_config()
logger = logging.getLogger("mini_project")

# Automatically validate paths when this module is imported
validate_paths()

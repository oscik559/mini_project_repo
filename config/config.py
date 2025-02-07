# config.py

import os
from pathlib import Path

# Define the base directory
BASE_DIR = Path(__file__).parent.parent # mini_project/ directory path
# DB_PATH = BASE_DIR / "database" / "sequences.db"
DB_PATH = r"\\ad.liu.se\coop\i\industrialrobotsetup" + "\\sequences.db"

# Face recognition utilities
FACIAL_DATA_PATH = BASE_DIR / "utils" / "face_encodings"
FACE_CAPTURE_PATH = BASE_DIR / "utils" / "face_capture"

# Face recognition parameters
FACE_MATCH_THRESHOLD = 0.6
MAX_ENCODINGS_PER_USER = 5
AUTO_CAPTURE_FRAME_COUNT = 5  # Number of consecutive frames with detected face for auto-capture

#Voice recognition parameters
VOICE_DATA_PATH = BASE_DIR / "utils" / "voice_embeddings"
TEMP_AUDIO_PATH = BASE_DIR / "utils" / "temp_audio"

# camera_vision utilities
CAMERA_DATA_PATH = BASE_DIR / "utils" / "camera_data"

# Email and ID validation patterns
LIU_ID_PATTERN = r"^[a-z]{3,5}\d{3}$"  # Example: oscik559
EMAIL_PATTERN = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
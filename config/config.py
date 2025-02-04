# config.py

import os
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
DB_PATH = BASE_DIR / "database" / "sequences.db"

FACIAL_DATA_PATH = BASE_DIR / "utils" / "facial_data"
FACE_CAPTURE_PATH = BASE_DIR / "utils" / "face_capture"

# Face recognition parameters
FACE_MATCH_THRESHOLD = 0.6
MAX_ENCODINGS_PER_USER = 5
AUTO_CAPTURE_FRAME_COUNT = 5  # Number of consecutive frames with detected face for auto-capture

# Email and ID validation patterns
LIU_ID_PATTERN = r"^[a-z]{3,5}\d{3}$"  # Example: oscik559
EMAIL_PATTERN = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
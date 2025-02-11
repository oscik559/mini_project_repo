
# scripts/user_authentication.py
#!/usr/bin/env python
"""
User Authentication Module

This module provides a unified interface for both face authentication
and voice authentication. It allows the operator to choose the
authentication method and then calls the corresponding module.

It leverages:
- The face_auth system (from scripts/face_auth.py)
- The voice_auth system (from scripts/voice_auth.py)
- The shared database handler from db_handler.py
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

import logging
from config.logging_config import setup_logging
setup_logging()  # You can pass a different level if needed

# Import the authentication modules.
from scripts.face_auth import FaceAuthSystem
from scripts.voice_auth import VoiceAuth

def main() -> None:
    print("User Authentication System")
    print("==========================")
    print("Choose an authentication method:")
    print("1. Face Authentication")
    print("2. Voice Authentication")

    choice = input("Enter your choice (1 or 2): ").strip()

    if choice == "1":
        print("Launching Face Authentication...")
        face_auth = FaceAuthSystem()
        # For example, you might call face_auth.register_user() or face_auth.identify()
        face_auth.register_user()  # or face_auth.identify() depending on your use case
    elif choice == "2":
        print("Launching Voice Authentication...")
        from config.config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH
        voice_auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        voice_auth.register_user()
    else:
        print("Invalid choice. Exiting.")

if __name__ == "__main__":
    main()

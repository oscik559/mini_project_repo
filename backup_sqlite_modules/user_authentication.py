# authentication/user_authentication.py

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
import logging

from config.app_config import *

setup_logging()  # You can pass a different level if needed

# Import the authentication modules.
from mini_project.authentication.face_auth_SQLite import FaceAuthSystem
from mini_project.authentication.voice_auth_SQLite import VoiceAuth


def main() -> None:
    print("User Authentication System")
    print("==========================")
    print("Choose an authentication method:")
    print("1. Face Authentication")
    print("2. Voice Authentication")

    choice = input("Enter your choice (1 or 2): ").strip()

    if choice == "1":
        print("Launching Face Authentication...")

        FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
        FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)
        face_auth = FaceAuthSystem()
        face_auth.run()

    elif choice == "2":
        print("Launching Voice Authentication...")

        voice_auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        voice_auth.register_user()
    else:
        print("Invalid choice. Exiting.")


if __name__ == "__main__":
    main()

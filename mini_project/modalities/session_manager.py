# modalities/session_manager.py
"""Module: session_manager
This module defines the `SessionManager` class, which is responsible for managing user authentication
and session lifecycle in the mini_project application. It integrates face and voice authentication
systems to authenticate users and manage their sessions.
Classes:
    - SessionManager: Handles user authentication, session creation, cancellation, and retry logic.
Dependencies:
    - logging: For logging session and authentication events.
    - uuid: For generating unique session IDs.
    - config.app_config: Provides configuration constants such as database and file paths.
    - mini_project.authentication._face_auth.FaceAuthSystem: For face authentication and registration.
    - mini_project.authentication._voice_auth.VoiceAuth: For voice authentication and registration.
Usage:
    The `SessionManager` class is instantiated with optional face and voice authentication modules.
    It provides methods to authenticate users, create sessions, cancel sessions, and retry sessions.

"""


import logging
import uuid

from mini_project.config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH
from mini_project.authentication._face_auth import FaceAuthSystem
from mini_project.authentication._voice_auth import VoiceAuth

logger = logging.getLogger("SessionManager")


class SessionManager:
    def __init__(self, face_auth: FaceAuthSystem = None, voice_auth: VoiceAuth = None):

        # Instantiate authentication modules if not provided.
        self.face_auth = face_auth if face_auth else FaceAuthSystem()
        self.voice_auth = voice_auth if voice_auth else VoiceAuth()
        self.session_id = None
        self.authenticated_user = (
            None  # Expected dict, keys: 'liu_id', 'first_name', 'last_name', etc.
        )
        self.running = False

    def authenticate_user(self):
        """
        Attempt face authentication. If the face is not recognized, trigger manual registration.
        Following successful face registration, trigger voice registration.
        """
        logger.info("🟡 Attempting face authentication...")
        user = self.face_auth.identify_user()

        # if user:
        #     self.authenticated_user = user
        #     logger.info(
        #         f"✅ Successful face authentication. Welcome {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
        #     )
        if not user:
            logger.warning(
                "🔴 Face not recognized. Initiating manual face registration..."
            )
            # Attempt to register the user
            registered = self.face_auth.register_user()
            if not registered:
                logger.warning("🚫 User declined registration. Session halted.")
                return None

            self.face_auth._refresh_index()
            user = self.face_auth.identify_user()
            if not user:
                logger.error("❌ User authentication failed after registration.")
                return None

        self.authenticated_user = user  # ✅ Set it in both branches
        logger.info(
            f"✅ Successful face authentication. Welcome {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
        )
        # ✅ ALWAYS run voice registration check here
        logger.info(f"🟡 Initiating voice check...")
        embedding = self.authenticated_user.get("voice_embedding")
        logger.info(f"🟡 Checking for existing voice embedding...")

        if not embedding or len(embedding) == 0:
            logger.info(f"🟢 No voice embedding found for user...")
            confirm = (
                input("🎤 Would you like to register your voice now? (y/n): ")
                .strip()
                .lower()
            )
            if confirm == "y":
                try:
                    self.voice_auth.register_voice_for_user(
                        first_name=self.authenticated_user["first_name"],
                        last_name=self.authenticated_user["last_name"],
                        liu_id=self.authenticated_user["liu_id"],
                    )
                    logger.info("✅ Voice registration completed successfully.")
                except Exception as e:
                    logger.error(f"❌ Voice registration failed: {str(e)}")
            else:
                logger.info("🟡 Voice registration skipped by user request.")
        else:
            logger.info(
                "✅ Voice embedding already exists. Skipping voice registration."
            )
        return self.authenticated_user

    def create_session(self):
        """
        Create a new session by generating a unique session ID and setting the running flag.
        """
        self.session_id = str(uuid.uuid4())
        self.running = True
        logger.info(f"✅ New session created with ID: {self.session_id}")
        return self.session_id

    def cancel_session(self):
        """
        Cancel the current session.
        """
        if self.running:
            logger.info(f"🟡 Cancelling session: {self.session_id}")
            self.running = False
        else:
            logger.info("🔴 No active session to cancel.")

    def retry_session(self):
        """
        Cancel the current session and create a new session.
        """
        self.cancel_session()
        return self.create_session()

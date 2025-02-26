# workflow/session_manager.py

import uuid
import logging
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

logger = logging.getLogger("SessionManager")


class SessionManager:
    def __init__(self, face_auth: FaceAuthSystem = None, voice_auth: VoiceAuth = None):
        # Instantiate authentication modules if not provided.
        self.face_auth = face_auth if face_auth else FaceAuthSystem()
        self.voice_auth = (
            voice_auth
            if voice_auth
            else VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        )
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
        logger.info("Attempting face authentication...")
        user = self.face_auth.identify_user()
        if user:
            self.authenticated_user = user
            logger.info(
                f"Authenticated Face. Welcome {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
            )
        else:
            logger.warning(
                "Face not recognized. Initiating manual face registration..."
            )
            self.face_auth.register_user()

            # Retry identification after registration
            user = self.face_auth.identify_user()
            if user:
                self.authenticated_user = user
                logger.info(
                    f"Authenticated after registration. Welcome {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
                )
                # Trigger voice registration (this method should exist in VoiceAuth)
                try:
                    logger.info(f"Initiating voice registration...")
                    self.voice_auth.register_voice_for_user(
                        first_name=user.get("first_name"),
                        last_name=user.get("last_name"),
                        liu_id=user.get("liu_id"),
                    )
                    logger.info("Voice registration completed successfully.")
                except Exception as e:
                    logger.error(f"Voice registration failed: {str(e)}")
            else:
                logger.error("User authentication failed after registration.")
                return None
        return self.authenticated_user

    def create_session(self):
        """
        Create a new session by generating a unique session ID and setting the running flag.
        """
        self.session_id = str(uuid.uuid4())
        self.running = True
        logger.info(f"New session created with ID: {self.session_id}")
        return self.session_id

    def cancel_session(self):
        """
        Cancel the current session.
        """
        if self.running:
            logger.info(f"Cancelling session: {self.session_id}")
            self.running = False
        else:
            logger.info("No active session to cancel.")

    def retry_session(self):
        """
        Cancel the current session and create a new session.
        """
        self.cancel_session()
        return self.create_session()

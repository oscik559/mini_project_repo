# modalities/orchestrator.py

import logging
import threading
import uuid

from config.app_config import *
from mini_project.modalities.gesture_processor import GestureDetector
from mini_project.modalities.voice_processor import VoiceProcessor
from mini_project.modalities.synchronizer import synchronize_and_unify

# from mini_project.authentication.voice_auth import VoiceAuth
# from mini_project.authentication.face_auth import FaceAuthSystem
# from mini_project.authentication.user_authentication import main


# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("Orchestrator")


# Global event to signal end of session capture
SESSION_END_EVENT = threading.Event()


def run_voice_capture(session_id: str):
    vp = VoiceProcessor(session_id=session_id)
    vp.capture_voice()
    logger.info("Voice capture completed.")
    # Signal that voice capture is complete; gesture capture should stop.
    SESSION_END_EVENT.set()


def run_gesture_capture(session_id: str):
    gd = GestureDetector(session_id=session_id)
    # Pass termination event so gesture capture can close gracefully.
    gd.process_video_stream(termination_event=SESSION_END_EVENT)
    logger.info("Gesture capture completed.")


# def authenticate_user() -> str:
#     """
#     Runs the authentication process (face and/or voice) and returns the authenticated LIU ID.
#     If authentication fails, this function can prompt the user to register.
#     """
#     # Pseudocode for authentication process:
#     liu_id = None
#     # Try face authentication first.
#     liu_id = FaceAuthSystem().identify_user  # Suppose this returns a LIU ID or None
#     if not liu_id:
#         # Fallback to voice authentication:
#         liu_id = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH).register_user()
#     if not liu_id:
#         raise Exception("User could not be authenticated.")
#     return liu_id


if __name__ == "__main__":
    session_id = str(uuid.uuid4())
    # authenticate_user()
    logger.info(f"Starting session with session_id: {session_id}")

    voice_thread = threading.Thread(target=run_voice_capture, args=(session_id,))
    gesture_thread = threading.Thread(target=run_gesture_capture, args=(session_id,))

    voice_thread.start()
    gesture_thread.start()

    voice_thread.join()
    gesture_thread.join()

    logger.info("Session capture ended. Now running synchronizer/unifier...")

    synchronize_and_unify(db_path=DB_PATH)
    logger.info(
        "Unification complete. Check the unified_instructions table in sequences.db."
    )

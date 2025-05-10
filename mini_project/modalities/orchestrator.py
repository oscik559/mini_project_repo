# mini_project/modalities/orchestrator.py


import logging
import threading
import uuid

from config.app_config import *

from mini_project.modalities.gesture_processor import GestureDetector
from mini_project.modalities.synchronizer import synchronize_and_unify
from mini_project.modalities.voice_processor import VoiceProcessor

# Initialize logging
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


if __name__ == "__main__":
    session_id = str(uuid.uuid4())
    logger.info(f"Starting session with session_id: {session_id}")

    voice_thread = threading.Thread(target=run_voice_capture, args=(session_id,))
    gesture_thread = threading.Thread(target=run_gesture_capture, args=(session_id,))

    voice_thread.start()
    gesture_thread.start()

    voice_thread.join()
    gesture_thread.join()

    logger.info("Session capture ended. Now running synchronizer/unifier...")

    try:
        synchronize_and_unify(liu_id=None)
        logger.info("Unification complete. Check the unified_instructions table.")
    except Exception as e:
        logger.error(f"Synchronization failed: {e}")
        logger.debug("Exception details:", exc_info=True)

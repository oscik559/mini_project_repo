# mini_project/modalities/orchestrator.py
"""
Orchestrator module for multimodal session capture and synchronization.
This module coordinates the capture of voice and gesture data streams in parallel threads,
and then synchronizes and unifies the captured data at the end of the session.
Functions:
    run_voice_capture(session_id: str):
        Captures voice input for a given session using the VoiceProcessor.
        Signals the end of session capture upon completion.
    run_gesture_capture(session_id: str):
        Captures gesture input for a given session using the GestureDetector.
        Listens for a termination event to end capture gracefully.
Execution:
    When run as a script, generates a unique session ID, starts both voice and gesture
    capture threads, waits for their completion, and then runs the synchronizer/unifier
    to process and unify the captured data.
Logging:
    Uses the configured logging setup to record progress and errors throughout the session.
Dependencies:
    - config.app_config (for logging setup)
    - mini_project.modalities.gesture_processor.GestureDetector
    - mini_project.modalities.synchronizer.synchronize_and_unify
    - mini_project.modalities.voice_processor.VoiceProcessor
"""


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

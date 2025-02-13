import logging
import threading
import time

# from mini_project.modalities.cmd_synchronizer import (  # The synchronizer code provided earlier
#     synchronize_and_merge,
# )

from mini_project.modalities.test_script import (  # The synchronizer code provided earlier
    synchronize_and_merge,
)

from mini_project.modalities.gesture_processor import (  # Assumes your gesture script is in gesture_detector.py
    GestureDetector,
)

from mini_project.modalities.voice_processor import (  # Assumes your voice script is in voice_processor.py
    VoiceProcessor,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)


def run_voice_capture():
    """Run voice capture during the session."""
    vp = VoiceProcessor()
    vp.capture_voice()
    logging.info("Voice capture completed.")


def run_gesture_capture():
    """Run gesture capture during the session."""
    gd = GestureDetector()
    gd.process_video_stream()
    logging.info("Gesture capture completed.")


if __name__ == "__main__":
    # Start voice and gesture capture concurrently in separate threads
    voice_thread = threading.Thread(target=run_voice_capture)
    gesture_thread = threading.Thread(target=run_gesture_capture)

    logging.info("Starting session: capturing voice and gesture concurrently...")
    voice_thread.start()
    gesture_thread.start()

    # Wait for both capture threads to complete
    voice_thread.join()
    gesture_thread.join()

    logging.info("Session ended. Now synchronizing and merging commands...")

    # Run the synchronizer to merge voice and gesture commands using the LLM unification function
    synchronize_and_merge(voice_db="sequences.db", gesture_db="commands.db")

    logging.info(
        "Unification complete. Check your unified_commands table in commands.db."
    )

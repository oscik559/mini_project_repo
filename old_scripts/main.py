# main.py
import logging
import threading

from old_scripts.command_unifier import CommandUnifier
from old_scripts.gesture_processor_copy import GestureDetector
from old_scripts.voice_processor_copy import VoiceProcessor

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)


def run_session():
    # Initialize components
    unifier = CommandUnifier()

    # Create processors with unifier reference
    gesture_detector = GestureDetector(unifier)
    voice_processor = VoiceProcessor(unifier)

    # Start real-time processing thread
    real_time_thread = threading.Thread(target=unifier.process_real_time_commands)
    real_time_thread.daemon = True

    # Start capture threads
    gesture_thread = threading.Thread(target=gesture_detector.process_video_stream)
    voice_thread = threading.Thread(target=voice_processor.capture_voice)

    try:
        logging.info("Starting hybrid session...")
        real_time_thread.start()
        gesture_thread.start()
        voice_thread.start()

        # Wait for capture threads to complete
        gesture_thread.join()
        voice_thread.join()

        logging.info("Session ended. Starting post-processing...")
        unifier.post_process_unification()
        logging.info("Hybrid processing complete!")

    except KeyboardInterrupt:
        logging.info("Session interrupted by user")


if __name__ == "__main__":
    run_session()

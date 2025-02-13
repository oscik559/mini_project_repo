# main.py
from gesture_processor import GestureDetector
from speech_processor import SpeechTranscriber
from llm_processor import CommandUnifier
from database import CommandDatabase

# Initialize modules
gesture_detector = GestureDetector()
speech_transcriber = SpeechTranscriber()
command_db = CommandDatabase("commands.db")
llm_unifier = CommandUnifier()

# Real-time loop
cap = cv2.VideoCapture(0)
while True:
    # Capture frame
    ret, frame = cap.read()

    # Detect gesture (non-blocking)
    gesture, gesture_time = gesture_detector.detect_gesture(frame)

    # Transcribe speech (async)
    speech_text, speech_time = speech_transcriber.transcribe("audio.wav")

    # Sync and merge
    if abs(gesture_time - speech_time) < 2.0:
        structured_cmd = llm_unifier.unify_commands(speech_text, gesture)
        command_db.log_command(speech_text, gesture, structured_cmd)
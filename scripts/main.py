# main.py
from old_scripts.voice_processor import VoiceProcessor

if __name__ == "__main__":
    processor = VoiceProcessor()
    processor.capture_voice()
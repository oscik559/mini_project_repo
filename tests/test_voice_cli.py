# How to Use It
"""
# 1. Capture full pipeline
python test_voice_cli.py --mode capture

# 2. Record voice only (no transcription/storage)
python test_voice_cli.py --mode record

# 3. Transcribe existing audio file
python test_voice_cli.py --mode transcribe --audio path/to/audio.wav

# 4. Test text-to-speech
python test_voice_cli.py --mode tts --text "Hello robot"
"""

import argparse
import os

from mini_project.modalities.voice_processor_pgSQL import (
    AudioRecorder,
    SpeechSynthesizer,
    Transcriber,
    VoiceProcessor,
)


def run_capture_voice():
    vp = VoiceProcessor()
    vp.capture_voice()


def run_transcribe_file(audio_path):
    t = Transcriber()
    text, lang = t.transcribe_audio(audio_path)
    print(f"Transcribed: {text}")
    print(f"Language: {lang}")


def run_record_only():
    recorder = AudioRecorder()
    recorder.record_audio()
    print(f"Recording complete: {recorder.temp_audio_path}")


def run_tts(text):
    synth = SpeechSynthesizer()
    synth.speak(text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test voice processing components.")
    parser.add_argument(
        "--mode",
        choices=["capture", "transcribe", "record", "tts"],
        required=True,
        help="Component to test",
    )
    parser.add_argument("--audio", help="Path to audio file for transcription")
    parser.add_argument("--text", help="Text to synthesize")

    args = parser.parse_args()

    if args.mode == "capture":
        run_capture_voice()
    elif args.mode == "transcribe":
        if not args.audio:
            raise ValueError("You must specify --audio for transcription mode.")
        run_transcribe_file(args.audio)
    elif args.mode == "record":
        run_record_only()
    elif args.mode == "tts":
        if not args.text:
            raise ValueError("You must specify --text for tts mode.")
        run_tts(args.text)

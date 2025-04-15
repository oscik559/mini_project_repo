import pvporcupine
import sounddevice as sd
import struct
from mini_project.modalities.FOR_SHAPES.voice_processor_pgSQL import (
    VoiceProcessor,
    SpeechSynthesizer,
)
from LLM_main_copy import voice_to_scene_response, setup_logging

pv_access_key = "E0O2AD01eT6cJ83n1yYf5bekfdIOEGUky9q6APkwdx9enDaMLZQtLw=="
# Wake word: "jarvis" (or "computer", "picovoice", etc.)
porcupine = pvporcupine.create(access_key=pv_access_key, keywords=["jarvis"])
vp = VoiceProcessor()
tts = SpeechSynthesizer()



def audio_callback(indata, frames, time, status):
    try:
        pcm = struct.unpack_from("h" * porcupine.frame_length, bytes(indata))
        keyword_index = porcupine.process(pcm)
        if keyword_index >= 0:
            print("🟢 Wake word detected!")

            # Stop the wake word stream first
            raise KeyboardInterrupt  # quick trick to break the stream context

    except Exception as e:
        print(f"Callback error: {e}")


def start_listener():
    setup_logging()
    try:
        with sd.RawInputStream(
            samplerate=porcupine.sample_rate,
            blocksize=porcupine.frame_length,
            dtype="int16",
            channels=1,
            callback=audio_callback,
        ):
            print("🎙️ Listening for wake word...")
            while True:
                pass
    except KeyboardInterrupt:
        # Wake word was detected — run the assistant now
        print("🎤 Switching to command capture mode...")
        tts.speak("Yes?")
        voice_to_scene_response(vp, tts)
        print("✅ Done listening. Restarting listener...\n")
        start_listener()  # loop back into passive listening


if __name__ == "__main__":
    start_listener()

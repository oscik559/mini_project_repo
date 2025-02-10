# scripts/voice_processor.py

import sys
from pathlib import Path

# Add the project root directory to the Python path
sys.path.append(str(Path(__file__).parent.parent))

import logging
import os
import sqlite3
import time

import numpy as np
import sounddevice as sd
import webrtcvad
from faster_whisper import WhisperModel
from scipy.io.wavfile import write

# Import configurations from config.py
from config.config import VOICE_PROCESSING_CONFIG

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("voice_processor")

# Decoupled AudioRecorder class
class AudioRecorder:
    def __init__(self):
        self.config = VOICE_PROCESSING_CONFIG["recording"]
        self.temp_audio_path = self.config["temp_audio_path"]
        self.sampling_rate = self.config["sampling_rate"]
        self.vad = webrtcvad.Vad()
        self.vad.set_mode(3)  # Aggressive mode to filter out background noise

    def calibrate_noise(self):
        """Calibrates ambient noise and calculates the noise floor."""
        logger.info("Calibrating ambient noise...")
        noise_rms_values = []
        stream = sd.InputStream(samplerate=self.sampling_rate, channels=1, dtype="int16")
        end_time = time.time() + self.config["calibration_duration"]

        with stream:
            while time.time() < end_time:
                frame, _ = stream.read(int(self.sampling_rate * self.config["frame_duration"]))
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                noise_rms_values.append(rms)

        noise_floor = np.mean(noise_rms_values)
        logger.info(f"Ambient noise calibration complete. Noise floor: {noise_floor:.2f}")
        return noise_floor

    def record_audio(self):
        """
        Records audio from the user and saves it to a WAV file.
        Stops recording if:
          - No speech is detected for `initial_silence_duration` seconds (before any speech), or
          - After speech is detected, silence lasts for `post_speech_silence_duration` seconds.
        """
        # Step 1: Calibrate ambient noise
        noise_floor = self.calibrate_noise()
        amplitude_threshold = noise_floor + self.config["amplitude_margin"]
        logger.info(
            f"Amplitude threshold set to: {amplitude_threshold:.2f} "
            f"(Noise floor: {noise_floor:.2f} + Margin: {self.config['amplitude_margin']})"
        )

        logger.info("Voice recording: Please speak now...")

        audio = []
        start_time = time.time()
        silence_start = None
        speech_detected = False

        stream = sd.InputStream(samplerate=self.sampling_rate, channels=1, dtype="int16")
        with stream:
            while True:
                frame, _ = stream.read(int(self.sampling_rate * self.config["frame_duration"]))
                audio.append(frame)

                # Use VAD and amplitude threshold to detect speech
                is_speech_vad = self.vad.is_speech(frame.tobytes(), self.sampling_rate)
                rms = np.sqrt(np.mean(frame.astype(np.float32) ** 2))
                is_speech_amplitude = rms > amplitude_threshold

                if is_speech_vad and is_speech_amplitude:
                    speech_detected = True
                    silence_start = None  # Reset silence timer
                else:
                    if silence_start is None:
                        silence_start = time.time()
                    else:
                        threshold = (
                            self.config["post_speech_silence_duration"] if speech_detected else self.config["initial_silence_duration"]
                        )
                        if time.time() - silence_start > threshold:
                            break

                if time.time() - start_time > self.config["max_duration"]:
                    break

        audio = np.concatenate(audio, axis=0)

        # Save the recorded audio to a WAV file
        try:
            write(self.temp_audio_path, self.sampling_rate, audio)
            logger.info(f"Audio saved to {self.temp_audio_path}")
        except Exception as e:
            logger.error(f"Error saving audio: {e}")
            raise

# Decoupled Transcriber class
class Transcriber:
    def __init__(self):
        self.config = VOICE_PROCESSING_CONFIG["whisper"]
        self.model = WhisperModel(
            self.config["model"],
            device=self.config["device"],
            compute_type=self.config["compute_type"],
        )

    def transcribe_audio(self, audio_path):
        """Transcribes audio using Whisper."""
        try:
            segments, info = self.model.transcribe(audio_path)
            original_text = " ".join([segment.text for segment in segments])
            detected_language = info.language
            return original_text, detected_language
        except Exception as e:
            logger.error(f"Error during transcription: {e}")
            raise

# Decoupled Storage class
class Storage:
    def __init__(self):
        self.config = VOICE_PROCESSING_CONFIG["database"]
        self.db_path = self.config["db_path"]
        self.check_database()

    def check_database(self):
        """Ensure database file exists."""
        if not os.path.exists(self.db_path):
            open(self.db_path, "w").close()
            logger.info(f"Created database file: {self.db_path}")

    def store_instruction(self, modality, detected_language, content):
        """Stores transcribed instruction in the database."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    INSERT INTO instructions (modality, language, instruction_type, content)
                    VALUES (?, ?, ?, ?)
                    """,
                    (modality, detected_language, "voice command", content),
                )
                conn.commit()
                logger.info("Instruction stored successfully.")
        except Exception as e:
            logger.error(f"Error storing instruction: {e}")
            raise

# VoiceProcessor class to orchestrate the components
class VoiceProcessor:
    def __init__(self):
        self.recorder = AudioRecorder()
        self.transcriber = Transcriber()
        self.storage = Storage()

    def capture_voice(self):
        """Captures voice, transcribes it, and stores the result."""
        try:
            self.recorder.record_audio()
            text, language = self.transcriber.transcribe_audio(self.recorder.config["temp_audio_path"])
            self.storage.store_instruction("voice", language, text)
            logger.info("Voice instruction captured and stored successfully!")
        except Exception as e:
            logger.error(f"Error in voice capture process: {e}")

if __name__ == "__main__":
    processor = VoiceProcessor()
    processor.capture_voice()
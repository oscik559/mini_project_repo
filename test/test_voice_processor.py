import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

import numpy as np

# Add the project root directory to the Python path
sys.path.append(str(Path(__file__).parent.parent))

# Import the module(s) to test
from mini_project.voice_processor import (
    AudioRecorder,
    Storage,
    Transcriber,
    VoiceProcessor,
)


class TestAudioRecorder(unittest.TestCase):
    @patch("scripts.voice_processor.sd.InputStream")
    def test_record_audio(self, mock_input_stream):
        # Create a fake stream that simulates reading frames.
        fake_stream = MagicMock()
        # Simulate a 30ms frame: 16000 samples/sec * 0.03 sec = 480 samples.
        mock_frame = np.zeros((int(16000 * 0.03),), dtype=np.int16)
        # Always return (mock_frame, None) when read() is called.
        fake_stream.read.return_value = (mock_frame, None)
        # When the context manager is entered, use our fake stream.
        mock_input_stream.return_value.__enter__.return_value = fake_stream

        recorder = AudioRecorder()
        # Override configuration parameters for testing purposes.
        recorder.config["max_duration"] = 1  # Terminate quickly.
        recorder.config["frame_duration"] = 0.03
        recorder.config["initial_silence_duration"] = 0.1
        recorder.config["post_speech_silence_duration"] = 0.1
        recorder.config["amplitude_margin"] = 0  # So threshold equals the noise floor.

        # Patch calibrate_noise to immediately return 0 (simulate a noise floor of 0).
        with patch.object(
            recorder, "calibrate_noise", return_value=0
        ) as mock_calibrate:
            recorder.record_audio()
            # Verify that the fake stream's read method was called.
            self.assertTrue(fake_stream.read.called)
            # Verify that calibrate_noise was called exactly once.
            mock_calibrate.assert_called_once()


class TestTranscriber(unittest.TestCase):
    def test_transcribe_audio_real_file(self):
        transcriber = Transcriber()
        # Define the path to the real test audio file.
        audio_path = str(Path(__file__).parent / "test.wav")
        # Verify that the file exists.
        self.assertTrue(os.path.exists(audio_path), "test.wav file does not exist")
        # Call transcribe_audio on the real file.
        text, language = transcriber.transcribe_audio(audio_path)
        # Log the output for debugging (optional)
        print(f"Transcribed text: {text}")
        print(f"Detected language: {language}")
        # Assert that the detected language is 'en'
        self.assertEqual(language, "en")
        # Assert that the transcription text is not empty.
        self.assertTrue(len(text.strip()) > 0, "Transcription text should not be empty")
        # If you expect a specific transcription, update the following assertion:
        # self.assertEqual(text.strip(), "expected transcription text")


class TestStorage(unittest.TestCase):
    @patch("scripts.voice_processor.sqlite3.connect")
    def test_store_instruction(self, mock_sqlite_connect):
        storage = Storage()
        # Create mock connection and cursor objects.
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        # Setup the context manager so that sqlite3.connect returns our mock connection.
        mock_sqlite_connect.return_value.__enter__.return_value = mock_conn
        mock_conn.cursor.return_value = mock_cursor

        storage.store_instruction("voice", "en", "Test content")
        # Verify that the SQL execute method was called.
        self.assertTrue(mock_cursor.execute.called)


class TestVoiceProcessor(unittest.TestCase):
    @patch("scripts.voice_processor.Storage")
    @patch("scripts.voice_processor.Transcriber")
    @patch("scripts.voice_processor.AudioRecorder")
    def test_capture_voice(
        self, mock_audio_recorder_class, mock_transcriber_class, mock_storage_class
    ):
        # Create instance mocks for each component.
        mock_audio_recorder = MagicMock()
        mock_transcriber = MagicMock()
        mock_storage = MagicMock()

        # Configure the behavior of the mocked methods.
        mock_audio_recorder.record_audio.return_value = None
        # When transcribe_audio is called, return dummy text and language.
        mock_transcriber.transcribe_audio.return_value = ("test", "en")
        mock_storage.store_instruction.return_value = None

        # Ensure that when VoiceProcessor instantiates its components, our mocks are returned.
        mock_audio_recorder_class.return_value = mock_audio_recorder
        mock_transcriber_class.return_value = mock_transcriber
        mock_storage_class.return_value = mock_storage

        processor = VoiceProcessor()
        processor.capture_voice()

        # Verify that each component's method was called as expected.
        mock_audio_recorder.record_audio.assert_called_once()
        mock_transcriber.transcribe_audio.assert_called_once_with(
            mock_audio_recorder.config["temp_audio_path"]
        )
        mock_storage.store_instruction.assert_called_once_with("voice", "en", "test")


if __name__ == "__main__":
    unittest.main()

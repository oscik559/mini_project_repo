import os
import sqlite3
import pytest
from mini_project.voice_auth import VoiceAuth

def test_validate_liu_id():
    auth = VoiceAuth("test.db", "utils/temp_audio", "utils/voice_embeddings")
    assert auth._validate_liu_id("abcde123") is True
    assert auth._validate_liu_id("invalidID") is False

def test_database_initialization(tmp_path):
    db_path = str(tmp_path / "test.db")
    auth = VoiceAuth(db_path, str(tmp_path / "temp_audio"), str(tmp_path / "voice_embeddings"))
    # Verify that the database file exists and the users table was created.
    assert os.path.exists(db_path)
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
        table = cursor.fetchone()
    assert table is not None

def test_transcription_failure(tmp_path):
    # Create an invalid audio file to trigger a transcription error.
    dummy_audio = tmp_path / "dummy.wav"
    dummy_audio.write_bytes(b"invalid audio data")
    auth = VoiceAuth("test.db", str(tmp_path / "temp_audio"), str(tmp_path / "voice_embeddings"))
    with pytest.raises(Exception, match="Audio transcription failed"):
        auth._transcribe_audio(str(dummy_audio))

from unittest.mock import patch

import pytest

from mini_project.modalities.voice_processor_pgSQL import (
    SpeechSynthesizer,
    Storage,
    VoiceProcessor,
)


def test_singleton_synthesizer():
    s1 = SpeechSynthesizer()
    s2 = SpeechSynthesizer()
    assert s1 is s2, "SpeechSynthesizer is not a singleton"


def test_voice_processor_init():
    vp = VoiceProcessor()
    assert vp.recorder is not None
    assert vp.transcriber is not None
    assert vp.storage is not None
    assert vp.session_id is not None


@patch("mini_project.modalities.voice_processor_pgSQL.get_connection")
def test_store_instruction_mocked_db(mock_get_conn):
    from unittest.mock import MagicMock

    import psycopg2

    # Create a fake connection and cursor
    mock_conn = MagicMock()
    mock_cursor = MagicMock()
    mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
    mock_get_conn.return_value = mock_conn

    storage = Storage()
    storage.store_instruction("test_session", "en", "hello world")

    mock_cursor.execute.assert_called_once()
    mock_conn.__enter__.assert_called_once()

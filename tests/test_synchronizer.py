import os
import sys
import sqlite3
import unittest
from datetime import datetime
from unittest.mock import MagicMock, patch

# Adjust import path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../..")))

from mini_project.modalities.synchronizer import (
    get_instructions_by_session,
    merge_session_commands,
    llm_unify,
    synchronize_and_unify,
)

TEST_DB = ":memory:"


class TestSynchronizer(unittest.TestCase):
    def setUp(self):
        self.conn = sqlite3.connect(TEST_DB)
        self.cur = self.conn.cursor()
        self.cur.execute("""
            CREATE TABLE IF NOT EXISTS voice_instructions (
                id INTEGER PRIMARY KEY,
                session_id TEXT,
                transcribed_text TEXT,
                processed BOOLEAN DEFAULT 0,
                timestamp DATETIME
            )
        """)
        self.cur.execute("""
            CREATE TABLE IF NOT EXISTS gesture_instructions (
                id INTEGER PRIMARY KEY,
                session_id TEXT,
                gesture_text TEXT,
                processed BOOLEAN DEFAULT 0,
                timestamp DATETIME
            )
        """)
        self.cur.execute("""
            CREATE TABLE IF NOT EXISTS unified_instructions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT,
                timestamp DATETIME,
                liu_id TEXT,
                voice_command TEXT,
                gesture_command TEXT,
                unified_command TEXT,
                processed INTEGER DEFAULT 0
            )
        """)
        self.conn.commit()

    def tearDown(self):
        self.conn.close()

    def _seed_voice_instructions(self, data):
        self.cur.executemany("""
            INSERT INTO voice_instructions (session_id, transcribed_text, processed, timestamp)
            VALUES (?, ?, ?, ?)""", data)
        self.conn.commit()

    def _seed_gesture_instructions(self, data):
        self.cur.executemany("""
            INSERT INTO gesture_instructions (session_id, gesture_text, processed, timestamp)
            VALUES (?, ?, ?, ?)""", data)
        self.conn.commit()

    def test_merge_session_commands(self):
        session_data = [
            {"modality": "voice", "instruction_text": "Move forward", "timestamp": datetime(2023, 1, 1, 10, 0, 0)},
            {"modality": "gesture", "instruction_text": "Pointing left", "timestamp": datetime(2023, 1, 1, 10, 0, 1)},
            {"modality": "voice", "instruction_text": "Speed up", "timestamp": datetime(2023, 1, 1, 10, 0, 2)},
        ]
        result = merge_session_commands(session_data)
        self.assertEqual(result["voice"], "Move forward\nSpeed up")
        self.assertEqual(result["gesture"], "Pointing left")

    def test_llm_unify_success(self):
        with patch("mini_project.modalities.synchronizer.subprocess.run") as mock_run:
            mock_result = MagicMock()
            mock_result.stdout = "Move forward slowly"
            mock_run.return_value = mock_result
            result = llm_unify("Move forward", "Slow down gesture")
            self.assertEqual(result, "Move forward slowly")

    def test_llm_unify_fallback(self):
        with patch("mini_project.modalities.synchronizer.subprocess.run") as mock_run:
            mock_result = MagicMock()
            mock_result.stdout = ""
            mock_run.return_value = mock_result
            result = llm_unify("Turn left", "Pointing")
            self.assertEqual(result, "Voice: Turn left, Gesture: Pointing")


if __name__ == "__main__":
    unittest.main()

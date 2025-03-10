import sys
import os

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../..")))

import unittest
from unittest.mock import patch, MagicMock
from mini_project.modalities.synchronizer import *

TEST_DB = ":memory:"


class TestSynchronizer(unittest.TestCase):
    def setUp(self):
        # Setup in-memory database
        self.conn = sqlite3.connect(TEST_DB)
        self.cur = self.conn.cursor()

        # Create source tables
        self.cur.execute(
            """
            CREATE TABLE IF NOT EXISTS voice_instructions (
                id INTEGER PRIMARY KEY,
                session_id TEXT,
                transcribed_text TEXT,
                processed BOOLEAN DEFAULT 0,
                timestamp DATETIME
            )
        """
        )
        self.cur.execute(
            """
            CREATE TABLE IF NOT EXISTS gesture_instructions (
                id INTEGER PRIMARY KEY,
                session_id TEXT,
                gesture_text TEXT,
                processed BOOLEAN DEFAULT 0,
                timestamp DATETIME
            )
        """
        )
        self.conn.commit()

    def tearDown(self):
        self.conn.close()

    def _seed_voice_instructions(self, data):
        self.cur.executemany(
            "INSERT INTO voice_instructions (session_id, transcribed_text, processed, timestamp) VALUES (?, ?, ?, ?)",
            data,
        )
        self.conn.commit()

    def _seed_gesture_instructions(self, data):
        self.cur.executemany(
            "INSERT INTO gesture_instructions (session_id, gesture_text, processed, timestamp) VALUES (?, ?, ?, ?)",
            data,
        )
        self.conn.commit()

    @patch("modalities.synchronizer.DB_PATH", new=TEST_DB)
    def test_get_instructions_by_session(self):
        # Seed test data
        voice_data = [
            ("session1", "Turn right", 0, "2023-01-01 10:00:00"),
            ("session1", "Speed up", 0, "2023-01-01 10:00:05"),
        ]
        gesture_data = [("session1", "Pointing up", 0, "2023-01-01 10:00:01")]
        self._seed_voice_instructions(voice_data)
        self._seed_gesture_instructions(gesture_data)

        result = get_instructions_by_session()

        self.assertIn("session1", result)
        self.assertEqual(len(result["session1"]), 3)
        modalities = [r["modality"] for r in result["session1"]]
        self.assertCountEqual(modalities, ["voice", "voice", "gesture"])

    @patch("modalities.synchronizer.DB_PATH", new=TEST_DB)
    def test_merge_session_commands(self):
        test_data = [
            {
                "modality": "voice",
                "instruction_text": "Move forward",
                "timestamp": datetime(2023, 1, 1, 10, 0, 0),
            },
            {
                "modality": "gesture",
                "instruction_text": "Pointing left",
                "timestamp": datetime(2023, 1, 1, 10, 0, 1),
            },
            {
                "modality": "voice",
                "instruction_text": "Speed up",
                "timestamp": datetime(2023, 1, 1, 10, 0, 2),
            },
        ]

        result = merge_session_commands(test_data)

        self.assertEqual(result["voice"], "Move forward\nSpeed up")
        self.assertEqual(result["gesture"], "Pointing left")

    @patch("modalities.synchronizer.subprocess.run")
    def test_llm_unify(self, mock_subprocess):
        # Test successful case
        mock_result = MagicMock()
        mock_result.stdout = "Move forward slowly"
        mock_subprocess.return_value = mock_result

        result = llm_unify("Move forward", "Slow down gesture")
        self.assertEqual(result, "Move forward slowly")

        # Test empty response fallback
        mock_result.stdout = ""
        result = llm_unify("Turn left", "Pointing")
        self.assertEqual(result, "Voice: Turn left, Gesture: Pointing")

    @patch("modalities.synchronizer.DB_PATH", new=TEST_DB)
    def test_full_integration(self):
        # Seed test data
        voice_data = [
            ("session1", "Turn right", 0, "2023-01-01 10:00:00"),
            ("session1", "Speed up", 0, "2023-01-01 10:00:05"),
        ]
        gesture_data = [("session1", "Pointing up", 0, "2023-01-01 10:00:01")]
        self._seed_voice_instructions(voice_data)
        self._seed_gesture_instructions(gesture_data)

        with patch("modalities.synchronizer.llm_unify") as mock_llm:
            mock_llm.return_value = "Turn right upward and speed up"

            # Execute main flow
            synchronize_and_unify()

            # Verify unified instructions
            self.cur.execute("SELECT * FROM unified_instructions")
            results = self.cur.fetchall()
            self.assertEqual(len(results), 1)

            # Verify processed flags
            self.cur.execute("SELECT processed FROM voice_instructions")
            self.assertEqual(sum(row[0] for row in self.cur.fetchall()), 2)
            self.cur.execute("SELECT processed FROM gesture_instructions")
            self.assertEqual(sum(row[0] for row in self.cur.fetchall()), 1)

    @patch("modalities.synchronizer.logger")
    def test_error_handling(self, mock_logger):
        # Test timestamp parsing error
        with patch("modalities.synchronizer.datetime") as mock_dt:
            mock_dt.fromisoformat.side_effect = ValueError("Invalid timestamp")
            get_instructions_by_session()
            mock_logger.error.assert_called()


if __name__ == "__main__":
    try:
        unittest.main()
    except SystemExit:
        # Handle the SystemExit gracefully to avoid abrupt termination
        pass

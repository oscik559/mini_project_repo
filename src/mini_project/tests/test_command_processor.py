import unittest
from unittest.mock import patch, MagicMock
import sqlite3
import json

# Assuming CommandProcessor is in command_processor.py
from command_processor import CommandProcessor, logger


class TestCommandProcessor(unittest.TestCase):
    def setUp(self):
        self.processor = CommandProcessor()
        self.processor.conn = MagicMock()  # Mock SQLite connection
        self.processor.available_sequences = ["pick", "place", "go_home"]
        self.processor.available_objects = ["RedCube", "BlueCube"]
        self.processor.no_object_sequences = {"go_home"}

    def test_fetch_column_success(self):
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [("pick",), ("place",)]
        self.processor.conn.cursor.return_value = mock_cursor
        result = self.processor.fetch_column("sequence_library", "sequence_name")
        self.assertEqual(result, ["pick", "place"])

    def test_fetch_column_error(self):
        self.processor.conn.cursor.side_effect = sqlite3.Error("DB error")
        with self.assertRaises(sqlite3.Error):
            self.processor.fetch_column("sequence_library", "sequence_name")

    def test_validate_operation_valid_with_object(self):
        operation = {"sequence_name": "pick", "object_name": "RedCube"}
        result = self.processor.validate_operation(operation)
        self.assertTrue(result)

    def test_validate_operation_valid_no_object(self):
        operation = {"sequence_name": "go_home", "object_name": ""}
        result = self.processor.validate_operation(operation)
        self.assertTrue(result)

    def test_validate_operation_invalid_sequence(self):
        operation = {"sequence_name": "invalid_seq", "object_name": "RedCube"}
        result = self.processor.validate_operation(operation)
        self.assertFalse(result)

    def test_validate_operation_missing_object(self):
        operation = {"sequence_name": "pick", "object_name": ""}
        result = self.processor.validate_operation(operation)
        self.assertFalse(result)

    def test_validate_operation_unneeded_object(self):
        operation = {"sequence_name": "go_home", "object_name": "RedCube"}
        result = self.processor.validate_operation(operation)
        self.assertFalse(result)

    def test_extract_json_array_valid(self):
        raw = '[{"sequence_name": "pick", "object_name": "RedCube"}]'
        result = self.processor.extract_json_array(raw)
        self.assertEqual(result, [{"sequence_name": "pick", "object_name": "RedCube"}])

    def test_extract_json_array_malformed(self):
        raw = '[{"sequence_name": "pick", "object_name": "RedCube"}][{"sequence_name": "place", "object_name": "BlueCube"}]'
        result = self.processor.extract_json_array(raw)
        self.assertEqual(
            result,
            [
                {"sequence_name": "pick", "object_name": "RedCube"},
                {"sequence_name": "place", "object_name": "BlueCube"},
            ],
        )

    def test_extract_json_array_invalid(self):
        raw = "Not a JSON array"
        with self.assertRaises(ValueError):
            self.processor.extract_json_array(raw)

    @patch("command_processor.ollama.chat")
    def test_process_command_success(self, mock_ollama):
        mock_ollama.return_value = {
            "message": {
                "content": '[{"sequence_name": "pick", "object_name": "RedCube"}]'
            }
        }
        mock_cursor = MagicMock()
        mock_cursor.fetchone.side_effect = [(1,), (101,)]  # sequence_id, object_id
        self.processor.conn.cursor.return_value = mock_cursor

        unified_command = {"id": 1, "unified_command": "Pick up the RedCube"}
        result = self.processor.process_command(unified_command)
        self.assertTrue(result)
        self.processor.conn.commit.assert_called_once()

    @patch("command_processor.ollama.chat")
    def test_process_command_invalid_llm_response(self, mock_ollama):
        mock_ollama.return_value = {"message": {"content": "Invalid response"}}
        unified_command = {"id": 1, "unified_command": "Pick up the RedCube"}
        result = self.processor.process_command(unified_command)
        self.assertTrue(result)  # Empty but valid response is still "success"

    def test_get_unprocessed_unified_command(self):
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = sqlite3.Row(
            self.processor.conn, (1, "Pick up the RedCube")
        )
        self.processor.conn.cursor.return_value = mock_cursor
        result = self.processor.get_unprocessed_unified_command()
        self.assertEqual(result, {"id": 1, "unified_command": "Pick up the RedCube"})


if __name__ == "__main__":
    unittest.main()

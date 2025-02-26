# modalities/command_processor.py

import atexit
import json
import logging
import sqlite3
import time
from typing import Dict, List

import ollama

from config.app_config import DB_PATH, setup_logging

# === Logging Setup ===
setup_logging(level=logging.INFO)
logger = logging.getLogger("CommandProcessor")


class CommandProcessor:
    def __init__(self, llm_model: str = "llama3.2:latest"):
        self.db_path = DB_PATH
        self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
        self.conn.execute("PRAGMA foreign_keys = ON")
        self.conn.execute("PRAGMA journal_mode=WAL;")

        self.llm_model = llm_model

        self.system_prompt = """You are a robot task and operation sequence planner. Analyze the instruction and break it down into sequential operations using these available sequence_names:
        {available_sequences} and available object_names {available_objects}

        **Strict Output Rules**:
        **Output Format**:
            - The response MUST consist of ONLY one **SINGLE valid JSON array** containing all operations. Do NOT return multiple arrays.
            - Do NOT include any text, explanations, or additional comments outside the JSON array.
        **Required Fields**: Each operation MUST have "sequence_name" and "object_name"
        **Valid Values**:
            - "sequence_name" must be one of the following: {available_sequences}
            - "object_name" must be one of the following: {available_objects} or an empty string ("") if not applicable to the corresponding sequence_name.
        **Formatting**:
            - Use double quotes (`"`) for all keys and string values.
            - Ensure the JSON is valid and parsable by standard JSON parsers.
        **IMPORTANT**: Do NOT include any explanations, instructions, or text outside the JSON array. Return ONLY the JSON array.
        **Example Output**:
        ```json
        [{{"sequence_name": "pick", "object_name": "RedCube"}}]
        [{{"sequence_name": "go_home", "object_name": ""}}]
        ```
        """

        # Cache available sequences and objects from database for validation purposes
        self.available_sequences = self.get_available_sequences()
        self.available_objects = self.get_available_objects()

    def get_available_sequences(self) -> List[str]:
        """Fetch available sequence names from sequence_library in database"""
        try:

            cursor = self.conn.cursor()
            cursor.execute("SELECT sequence_name FROM sequence_library")
            logger.info("Fetching available sequences...")  # Debugging
            available_sequences = [row[0] for row in cursor.fetchall()]
            logger.info(f"Available sequences: {available_sequences}")
            return available_sequences
        except sqlite3.Error as e:
            logger.error(
                "Database error in get_available_sequences: %s", str(e), exc_info=True
            )
            raise

    def get_available_objects(self) -> List[str]:
        """Fetch available object names from camera_vision in database"""
        try:

            cursor = self.conn.cursor()
            cursor.execute("SELECT object_name FROM camera_vision")
            logger.info("Fetching available objects...")  # Debugging
            available_objects = [row[0] for row in cursor.fetchall()]
            logger.info(f"Available objects: {available_objects}")
            return available_objects
        except sqlite3.Error as e:
            logger.error(
                "Database error in get_available_objects: %s", str(e), exc_info=True
            )
            raise

    def get_unprocessed_unified_command(self) -> Dict:
        """Retrieve the latest unprocessed unified command."""
        try:

            self.conn.row_factory = sqlite3.Row
            cursor = self.conn.cursor()
            cursor.execute(
                """
                SELECT id, unified_command
                FROM unified_instructions
                WHERE processed = 0
                ORDER BY id DESC
                LIMIT 1
            """
            )
            result = cursor.fetchone()
            return dict(result) if result else None
        except sqlite3.Error as e:
            logger.error(
                "Database error in get_latest_unprocessed_instruction: %s",
                str(e),
                exc_info=True,
            )
            raise

    def validate_operation(self, operation: Dict) -> bool:
        """Validate operation structure"""
        available_sequences = self.get_available_sequences()
        if operation["sequence_name"] not in available_sequences:
            logger.error(f"Invalid sequence name: {operation['sequence_name']}")
            return False

        # Allow empty object names
        if not operation.get("object_name", ""):
            return True

        # Validate object if specified by comparing with available objects
        available_objects = self.get_available_objects()
        if operation["object_name"] in available_objects:
            return True
        else:
            logger.error(f"Invalid object name: {operation['object_name']}")
            return False

    def extract_json_array(self, raw_response: str) -> List[Dict]:
        json_start = raw_response.find("[")
        json_end = raw_response.rfind("]") + 1
        if json_start == -1 or json_end == 0:
            raise ValueError("JSON array not found in the response.")
        json_str = raw_response[json_start:json_end]
        try:
            return json.loads(json_str)
        except json.JSONDecodeError:
            json_str_fixed = "[" + json_str.replace("][", "],[") + "]"
            return json.loads(json_str_fixed)

    def process_command(self, unified_command: Dict) -> bool:
        """
        Process a single unified command using LLM
        """
        try:
            available_sequences = self.get_available_sequences()
            available_objects = self.get_available_objects()

            # Format the system prompt with available sequences
            formatted_system_prompt = self.system_prompt.format(
                available_sequences=", ".join(available_sequences),
                available_objects=", ".join(available_objects),
            )
            logger.debug(f"Formatted system prompt: {formatted_system_prompt}")
            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    {"role": "system", "content": formatted_system_prompt},
                    {"role": "user", "content": unified_command["unified_command"]},
                ],
            )

        except sqlite3.Error as db_err:
            logger.error(
                "Database error while preparing prompt: %s", db_err, exc_info=True
            )
            return False
        except Exception as e:
            logger.error(
                "Unexpected error during prompt formation: %s", e, exc_info=True
            )
            return False

            # Extract the raw response content
        try:
            raw_response = response["message"]["content"]
            logger.info("Raw LLM Response: %s", raw_response)
        except KeyError as key_err:
            logger.error(
                "LLM response structure is unexpected: %s", key_err, exc_info=True
            )
            return False

        try:
            operations = self.extract_json_array(raw_response)
        except (ValueError, json.JSONDecodeError) as json_err:
            logger.error("JSON extraction/parsing error: %s", json_err, exc_info=True)
            return False

        # Ensure each operation has an "object_name" key (default to empty string if missing)
        for op in operations:
            if "object_name" not in op:
                op["object_name"] = ""

        # Validate operation structure
        valid_operations = []
        for op in operations:
            if not all(key in op for key in ["sequence_name", "object_name"]):
                logger.error("Invalid operation missing keys: %s", op)
                continue

            if self.validate_operation(op):
                valid_operations.append(op)
            else:
                logger.error("Operation failed validation: %s", op)

        if valid_operations:
            try:
                cursor = self.conn.cursor()
                for op in valid_operations:
                    # Lookup the sequence_id for the given sequence_name
                    cursor.execute(
                        "SELECT sequence_id FROM sequence_library WHERE sequence_name = ?",
                        (op["sequence_name"],),
                    )
                    seq_result = cursor.fetchone()
                    if not seq_result:
                        logger.error(
                            "No matching sequence found for: %s", op["sequence_name"]
                        )
                        continue  # Skip this operation if no valid sequence_id is found
                    sequence_id = seq_result[0]

                    # If object_name is provided, look up the corresponding object_id
                    if op["object_name"]:
                        cursor.execute(
                            "SELECT object_id FROM camera_vision WHERE object_name = ?",
                            (op["object_name"],),
                        )
                        obj_result = cursor.fetchone()
                        if not obj_result:
                            logger.error(
                                "No matching object found for: %s", op["object_name"]
                            )
                            continue  # Skip this operation if no valid object_id is found
                        object_id = obj_result[0]
                    else:
                        object_id = None

                    logger.info("Inserting operation: %s", op)
                    cursor.execute(
                        """
                        INSERT INTO instruction_operation_sequence
                        (instruction_id, sequence_id, sequence_name, object_id, object_name)
                        VALUES (?, ?, ?, ?, ?)
                    """,
                        (
                            unified_command["id"],
                            sequence_id,
                            op["sequence_name"],
                            object_id,
                            op.get("object_name", ""),
                        ),
                    )

                cursor.execute(
                    "UPDATE unified_instructions SET processed = 1 WHERE id = ?",
                    (unified_command["id"],),
                )
                self.conn.commit()
                return True
            except sqlite3.Error as db_err:
                logger.error(
                    "Database error while inserting operations: %s",
                    db_err,
                    exc_info=True,
                )
                return False
        else:
            return False

    def run_processing_cycle(self):
        """
        Process the latest unprocessed unified command
        """
        logger.info("Checking for new unified_commands...")
        unified_command = self.get_unprocessed_unified_command()

        if unified_command:
            logger.info(f"Processing command ID: {unified_command['id']}")
            if self.process_command(unified_command):
                logger.info(
                    f"Successfully processed unified_command {unified_command['id']}"
                )
            else:
                logger.error(
                    f"Failed to process unified_command {unified_command['id']}"
                )
        else:
            logger.info("No unprocessed unified_commands found")

    def close(self):
        """Close the persistent SQLite connection."""
        if self.conn:
            self.conn.close()
            self.conn = None
            logger.info("Database connection closed.")


if __name__ == "__main__":

    # models: "llama3.2:1b", "deepseek-r1:1.5b", "mistral:latest", "deepseek-r1:32b"

    processor = CommandProcessor(llm_model="mistral:latest")

    # Register the close method so it gets called when the program exits
    atexit.register(processor.close)
    processor.run_processing_cycle()

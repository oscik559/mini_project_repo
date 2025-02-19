# modalities/instruction_processor.py

import json
import sqlite3
import time
from typing import Dict, List
import logging
import ollama

from config.app_config import DB_PATH, setup_logging


# === Logging Setup ===
setup_logging(level=logging.INFO)
logger = logging.getLogger("InstructionProcessor")


class InstructionProcessor:
    def __init__(self):
        self.db_path = DB_PATH

        self.llm_model = "llama3.2:latest"
        # self.llm_model = "llama3.2:1b"
        # self.llm_model = "deepseek-r1:1.5b"
        # self.llm_model = "deepseek-r1:32b"
        # self.llm_model = "mistral:latest"
        # self.llm_model = "mistral:latest"

        self.system_prompt = """You are a robot task and operation sequence planner. Analyze the instruction and break it down into sequential operations using these available sequence_names:
        {available_sequences}

        **Strict Output Rules**:
        **Output Format**:
            - The response MUST consist of ONLY  one **SINGLE valid JSON array** containing all operations. Do NOT return multiple arrays..
            - Do NOT include any text, explanations, or additional comments outside the JSON array.
        **Required Fields**: Each operation MUST have "sequence_name" and "object_name" fields
        **Valid Values**:
            - "sequence_name" must be one of the following: {available_sequences}
            - "object_name" must be from detected objects or must be empty if not applicable for that sequence_name.
        **Example Output**:
        ```json
        [{{"sequence_name": "pick", "object_name": "RedCube"}}]
        ```
        **Formatting**:
            - Use double quotes (`"`) for all keys and string values.
            - Ensure the JSON is valid and parsable by standard JSON parsers.
        **IMPORTANT**: Do NOT include any explanations, instructions, or text outside the JSON array. Return ONLY the JSON array.
        """

    def get_available_sequences(self) -> List[str]:
        """Fetch available sequence names from sequence_library in database"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT sequence_name FROM sequence_library")
                logger.info("Fetching available sequences...")  # Debugging
                available_sequences = [row[0] for row in cursor.fetchall()]
                logger.info("Available sequences:", available_sequences)  # Debugging

                return available_sequences
        except sqlite3.Error as e:
            logger.error(
                "Database error in get_available_sequences: %s", str(e), exc_info=True
            )
            raise

    def get_latest_unprocessed_instruction(self) -> Dict:
        """Retrieve the latest unprocessed instruction"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.row_factory = sqlite3.Row
                cursor = conn.cursor()
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
            print(f"Invalid sequence name: {operation['sequence_name']}")
            return False

        # Allow empty object names
        if not operation["object_name"]:
            return True

        # Validate object if specified
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT 1 FROM camera_vision WHERE object_name = ?",
                    (operation["object_name"],),
                )
                return bool(cursor.fetchone())
        except sqlite3.Error as e:
            logger.error(
                "Database error in validate_operation: %s", str(e), exc_info=True
            )
            return False

    def process_instruction(self, instruction: Dict) -> bool:
        """
        Process a single instruction using LLM
        """
        try:
            available_sequences = self.get_available_sequences()

            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    {
                        "role": "system",
                        "unified_command": self.system_prompt.format(
                            available_sequences=", ".join(available_sequences)
                        ),
                    },
                    {
                        "role": "user",
                        "unified_command": unified_instructions["unified_command"],
                    },
                ],
            )

            raw_response = response["message"]["unified_command"]
            print("Raw LLM Response:", raw_response)

            try:
                # Extract all JSON arrays from the response
                json_start = raw_response.find("[")
                json_end = raw_response.rfind("]") + 1
                if json_start == -1 or json_end == 0:
                    raise ValueError("JSON array not found in the response.")

                json_str = raw_response[json_start:json_end]

                # Try parsing as a single JSON array first
                try:
                    operations = json.loads(json_str)  # Parse the JSON string
                except json.JSONDecodeError:
                    # Handle multiple JSON arrays manually
                    json_str_fixed = "[" + json_str.replace("][", "],[") + "]"
                    operations = json.loads(json_str_fixed)
                logger.debug("Parsed Operations:", operations)  # Debugging

            except (ValueError, json.JSONDecodeError) as e:
                logger.error(f"JSON parsing failed: {str(e)}")
                print("Raw LLM Response:", raw_response)  # Debugging purpose
                return False

            # Validate operation structure
            valid_operations = []
            for op in operations:
                # try:
                if not all(key in op for key in ["sequence_name", "object_name"]):
                    logger.error(f"Invalid operation missing keys: {op}")  # Debugging
                    continue

                if self.validate_operation(op):
                    valid_operations.append(op)
                else:
                    logger.error(f"Operation failed validation: {op}")  # Debugging
            if valid_operations:
                with sqlite3.connect(self.db_path) as conn:
                    cursor = conn.cursor()
                    for order, op in enumerate(valid_operations, start=1):
                        print(f"Inserting: {op}")  # Debugging
                        cursor.execute(
                            """
                            INSERT INTO instruction_operation_sequence
                            (instruction_id, sequence_id, sequence_name, object_name)
                            VALUES (?, ?, ?, ?)
                        """,
                            (
                                instruction["id"],
                                order,
                                op["sequence_name"],
                                op.get(
                                    "object_name", ""
                                ),  # Handle missing values safely
                            ),
                        )

                    cursor.execute(
                        """
                        UPDATE unified_instructions
                        SET processed = 1
                        WHERE id = ?
                    """,
                        (instruction["id"],),
                    )
                    conn.commit()
                return True
            return False
        except Exception as e:
            logger.error(
                f"Error processing instruction {instruction.get('id')}: {str(e)}"
            )
            return False

    def run_processing_cycle(self):
        """
        Process the latest unprocessed instruction
        """
        logger.info("Checking for new unified_commands...")
        instruction = self.get_latest_unprocessed_instruction()

        if instruction:
            logger.info(f"Processing instruction ID: {instruction['id']}")
            if self.process_instruction(instruction):
                logger.info(f"Successfully processed instruction {instruction['id']}")
            else:
                logger.error(f"Failed to process instruction {instruction['id']}")
        else:
            logger.info("No unprocessed unified_commands found")


if __name__ == "__main__":
    processor = InstructionProcessor()
    processor.run_processing_cycle()

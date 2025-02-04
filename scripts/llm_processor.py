import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
import json
import sqlite3
import time
from typing import Dict, List

import ollama
from config.config import DB_PATH


class InstructionProcessor:
    def __init__(self):
        self.db_path = DB_PATH

        # Define the LLM model to use
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
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT sequence_name FROM sequence_library")
            print("Fetching available sequences...")  # Debugging
            available_sequences = [row[0] for row in cursor.fetchall()]
            print("Available sequences:", available_sequences)  # Debugging

            return available_sequences

    def get_latest_unprocessed_instruction(self) -> Dict:
        """Retrieve the latest unprocessed instruction"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT id, content
                FROM instructions
                WHERE processed = 0
                ORDER BY id DESC
                LIMIT 1
            """
            )
            result = cursor.fetchone()
            return dict(result) if result else None

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
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                "SELECT 1 FROM camera_vision WHERE object_name = ?",
                (operation["object_name"],),
            )
            return bool(cursor.fetchone())

    def process_instruction(self, instruction: Dict) -> bool:
        """Process a single instruction using LLM"""

        ### **Modify JSON Parsing Code**

        try:
            sequence_library = self.get_available_sequences()

            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    {
                        "role": "system",
                        "content": self.system_prompt.format(
                            available_sequences=", ".join(sequence_library)
                        ),
                    },
                    {"role": "user", "content": instruction["content"]},
                ],
            )

            raw_response = response["message"]["content"]
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
                print("Parsed Operations:", operations)  # Debugging

            except (ValueError, json.JSONDecodeError) as e:
                print(f"JSON parsing failed: {str(e)}")
                print("Raw LLM Response:", raw_response)  # Debugging purpose
                return False

            # Validate operation structure
            valid_operations = []
            for op in operations:
                # try:
                if not all(key in op for key in ["sequence_name", "object_name"]):
                    print(f"Invalid operation missing keys: {op}")  # Debugging
                    continue

                if self.validate_operation(op):
                    valid_operations.append(op)
                else:
                    print(f"Operation failed validation: {op}")  # Debugging
            # except Exception as op_error:
            #     print(f"Error validating operation {op}: {str(op_error)}")
            #     continue

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
                        UPDATE instructions
                        SET processed = 1
                        WHERE id = ?
                    """,
                        (instruction["id"],),
                    )
                    conn.commit()
                return True
            return False
        except Exception as e:
            print(f"Error processing instruction {instruction.get('id')}: {str(e)}")
            return False

    def run_processing_cycle(self):
        """Process the latest unprocessed instruction"""
        print("Checking for new instructions...")
        instruction = self.get_latest_unprocessed_instruction()

        if instruction:
            print(f"Processing instruction ID: {instruction['id']}")
            if self.process_instruction(instruction):
                print(f"Successfully processed instruction {instruction['id']}")
            else:
                print(f"Failed to process instruction {instruction['id']}")
        else:
            print("No unprocessed instructions found")


if __name__ == "__main__":
    # # Initialize database schema
    # with sqlite3.connect("sequences.db") as conn:
    processor = InstructionProcessor()
    processor.run_processing_cycle()

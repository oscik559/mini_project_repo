# modalities/command_processor.py


import atexit
import json
import logging
import os
import time
from typing import Dict, List, Tuple

import ollama
import psycopg2
from psycopg2 import Error as Psycopg2Error
from psycopg2 import sql
from psycopg2.extras import DictCursor

from config.app_config import DB_PATH, setup_logging
from mini_project.database.connection import get_connection

# === Logging Setup ===
debug_mode = os.getenv("DEBUG", "0") in ["1", "true", "True"]
log_level = os.getenv("LOG_LEVEL", "DEBUG" if debug_mode else "INFO").upper()

setup_logging(level=getattr(logging, log_level))
logger = logging.getLogger("CommandProcessor")

# === CONFIGURATION ===
OLLAMA_MODEL = "mistral:latest"
# OLLAMA_MODEL = "llama3.2:latest"
# OLLAMA_MODEL = "llama3.3:latest"


class CommandProcessor:
    def __init__(self, llm_model: str = OLLAMA_MODEL):
        self.conn = get_connection()
        self.cursor = self.conn.cursor(cursor_factory=DictCursor)

        self.llm_model = llm_model

        self.system_prompt = """
            You are a robotic task planner. Your job is to break down natural language commands into valid low-level robot operations.

            ### CONTEXT:

            #### 1. AVAILABLE SEQUENCES:
            The robot can only use the following valid sequence names from the sequence_library table:
            {available_sequences}

            ⚠️ Do NOT invent or assume sequences. Only use the names provided above. Invalid examples: checkColor, rotate, scan, verify, etc.


            #### 2. TASK TEMPLATES:
            These are default sequences for high-level tasks like sorting, assembling, etc.

            Examples:
            {task_templates}

            #### 3. OBJECT CONTEXT:
            Here are the known objects the robot can see, with color:
            {object_context}

            #### 4. SORT ORDER:
            When sorting by color, use this color priority (from sort_order):
            {sort_order}

            ### INSTRUCTIONS:
            1. Determine the intended task (e.g., "sort").
            2. Use the default task template unless user modifies the plan.
            3. Match object names by color (e.g., "green slide").
            4. If the user specifies steps (e.g., “rotate before drop”), update the sequence.
            5. Apply the sequence to each object in order.
            6. Must always Add `"go_home"` at the end unless told otherwise.

            ### RESPONSE FORMAT:
            Example JSON array of operations:
            [
            {{"sequence_name": "pick", "object_name": "Slide_1"}},
            {{"sequence_name": "travel", "object_name": "Slide_1"}},
            {{"sequence_name": "drop", "object_name": "Slide_1"}},
            {{"sequence_name": "go_home", "object_name": ""}}
            ]

            Return only one JSON array — NEVER return multiple arrays or repeat the plan.
            BAD ❌:
            [
            {{...}}
            ]
            [
            {{...}}
            ]

            GOOD ✅:
            [
            {{"sequence_name": "...", "object_name": "..."}},
            ...
            ]

            🚫 DO NOT include explanations like "Here's the plan:" or "In reverse order:" — only return ONE JSON array.

            Do NOT include extra text, markdown, or explanations.
            Note: All generated plans will be stored step-by-step in a planning table called "operation_sequence", indexed by a group ID called "operation_id".
            Each row in the output corresponds to one line in this table.

            """

        # Cache available sequences and objects from database for validation purposes
        self.available_sequences = self.get_available_sequences()
        self.available_objects = self.get_available_objects()

    def get_available_sequences(self) -> List[str]:
        """Fetch available sequence names from sequence_library in database"""
        try:

            cursor = self.cursor
            cursor.execute("SELECT sequence_name FROM sequence_library")
            logger.info("Fetching available sequences...")  # Debugging
            available_sequences = [row[0] for row in cursor.fetchall()]
            logger.info(f"Available sequences: {available_sequences}")
            return available_sequences
        except Psycopg2Error as e:
            logger.error(
                "Database error in get_available_sequences: %s", str(e), exc_info=True
            )
            raise

    def fetch_column(self, table: str, column: str) -> list:
        try:
            query = sql.SQL("SELECT {field} FROM {tbl}").format(
                field=sql.Identifier(column), tbl=sql.Identifier(table)
            )
            self.cursor.execute(query)
            return [row[0] for row in self.cursor.fetchall()]
        except Psycopg2Error as e:
            logger.error("Database error in fetch_column: %s", str(e), exc_info=True)
            raise

    def get_available_objects(self) -> List[str]:
        """Fetch available object names from camera_vision in database"""
        try:

            cursor = self.cursor
            cursor.execute("SELECT object_name FROM camera_vision")
            logger.info("Fetching available objects...")  # Debugging
            available_objects = [row[0] for row in cursor.fetchall()]
            logger.info(f"Available objects: {available_objects}")
            return available_objects
        except Psycopg2Error as e:
            logger.error(
                "Database error in get_available_objects: %s", str(e), exc_info=True
            )
            raise

    def get_unprocessed_unified_command(self) -> Dict:
        try:
            cursor = self.cursor
            cursor.execute(
                """
                SELECT id, unified_command
                FROM unified_instructions
                WHERE processed = FALSE
                ORDER BY id DESC
                LIMIT 1
                """
            )
            result = cursor.fetchone()
            return (
                {"id": result["id"], "unified_command": result["unified_command"]}
                if result
                else None
            )
        except Psycopg2Error as e:
            logger.error(
                "Database error in get_latest_unprocessed_instruction: %s",
                str(e),
                exc_info=True,
            )
            raise

    def get_available_objects_with_colors(self) -> List[str]:
        self.cursor.execute("SELECT object_name, object_color FROM camera_vision")
        return [f"{name} ({color})" for name, color in self.cursor.fetchall()]

    def get_sort_order(self) -> List[str]:
        self.cursor.execute(
            "SELECT object_color FROM sort_order ORDER BY sequence_id ASC"
        )
        return [row[0] for row in self.cursor.fetchall()]

    def get_task_templates(self) -> Dict[str, List[str]]:
        self.cursor.execute("SELECT task_name, default_sequence FROM task_templates")
        return {row[0]: row[1] for row in self.cursor.fetchall()}

    def validate_operation(self, operation: Dict) -> bool:
        """Validate operation structure"""
        available_sequences = self.available_sequences
        if operation["sequence_name"] not in available_sequences:
            logger.error(f"Invalid sequence name: {operation['sequence_name']}")
            return False

        # Allow empty object names
        if not operation.get("object_name", ""):
            return True

        # Validate object if specified by comparing with available objects
        available_objects = self.available_objects
        if operation["object_name"] in available_objects:
            return True
        else:
            logger.error(f"Invalid object name: {operation['object_name']}")
            return False

    def extract_json_array(self, raw_response: str) -> List[Dict]:
        import re

        try:
            # Match the first complete JSON array only
            match = re.search(r"\[\s*{[\s\S]*?}\s*]", raw_response)
            if not match:
                raise ValueError("No valid JSON array found in LLM response.")

            json_str = match.group(0)
            return json.loads(json_str)

        except Exception as e:
            logger.error(
                "Failed to extract JSON array from LLM response: %s", e, exc_info=True
            )
            raise

    def process_command(self, unified_command: Dict) -> Tuple[bool, List[Dict]]:
        """
        Process a single unified command using LLM and return success + valid operations.
        """
        try:
            task_templates = self.get_task_templates()
            formatted_templates = "\n".join(
                f'- Task: "{k}" → {v}' for k, v in task_templates.items()
            )

            formatted_system_prompt = self.system_prompt.format(
                available_sequences=", ".join(self.available_sequences),
                task_templates=formatted_templates,
                object_context=", ".join(self.get_available_objects_with_colors()),
                sort_order=", ".join(self.get_sort_order()),
            )

            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    {"role": "system", "content": formatted_system_prompt},
                    {"role": "user", "content": unified_command["unified_command"]},
                ],
            )
        except Exception as e:
            ...  # logging
            return False, []

        try:
            raw_response = response["message"]["content"]
            logger.info("Raw LLM Response: %s", raw_response)
            operations = self.extract_json_array(raw_response)
        except Exception as e:
            logger.error("JSON parsing error: %s", e, exc_info=True)
            return False, []

        valid_operations = []
        for op in operations:
            op.setdefault("object_name", "")
            if all(
                k in op for k in ["sequence_name", "object_name"]
            ) and self.validate_operation(op):
                valid_operations.append(op)

        if valid_operations:
            try:
                cursor = self.cursor
                cursor.execute(
                    "UPDATE operation_sequence SET processed = TRUE WHERE processed = FALSE"
                )
                cursor.execute(
                    "SELECT COALESCE(MAX(operation_id), 0) + 1 FROM operation_sequence"
                )
                operation_id = cursor.fetchone()[0]

                for idx, op in enumerate(valid_operations):
                    cursor.execute(
                        "SELECT sequence_id FROM sequence_library WHERE sequence_name = %s",
                        (op["sequence_name"],),
                    )
                    seq_result = cursor.fetchone()
                    if not seq_result:
                        continue

                    cursor.execute(
                        """
                        INSERT INTO operation_sequence
                        (operation_id, sequence_id, sequence_name, object_name, command_id)
                        VALUES (%s, %s, %s, %s, %s)
                        """,
                        (
                            idx + 1,
                            seq_result[0],
                            op["sequence_name"],
                            op["object_name"],
                            unified_command["id"],
                        ),
                    )

                cursor.execute(
                    "UPDATE unified_instructions SET processed = TRUE WHERE id = %s",
                    (unified_command["id"],),
                )

                # Auto-populate operation parameter tables
                self.populate_operation_parameters()

                # ✅ Log to task_history
                self.cursor.execute(
                    "INSERT INTO task_history (command_text, generated_plan) VALUES (%s, %s)",
                    (unified_command["unified_command"], json.dumps(valid_operations)),
                )

                self.conn.commit()
                return True, valid_operations
            except Exception as e:
                logger.error("Failed to insert plan: %s", e, exc_info=True)
                return False, []
        return False, []

    def populate_operation_parameters(self):
        logger.info("Populating operation-specific parameters...")

        # Step 1: Get all unique sequence types planned
        self.cursor.execute("SELECT DISTINCT sequence_name FROM operation_sequence")
        sequence_types = [row[0] for row in self.cursor.fetchall()]

        insert_count = 0

        if "pick" in sequence_types:
            self.cursor.execute("DELETE FROM pick_op_parameters")
            self.cursor.execute(
                "SELECT object_name FROM operation_sequence WHERE sequence_name = 'pick'"
            )
            pick_data = self.cursor.fetchall()
            for i, (obj,) in enumerate(pick_data):
                self.cursor.execute(
                    """
                    INSERT INTO pick_op_parameters (
                        operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status
                    ) VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (i + 1, obj, False, "y", 0.01, False),
                )
                insert_count += 1
            logger.info(f"Inserted {insert_count} rows into pick_op_parameters.")

        if "travel" in sequence_types:
            self.cursor.execute("DELETE FROM travel_op_parameters")
            self.cursor.execute(
                "SELECT object_name FROM operation_sequence WHERE sequence_name = 'travel'"
            )
            travel_data = self.cursor.fetchall()
            for i, (obj,) in enumerate(travel_data):
                self.cursor.execute(
                    """
                    INSERT INTO travel_op_parameters (
                        operation_order, object_id, travel_height, gripper_rotation, operation_status
                    ) VALUES (%s, %s, %s, %s, %s)
                    """,
                    (i + 1, obj, 0.085, "y-axis", False),
                )
                insert_count += 1
            logger.info(f"Inserted {insert_count} rows into travel_op_parameters.")

        if "drop" in sequence_types:
            self.cursor.execute("DELETE FROM drop_op_parameters")
            self.cursor.execute(
                "SELECT object_name FROM operation_sequence WHERE sequence_name = 'drop'"
            )
            drop_data = self.cursor.fetchall()
            for i, (obj,) in enumerate(drop_data):
                self.cursor.execute(
                    """
                    INSERT INTO drop_op_parameters (
                        operation_order, object_id, drop_height, operation_status
                    ) VALUES (%s, %s, %s, %s)
                    """,
                    (i + 1, obj, 0.0, False),
                )
                insert_count += 1
            logger.info(f"Inserted {insert_count} rows into drop_op_parameters.")

        if "screw" in sequence_types:
            self.cursor.execute("DELETE FROM screw_op_parameters")
            self.cursor.execute(
                "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'screw'"
            )
            screw_data = self.cursor.fetchall()
            for i, (seq_id, obj) in enumerate(screw_data):
                self.cursor.execute(
                    """
                    INSERT INTO screw_op_parameters (
                        operation_order, sequence_id, object_id,
                        rotation_dir, number_of_rotations,
                        current_rotation, operation_status
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (i + 1, seq_id, obj, i % 2 == 0, 3, 0, False),
                )
                insert_count += 1
            logger.info(f"Inserted {insert_count} rows into screw_op_parameters.")

        if "screw" in sequence_types:
            self.cursor.execute("DELETE FROM rotate_state_parameters")
            self.cursor.execute(
                "SELECT sequence_id, operation_order, object_id FROM screw_op_parameters"
            )
            rotate_data = self.cursor.fetchall()
            for seq_id, op_order, obj in rotate_data:
                self.cursor.execute(
                    """
                    INSERT INTO rotate_state_parameters (
                        sequence_id, operation_order, object_id,
                        rotation_angle, operation_status
                    ) VALUES (%s, %s, %s, %s, %s)
                    """,
                    (seq_id, op_order, obj, 90, False),
                )
                insert_count += 1
            logger.info(f"Inserted {insert_count} rows into rotate_state_parameters.")

        self.conn.commit()
        logger.info("Operation-specific parameter tables updated.")

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

# modalities/command_processor.py
"""CommandProcessor Class
This class is responsible for processing unified commands for robotic tasks. It interacts with a database to fetch
and validate data, uses an LLM (Large Language Model) for inference and classification, and generates operation
sequences based on the provided commands.
Attributes:
    conn (psycopg2.connection): Database connection object.
    cursor (psycopg2.cursor): Cursor for executing database queries.
    logger (logging.Logger): Logger instance for logging messages.
    llm_model (str): The LLM model used for inference.
    available_sequences (List[str]): Cached list of available sequences from the database.
    available_objects (List[str]): Cached list of available objects from the database.
Methods:
    __init__(llm_model: str = OLLAMA_MODEL):
        Initializes the CommandProcessor instance, sets up database connection, and caches available sequences and objects.
    get_available_sequences() -> List[str]:
        Fetches available sequence names from the sequence_library table in the database.
    fetch_column(table: str, column: str) -> list:
        Fetches a specific column from a given table in the database.
    get_available_objects() -> List[str]:
        Fetches available object names from the camera_vision table in the database.
    get_unprocessed_unified_command() -> Dict:
        Retrieves the latest unprocessed unified command from the unified_instructions table.
    get_available_objects_with_colors() -> List[str]:
        Fetches object names along with their colors from the camera_vision table.
    get_sort_order() -> List[str]:
        Fetches the sort order of objects from the sort_order table.
    get_task_templates() -> Dict[str, List[str]]:
        Fetches task templates from the task_templates table.
    validate_operation(operation: Dict) -> bool:
        Validates the structure of an operation and checks if the sequence and object names are valid.
    extract_json_array(raw_response: str) -> List[Dict]:
        Extracts a JSON array from a raw LLM response string.
    infer_operation_name_from_llm(command_text: str) -> str:
        Infers the operation name from a user command using the LLM.
    get_task_order(operation_name: str) -> List[str]:
        Retrieves the task order for a given operation name from the operation_library table.
    generate_operations_from_sort_order(task_order: List[str], command_id: int) -> List[Dict]:
        Generates a list of operations based on the task order and sort order.
    process_command(unified_command: Dict) -> Tuple[bool, List[Dict]]:
        Processes a unified command, generates operations, and updates the database.
    populate_operation_parameters():
        Populates operation-specific parameter tables in the database based on the planned sequences.
    extract_sort_order_from_llm(command_text: str) -> List[Tuple[str, str]]:
        Extracts the sort order of objects from a user command using the LLM.
    populate_sort_order_from_llm(command_text: str) -> None:
        Populates the sort_order table in the database based on the extracted sort order from the LLM.
    run_processing_cycle():
        Processes the latest unprocessed unified command.
    close():
        Closes the database connection.
Usage:
    This class is designed to be used as a command processor for robotic tasks. It integrates with a database
    and an LLM to process commands, validate operations, and generate operation sequences. The `run_processing_cycle`
    method can be used to process the latest unprocessed command in a single cycle.
"""

import atexit
import json
import logging
import os
from collections import defaultdict, deque
from typing import Dict, List, Tuple

import ollama
import psycopg2
from psycopg2 import Error as Psycopg2Error
from psycopg2 import sql
from psycopg2.extras import DictCursor

from mini_project.config.app_config import setup_logging
from mini_project.database.connection import get_connection
from mini_project.modalities.prompt_utils import PromptBuilder

# === Logging Setup ===
debug_mode = os.getenv("DEBUG", "0") in ["1", "true", "True"]
log_level = os.getenv("LOG_LEVEL", "DEBUG" if debug_mode else "INFO").upper()
setup_logging(level=getattr(logging, log_level))
logger = logging.getLogger("CommandProcess")

# models: "llama3.2:1b", "deepseek-r1:1.5b", "mistral:latest", "deepseek-r1:32b"
OLLAMA_MODEL = "mistral:latest"


class CommandProcessor:

    def __init__(self, llm_model: str = OLLAMA_MODEL):
        self.conn = get_connection()
        self.cursor = self.conn.cursor(cursor_factory=DictCursor)
        self.logger = logger
        self.llm_model = llm_model

        # Cache available sequences and objects from database for validation purposes
        self.available_sequences = self.get_available_sequences()
        self.available_objects = self.get_available_objects()

    def get_available_sequences(self) -> List[str]:
        """Fetch available sequence names from sequence_library in database"""
        self.cursor.execute("SELECT sequence_name FROM sequence_library")
        available_sequences = [row[0] for row in self.cursor.fetchall()]
        logger.info(f"🟢 Available sequences: {available_sequences}")
        return available_sequences

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
        self.cursor.execute("SELECT object_name FROM camera_vision")
        available_objects = [row[0] for row in self.cursor.fetchall()]
        logger.info(f"🟢 Available objects: {available_objects}")
        return available_objects

    def get_unprocessed_unified_command(self) -> Dict:
        self.cursor.execute(
            """
            SELECT id, unified_command FROM unified_instructions
            WHERE processed = FALSE ORDER BY id DESC LIMIT 1
        """
        )
        result = self.cursor.fetchone()
        return (
            {"id": result["id"], "unified_command": result["unified_command"]}
            if result
            else None
        )

    def get_available_objects_with_colors(self) -> List[str]:
        self.cursor.execute("SELECT object_name, object_color FROM camera_vision")
        return [f"{name} ({color})" for name, color in self.cursor.fetchall()]

    def get_sort_order(self) -> List[str]:
        self.cursor.execute(
            "SELECT object_name, object_color FROM sort_order ORDER BY order_id ASC"
        )
        return [f"{name} ({color})" for name, color in self.cursor.fetchall()]

    def get_task_templates(self) -> Dict[str, List[str]]:
        self.cursor.execute("SELECT task_name, default_sequence FROM task_templates")
        return {row[0]: row[1] for row in self.cursor.fetchall()}

    def refresh_cache(self):
        """Refreshes cached sequences and objects from the database."""
        self.available_sequences = self.get_available_sequences()
        self.available_objects = self.get_available_objects()
        logger.info("🟢 Cache refreshed: sequences and objects updated.")

    def validate_operation(self, operation: Dict) -> bool:
        """Validate operation structure"""
        self.refresh_cache()  # Ensure we're using the latest data

        if operation["sequence_name"] not in self.available_sequences:
            logger.error(f"Invalid sequence name: {operation['sequence_name']}")
            return False

        # Allow empty object names
        if not operation.get("object_name", ""):
            return True

        if operation["object_name"] in self.available_objects:
            return True
        else:
            logger.error(f"Invalid object name: {operation['object_name']}")
            return False

    def extract_json_array(self, raw_response: str) -> List[Dict]:
        import re

        try:
            if not PromptBuilder.validate_llm_json(raw_response):
                raise ValueError(
                    "Invalid JSON format: response must start with [ and end with ]"
                )

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

    def infer_operation_name_from_llm(self, command_text: str) -> str:
        self.cursor.execute("SELECT operation_name FROM operation_library")
        available_operations = [row[0] for row in self.cursor.fetchall()]

        prompt = f"""
        Given the following user command:

        "{command_text}"

        Choose the most appropriate operation name from the list:
        {', '.join(available_operations)}

        Only respond with the exact operation_name string — no extra words or explanation.
        """

        response = ollama.chat(
            model=self.llm_model,
            messages=[
                {
                    "role": "system",
                    "content": "You are a smart classifier for robotic task types.",
                },
                {"role": "user", "content": prompt},
            ],
        )
        result = response["message"]["content"].strip()

        if result not in available_operations:
            raise ValueError(f"LLM returned invalid operation_name: {result}")

        return result

    def get_task_order(self, operation_name: str) -> List[str]:
        self.cursor.execute(
            "SELECT task_order FROM operation_library WHERE operation_name = %s",
            (operation_name,),
        )
        row = self.cursor.fetchone()
        return [s.strip() for s in row[0].split(",")] if row else []

    def generate_operations_from_sort_order(
        self, task_order: List[str], command_id: int
    ) -> List[Dict]:
        self.cursor.execute("SELECT object_name FROM sort_order ORDER BY order_id")
        objects = [row[0] for row in self.cursor.fetchall()]

        self.cursor.execute(
            "SELECT COALESCE(MAX(operation_id), 0) + 1 FROM operation_sequence"
        )
        operation_id_start = self.cursor.fetchone()[0]

        ops = []
        idx = 0

        for obj in objects:
            for seq in task_order:
                self.cursor.execute(
                    "SELECT sequence_id FROM sequence_library WHERE sequence_name = %s",
                    (seq,),
                )
                seq_id_row = self.cursor.fetchone()
                if not seq_id_row:
                    continue

                ops.append(
                    {
                        "operation_id": operation_id_start + idx,
                        "sequence_id": seq_id_row[0],
                        "sequence_name": seq,
                        "object_name": obj,
                        "command_id": command_id,
                    }
                )
                idx += 1

        # Optionally add a final "go_home"
        self.cursor.execute(
            "SELECT sequence_id FROM sequence_library WHERE sequence_name = 'go_home'"
        )
        go_home_seq = self.cursor.fetchone()
        if go_home_seq:
            ops.append(
                {
                    "operation_id": operation_id_start + idx,
                    "sequence_id": go_home_seq[0],
                    "sequence_name": "go_home",
                    "object_name": "",
                    "command_id": command_id,
                }
            )

        return ops

    def process_command(self, unified_command: Dict) -> Tuple[bool, List[Dict]]:
        try:
            self.populate_sort_order_from_llm(unified_command["unified_command"])

            operation_name = self.infer_operation_name_from_llm(
                unified_command["unified_command"]
            )
            task_order = self.get_task_order(operation_name)

            operations = self.generate_operations_from_sort_order(
                task_order, unified_command["id"]
            )

            # Wipe old unprocessed
            self.cursor.execute(
                "UPDATE operation_sequence SET processed = TRUE WHERE processed = FALSE"
            )

            # Insert new
            insert_count = 0
            for op in operations:
                self.cursor.execute(
                    """
                    INSERT INTO operation_sequence
                    (operation_id, sequence_id, sequence_name, object_name, command_id)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (
                        op["operation_id"],
                        op["sequence_id"],
                        op["sequence_name"],
                        op["object_name"],
                        op["command_id"],
                    ),
                )
                insert_count += 1
            logger.info(f"✅ Inserted {insert_count} rows into operation_sequence.")

            # Mark as processed
            self.cursor.execute(
                "UPDATE unified_instructions SET processed = TRUE WHERE id = %s",
                (unified_command["id"],),
            )

            # Auto-populate operation parameter tables
            self.populate_operation_parameters()

            self.conn.commit()
            return True, operations

        except Exception as e:
            logger.error("Failed to process command: %s", e, exc_info=True)
            self.conn.rollback()
            return False, []

    def populate_operation_parameters(self):
        logger.info("Populating operation-specific parameters...")

        # Step 1: Get all unique sequence types planned
        self.cursor.execute("SELECT DISTINCT sequence_name FROM operation_sequence")
        sequence_types = [row[0] for row in self.cursor.fetchall()]

        insert_count = 0
        self.cursor.execute(
            "SELECT COUNT(*) FROM camera_vision WHERE usd_name = 'Slide.usd'"
        )
        slide_usd_count = self.cursor.fetchone()[0]
        if slide_usd_count > 0:

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
                logger.info(f"✅ Inserted {insert_count} rows into pick_op_parameters.")

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
                logger.info(
                    f"✅ Inserted {insert_count} rows into travel_op_parameters."
                )

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
                logger.info(f"✅ Inserted {insert_count} rows into drop_op_parameters.")

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
                logger.info(
                    f"Inserted {insert_count} rows into rotate_state_parameters."
                )
        else:
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
                logger.info(f"✅ Inserted {insert_count} rows into pick_op_parameters.")

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
                        (i + 1, obj, 0.085, "z-axis", False),
                    )
                    insert_count += 1
                logger.info(
                    f"✅ Inserted {insert_count} rows into travel_op_parameters."
                )

            # if "drop" in sequence_types:
            #     self.cursor.execute("DELETE FROM drop_op_parameters")
            #     self.cursor.execute(
            #         "SELECT object_name FROM operation_sequence WHERE sequence_name = 'drop'"
            #     )
            #     drop_data = self.cursor.fetchall()
            #     for i, (obj,) in enumerate(drop_data):
            #         self.cursor.execute(
            #             """
            #             INSERT INTO drop_op_parameters (
            #                 operation_order, object_id, drop_height, operation_status
            #             ) VALUES (%s, %s, %s, %s)
            #             """,
            #             (i + 1, obj, 0.0, False),
            #         )
            #         insert_count += 1
            #     logger.info(f"✅ Inserted {insert_count} rows into drop_op_parameters.")

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
                logger.info(
                    f"Inserted {insert_count} rows into rotate_state_parameters."
                )

        self.conn.commit()
        logger.info("✅ Operation-specific parameter tables updated.")

    def extract_sort_order_from_llm(self, command_text: str) -> List[Tuple[str, str]]:
        try:
            logger.info("🧠 Extracting sort order using LLM...")
            prompt = PromptBuilder.sort_order_prompt(command_text)
            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    PromptBuilder.sort_order_system_msg(),
                    {"role": "user", "content": prompt},
                ],
            )

            parsed = self.extract_json_array(response["message"]["content"])
            if not isinstance(parsed, list):
                logger.warning("⚠️ Unexpected format from LLM sort extraction.")
                return []

            results = []
            for item in parsed:
                object_name = (item.get("object_name") or "").strip()
                object_color = (item.get("object_color") or "").strip()
                results.append((object_name, object_color))

            logger.info(f"✅ Extracted sort order: {results}")
            return results

        except Exception as e:
            logger.error(
                "❌ Failed to extract sort order using LLM: %s", str(e), exc_info=True
            )
            return []

    def populate_sort_order_from_llm(self, command_text: str) -> None:
        try:
            logger.info("🧠 Asking LLM to extract sort order...")

            extracted = self.extract_sort_order_from_llm(command_text)

            if not extracted:
                logger.warning("⚠️ No sort order to insert.")
                return

            # Clear previous sort_order
            self.cursor.execute("DELETE FROM sort_order")

            # Fetch color-to-object_name mapping from camera_vision
            self.cursor.execute("SELECT object_name, object_color FROM camera_vision")
            camera_color_map = self.cursor.fetchall()
            color_to_names = {}
            for name, color in camera_color_map:
                color_to_names.setdefault(color.lower(), []).append(name)

            inserted = []
            for item in extracted:
                color = item[1].lower()
                name_list = color_to_names.get(color, [])
                if not name_list:
                    logger.warning(f"⚠️ No match in camera_vision for color: {color}")
                    continue
                obj_name = name_list.pop(0)  # Use and remove to avoid duplicates
                self.cursor.execute(
                    "INSERT INTO sort_order (object_name, object_color) VALUES (%s, %s)",
                    (obj_name, color),
                )
                inserted.append((obj_name, color))

            logger.info(f"✅ sort_order table populated: {inserted}")

        except Exception as e:
            logger.error(
                "❌ Failed to populate sort_order table: %s", str(e), exc_info=True
            )

    def run_processing_cycle(self):
        """
        Process the latest unprocessed unified command
        """
        logger.info("🟢 Checking for new unified_commands...")
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
            logger.info("🟡 No unprocessed unified_commands found")

    def close(self):
        """Close the persistent SQLite connection."""
        if self.conn:
            self.conn.close()
            self.conn = None
            logger.info("🟢 Database connection closed.")


if __name__ == "__main__":
    processor = CommandProcessor(llm_model="mistral:latest")
    # Register the close method so it gets called when the program exits
    atexit.register(processor.close)
    processor.run_processing_cycle()

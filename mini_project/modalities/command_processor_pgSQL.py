# modalities/command_processor.py


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

from config.app_config import setup_logging
from mini_project.database.connection import get_connection

# === Logging Setup ===
debug_mode = os.getenv("DEBUG", "0") in ["1", "true", "True"]
log_level = os.getenv("LOG_LEVEL", "DEBUG" if debug_mode else "INFO").upper()
setup_logging(level=getattr(logging, log_level))
logger = logging.getLogger("CommandProcessor")

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
        self.system_prompt = self._build_system_prompt()

    def _build_system_prompt(self):
        return """
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
            Extract and return the desired sort order mentioned in the instruction as an array of objects, each with object_name and/or object_color.
            This list must reflect the exact intended sort order if mentioned (e.g. "green then pink then orange").
            If the user says to sort "all slides by color", you must extract multiple entries for the same color.
            List each object_color for each object you expect to sort based on the scene (e.g. two pink slides = two entries).
            Only include colors that are known from the camera_vision.
            After sorting by color, add sort order to sort_order here: {sort_order}

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

    def _build_sort_order_prompt(self, command_text: str) -> str:
        return f"""
        Given the following user instruction:
        \"{command_text}\"

        Extract the desired sort order as a JSON array of objects.
        Each item should include:
        - object_name (if mentioned)
        - object_color (if used for sorting)

        Respond only with a clean JSON array.
        """
    def _sort_order_system_msg(self) -> Dict:
        return {
            "role": "system",
            "content": "You are a planner that helps extract object sorting order from commands."
        }


    def get_available_sequences(self) -> List[str]:
        """Fetch available sequence names from sequence_library in database"""
        self.cursor.execute("SELECT sequence_name FROM sequence_library")
        available_sequences = [row[0] for row in self.cursor.fetchall()]
        logger.info(f"Available sequences: {available_sequences}")
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
        logger.info(f"Available objects: {available_objects}")
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

    def validate_operation(self, operation: Dict) -> bool:
        """Validate operation structure"""
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

            # Step: Extract sort preference and populate sort_order before planning
            self.populate_sort_order_from_llm(unified_command["unified_command"])

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

        # ✅ 1. Fetch color-ordered object names from sort_order
        self.cursor.execute(
            "SELECT object_name, object_color FROM sort_order ORDER BY order_id"
        )
        sort_order_rows = self.cursor.fetchall()

        # ✅ 2. Build a mapping: color → queue of object_names (preserves sort order)
        from collections import defaultdict, deque

        color_to_objects = defaultdict(deque)
        for obj_name, color in sort_order_rows:
            color_to_objects[color.strip().lower()].append(obj_name)

        # ✅ 3. Resolve placeholder object names in the plan
        resolved_operations = []
        for op in valid_operations:
            obj_raw = op.get("object_name", "").lower()

            # Try to extract color keyword from object name
            extracted_color = None
            for known_color in color_to_objects:
                if known_color in obj_raw:
                    extracted_color = known_color
                    break

            # Replace with object name from sort_order
            if extracted_color and op["sequence_name"] in [
                "pick",
                "travel",
                "drop",
            ]:
                if color_to_objects[extracted_color]:
                    op["object_name"] = color_to_objects[extracted_color].popleft()

            resolved_operations.append(op)

        # 👉 Ensure resolved_operations are ordered based on sort_order.order_id
        self.cursor.execute("SELECT object_name FROM sort_order ORDER BY order_id")
        ordered_object_names = [row[0] for row in self.cursor.fetchall()]

        def sort_key(op):
            obj = op.get("object_name", "")
            return (
                ordered_object_names.index(obj)
                if obj in ordered_object_names
                else float("inf")
            )

        sorted_resolved_ops = sorted(resolved_operations, key=sort_key)

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

                for idx, op in enumerate(sorted_resolved_ops):

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
                    (
                        unified_command["unified_command"],
                        json.dumps(sorted_resolved_ops),
                    ),
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

    def extract_sort_order_from_llm(self, command_text: str) -> List[Tuple[str, str]]:
        try:
            logger.info("🧠 Extracting sort order using LLM...")
            prompt = self._build_sort_order_prompt(command_text)
            response = ollama.chat(
                model=self.llm_model,
                messages=[
                    self._sort_order_system_msg(),
                    {"role": "user", "content": prompt},
                ],
            )

            parsed = self.extract_json_array(response["message"]["content"])
            if not isinstance(parsed, list):
                logger.warning("⚠️ Unexpected format from LLM sort extraction.")
                return []

            results = []
            for item in parsed:
                object_name = item.get("object_name", "").strip()
                object_color = item.get("object_color", "").strip()
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
    processor = CommandProcessor(llm_model="mistral:latest")
    # Register the close method so it gets called when the program exits
    atexit.register(processor.close)
    processor.run_processing_cycle()

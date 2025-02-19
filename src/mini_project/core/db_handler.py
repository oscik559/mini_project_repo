# core/db_handler.py

import atexit
import logging
import sqlite3
from datetime import datetime
from functools import wraps
from typing import Dict, List, Optional, Tuple

from config.app_config import DB_PATH, setup_logging

# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("dbHandler")


class DatabaseHandler:
    """
    A class to handle database operations, including table creation, schema updates, and data population.
    """

    def __init__(self, db_name: str = DB_PATH) -> None:
        """
        Initialize the DatabaseHandler.

        Args:
            db_name (str): Path to the SQLite database file. Defaults to DB_PATH from config.
        """
        self.db_name = db_name
        self.conn = sqlite3.connect(self.db_name, timeout=60)
        self.conn.execute("PRAGMA foreign_keys = ON")
        self.conn.execute("PRAGMA journal_mode=WAL;")  # WAL mode for concurrency
        self.cursor = self.conn.cursor()
        self.initialize_database()

    def initialize_database(self) -> None:
        """
        Initialize the database by creating tables and updating schemas.
        """
        self.create_tables()
        self.update_table_schemas()
        self.create_indexes()

    def create_tables(self) -> None:
        """
        Create all necessary tables if they do not exist.
        """
        tables = {
            "sequence_library": """
                CREATE TABLE IF NOT EXISTS sequence_library (
                    sequence_id INTEGER PRIMARY KEY,
                    sequence_name TEXT NOT NULL,
                    skill_name TEXT,
                    node_name TEXT,
                    description TEXT,
                    conditions TEXT,
                    post_conditions TEXT,
                    is_runnable_count INTEGER,
                    is_runnable_condition TEXT,
                    is_runnable_exit BOOLEAN
                );
            """,
            "states": """
                CREATE TABLE IF NOT EXISTS states (
                    task_id INTEGER PRIMARY KEY,
                    task_name TEXT NOT NULL,
                    description TEXT,
                    conditions TEXT,
                    post_conditions TEXT,
                    sequence_id INTEGER,
                    FOREIGN KEY (sequence_id) REFERENCES sequence_library (sequence_id) ON DELETE CASCADE
                );
            """,
            "operation_sequence": """
                CREATE TABLE IF NOT EXISTS operation_sequence (
                    sequence_id INTEGER PRIMARY KEY,
                    operation_id INTEGER NOT NULL,
                    sequence_name TEXT NOT NULL,
                    object_name TEXT
                );
            """,
            "screw_op_parameters": """
                CREATE TABLE IF NOT EXISTS screw_op_parameters (
                    sequence_id INTEGER PRIMARY KEY,
                    operation_order INTEGER NOT NULL,
                    object_id TEXT NOT NULL,
                    rotation_dir BOOLEAN NOT NULL,
                    number_of_rotations INTEGER NOT NULL,
                    current_rotation INTEGER NOT NULL,
                    operation_status BOOLEAN NOT NULL
                );
            """,
            "camera_vision": """
                CREATE TABLE IF NOT EXISTS camera_vision (
                    object_id INTEGER PRIMARY KEY,
                    object_name TEXT NOT NULL,
                    object_color TEXT NOT NULL,
                    color_code TEXT,
                    pos_x FLOAT NOT NULL,
                    pos_y FLOAT NOT NULL,
                    pos_z FLOAT NOT NULL,
                    rot_x FLOAT NOT NULL,
                    rot_y FLOAT NOT NULL,
                    rot_z FLOAT NOT NULL,
                    usd_name TEXT NOT NULL,
                    last_detected TIMESTAMP DEFAULT (datetime('now','localtime'))
                );
            """,
            "sort_order": """
                CREATE TABLE IF NOT EXISTS sort_order (
                    sequence_id INTEGER PRIMARY KEY,
                    object_name TEXT NOT NULL,
                    object_color TEXT NOT NULL
                );
            """,
            "users": """
                CREATE TABLE IF NOT EXISTS users (
                    user_id INTEGER PRIMARY KEY,
                    first_name TEXT NOT NULL,
                    last_name TEXT NOT NULL,
                    liu_id TEXT UNIQUE,
                    email TEXT UNIQUE,
                    role TEXT NOT NULL DEFAULT 'guest' CHECK(role IN ('admin','operator','guest')),
                    preferences TEXT,
                    profile_image_path TEXT,
                    user_interaction_memory TEXT,
                    face_encoding BLOB,
                    voice_embedding BLOB,
                    created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
                    last_updated TIMESTAMP DEFAULT (datetime('now','localtime'))
                );
            """,
            # "instructions": """
            #     CREATE TABLE IF NOT EXISTS instructions (
            #         id INTEGER PRIMARY KEY AUTOINCREMENT,
            #         session_id TEXT NOT NULL,
            #         timestamp DATETIME DEFAULT (datetime('now','localtime')),
            #         user_id INTEGER,
            #         modality TEXT,
            #         language TEXT,
            #         instruction_type TEXT,
            #         processed BOOLEAN DEFAULT FALSE,
            #         transcribed_text TEXT,
            #         gesture_type TEXT,
            #         gesture_text TEXT,
            #         natural_description TEXT,
            #         hand_label TEXT,
            #         sync_id INTEGER UNIQUE,
            #         confidence FLOAT CHECK(confidence BETWEEN 0 AND 1),
            #         FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
            #     );
            # """,
            # Add new table for voice commands
            "voice_instructions": """
                CREATE TABLE IF NOT EXISTS voice_instructions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id TEXT NOT NULL,
                    timestamp DATETIME DEFAULT (datetime('now','localtime')),
                    transcribed_text TEXT NOT NULL,
                    confidence REAL,
                    language TEXT NOT NULL,
                    processed BOOLEAN DEFAULT FALSE
                );
            """,
            # Add new table for gesture commands
            "gesture_instructions": """
                CREATE TABLE IF NOT EXISTS gesture_instructions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id TEXT NOT NULL,
                    timestamp DATETIME DEFAULT (datetime('now','localtime')),
                    gesture_text TEXT NOT NULL,
                    natural_description TEXT,
                    confidence REAL,
                    hand_label TEXT,
                    processed BOOLEAN DEFAULT FALSE
                );
            """,
            "gesture_library": """
                CREATE TABLE IF NOT EXISTS gesture_library (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    gesture_type TEXT UNIQUE NOT NULL,
                    gesture_text TEXT NOT NULL,
                    natural_description TEXT,
                    config JSON
                );
            """,
            "unified_instructions": """
                CREATE TABLE IF NOT EXISTS unified_instructions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id TEXT,
                    timestamp DATETIME,
                    liu_id TEXT,
                    voice_command TEXT,
                    gesture_command TEXT,
                    unified_command TEXT,
                    confidence FLOAT CHECK(confidence BETWEEN 0 AND 1),
                    processed BOOLEAN DEFAULT FALSE,
                    FOREIGN KEY (liu_id) REFERENCES users(liu_id) ON DELETE CASCADE
                );
            """,
            "interaction_memory": """
                CREATE TABLE IF NOT EXISTS interaction_memory (
                    interaction_id INTEGER PRIMARY KEY,
                    user_id INTEGER,
                    instruction_id INTEGER,
                    interaction_type TEXT,
                    data TEXT,
                    start_time TIMESTAMP,  -- Start of the conversation group (e.g., start of the day)
                    end_time TIMESTAMP,    -- End of the conversation group (e.g., end of the day)
                    timestamp TIMESTAMP DEFAULT (datetime('now','localtime')),
                    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
                    FOREIGN KEY (instruction_id) REFERENCES unified_instructions(id) ON DELETE CASCADE
                );
            """,
            "skill_library": """
                CREATE TABLE IF NOT EXISTS skill_library (
                    skill_id INTEGER PRIMARY KEY,
                    skill_name TEXT NOT NULL UNIQUE,
                    description TEXT,
                    parameters TEXT,
                    required_capabilities TEXT,
                    average_duration FLOAT
                );
            """,
            # Add new table for security audit
            "access_logs": """
                CREATE TABLE IF NOT EXISTS access_logs (
                    log_id INTEGER PRIMARY KEY,
                    user_id INTEGER NOT NULL,
                    action_type TEXT NOT NULL,
                    target_table TEXT,
                    timestamp DATETIME DEFAULT (datetime('now','localtime')),
                    FOREIGN KEY (user_id) REFERENCES users(user_id)
                );
            """,
            "simulation_results": """
                CREATE TABLE IF NOT EXISTS simulation_results (
                    simulation_id INTEGER PRIMARY KEY,
                    instruction_id INTEGER,
                    success BOOLEAN,
                    metrics TEXT,
                    error_log TEXT,
                    timestamp TIMESTAMP DEFAULT (datetime('now','localtime')),
                    FOREIGN KEY (instruction_id) REFERENCES unified_instructions(id) ON DELETE CASCADE
                );
            """,
            "task_preferences": """
                CREATE TABLE IF NOT EXISTS task_preferences (
                    preference_id INTEGER PRIMARY KEY,
                    user_id INTEGER,
                    task_id TEXT,
                    task_name TEXT,
                    preference_data TEXT,
                    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
                );
            """,
            "instruction_operation_sequence": """
                CREATE TABLE IF NOT EXISTS instruction_operation_sequence (
                    task_id INTEGER PRIMARY KEY,
                    instruction_id INTEGER,
                    sequence_id INTEGER,
                    sequence_name TEXT NOT NULL,
                    skill_id INTEGER,
                    skill_name TEXT,
                    object_id INTEGER,
                    object_name TEXT,
                    status TEXT CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')) DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT (datetime('now','localtime')),
                    FOREIGN KEY (instruction_id) REFERENCES unified_instructions(id) ON DELETE CASCADE,
                    FOREIGN KEY (skill_id) REFERENCES skill_library(skill_id),
                    FOREIGN KEY (sequence_id) REFERENCES sequence_library(sequence_id),
                    FOREIGN KEY (object_id) REFERENCES camera_vision(object_id)
                );
            """,
        }
        # for table_name, create_statement in tables.items():
        #     self.cursor.execute(create_statement)
        try:
            for create_statement in tables.values():
                self.cursor.execute(create_statement)
            self.conn.commit()
        except sqlite3.Error as e:
            logger.error(f"Error creating tables: {e}")
            raise

    def create_indexes(self) -> None:
        """
        Create indexes on frequently queried columns to optimize query performance.
        """
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_users_liu_id ON users (liu_id);",
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);",
            "CREATE INDEX IF NOT EXISTS idx_interaction_memory_user_id ON interaction_memory (user_id);",
            "CREATE INDEX IF NOT EXISTS idx_task_preferences_user_id ON task_preferences (user_id);",
            "CREATE INDEX IF NOT EXISTS idx_conv_memory_instruction ON interaction_memory(instruction_id);",
            "CREATE INDEX IF NOT EXISTS idx_skills_name ON skill_library(skill_name);",
            "CREATE INDEX IF NOT EXISTS idx_simulation_instruction ON simulation_results(instruction_id);",
            "CREATE INDEX IF NOT EXISTS idx_operation_sequence_object ON instruction_operation_sequence(object_id);",
            "CREATE INDEX IF NOT EXISTS idx_camera_vision_last_detected ON camera_vision(last_detected);",
            "CREATE INDEX IF NOT EXISTS idx_user_prefs_task ON task_preferences(user_id, task_id);",
            "CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);",
            "CREATE INDEX IF NOT EXISTS idx_voice_session ON voice_instructions(session_id, timestamp);",
            "CREATE INDEX IF NOT EXISTS idx_gesture_session ON gesture_instructions(session_id, timestamp);",
            "CREATE INDEX IF NOT EXISTS idx_unified_liu_id ON unified_instructions(liu_id);",
        ]
        try:
            for index in indexes:
                self.cursor.execute(index)
            self.conn.commit()
        except sqlite3.Error as e:
            logger.error(f"Error creating indexes: {e}")
            raise

    def check_table_schema(self, table_name):
        """Print the schema of a table."""
        self.cursor.execute(f"PRAGMA table_info({table_name})")
        schema = self.cursor.fetchall()

        print(f"Schema of {table_name}:")
        for column in schema:
            print(column)

    def update_table_schemas(self):
        """Ensure all tables have the expected schema."""
        schemas = {
            "sequence_library": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("sequence_name", "TEXT NOT NULL"),
                ("skill_name", "TEXT"),
                ("node_name", "TEXT"),
                ("description", "TEXT"),
                ("conditions", "TEXT"),
                ("post_conditions", "TEXT"),
                ("is_runnable_count", "INTEGER"),
                ("is_runnable_condition", "TEXT"),
                ("is_runnable_exit", "BOOLEAN"),
            ],
            "states": [
                ("task_id", "INTEGER PRIMARY KEY"),
                ("task_name", "TEXT NOT NULL"),
                ("description", "TEXT"),
                ("conditions", "TEXT"),
                ("post_conditions", "TEXT"),
                ("sequence_id", "INTEGER"),
            ],
            "operation_sequence": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("operation_id", "INTEGER NOT NULL"),
                ("sequence_name", "TEXT NOT NULL"),
                ("object_name", "TEXT"),
            ],
            "screw_op_parameters": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("operation_order", "INTEGER NOT NULL"),
                ("object_id", "TEXT NOT NULL"),
                ("rotation_dir", "BOOLEAN NOT NULL"),
                ("number_of_rotations", "INTEGER NOT NULL"),
                ("current_rotation", "INTEGER NOT NULL"),
                ("operation_status", "BOOLEAN NOT NULL"),
            ],
            "camera_vision": [
                ("object_id", "INTEGER PRIMARY KEY"),
                ("object_name", "TEXT NOT NULL"),
                ("object_color", "TEXT NOT NULL"),
                ("color_code", "TEXT"),
                ("pos_x", "FLOAT NOT NULL"),
                ("pos_y", "FLOAT NOT NULL"),
                ("pos_z", "FLOAT NOT NULL"),
                ("rot_x", "FLOAT NOT NULL"),
                ("rot_y", "FLOAT NOT NULL"),
                ("rot_z", "FLOAT NOT NULL"),
                ("usd_name", "TEXT NOT NULL"),
                ("last_detected", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
            ],
            "sort_order": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("object_name", "TEXT NOT NULL"),
                ("object_color", "TEXT NOT NULL"),
            ],
            "users": [
                ("user_id", "INTEGER PRIMARY KEY"),
                ("first_name", "TEXT NOT NULL"),
                ("last_name", "TEXT NOT NULL"),
                ("liu_id", "TEXT UNIQUE"),
                ("email", "TEXT UNIQUE"),
                ("role", "TEXT NOT NULL"),
                ("preferences", "TEXT"),
                ("profile_image_path", "TEXT"),
                ("user_interaction_memory", "TEXT"),
                ("face_encoding", "BLOB"),
                ("voice_embedding", "BLOB"),
                ("created_at", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
                ("last_updated", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
            ],
            "interaction_memory": [
                ("interaction_id", "INTEGER PRIMARY KEY"),
                ("user_id", "INTEGER"),
                ("instruction_id", "INTEGER"),
                ("interaction_type", "TEXT"),
                ("data", "TEXT"),
                ("start_time", "TIMESTAMP"),
                ("end_time", "TIMESTAMP"),
                ("timestamp", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
            ],
            "skill_library": [
                ("skill_id", "INTEGER PRIMARY KEY"),
                ("skill_name", "TEXT NOT NULL UNIQUE"),
                ("description", "TEXT"),
                ("parameters", "TEXT"),
                ("required_capabilities", "TEXT"),
                ("average_duration", "FLOAT"),
            ],
            "simulation_results": [
                ("simulation_id", "INTEGER PRIMARY KEY"),
                ("instruction_id", "INTEGER"),
                ("success", "BOOLEAN"),
                ("metrics", "TEXT"),
                ("error_log", "TEXT"),
                ("timestamp", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
            ],
            "task_preferences": [
                ("preference_id", "INTEGER PRIMARY KEY"),
                ("user_id", "INTEGER"),
                ("task_id", "TEXT"),
                ("task_name", "TEXT"),
                ("preference_data", "TEXT"),
            ],
            # "instructions": [
            #     ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
            #     ("session_id", "TEXT NOT NULL"),
            #     ("timestamp", "DATETIME DEFAULT (datetime('now','localtime'))"),
            #     ("user_id", "INTEGER"),
            #     ("modality", "TEXT"),
            #     ("language", "TEXT"),
            #     ("instruction_type", "TEXT"),
            #     ("processed", "BOOLEAN DEFAULT FALSE"),
            #     ("transcribed_text", "TEXT"),
            #     ("gesture_type", "TEXT"),
            #     ("gesture_text", "TEXT"),
            #     ("natural_description", "TEXT"),
            #     ("hand_label", "TEXT"),
            #     ("sync_id", "INTEGER UNIQUE"),
            #     ("confidence", "FLOAT CHECK(confidence BETWEEN 0 AND 1)"),
            # ],
            "instruction_operation_sequence": [
                ("task_id", "INTEGER PRIMARY KEY"),
                ("instruction_id", "INTEGER"),
                ("skill_id", "INTEGER"),
                ("skill_name", "TEXT"),
                ("sequence_id", "INTEGER"),
                ("sequence_name", "TEXT NOT NULL"),
                ("object_id", "INTEGER"),
                ("object_name", "TEXT"),
                (
                    "status",
                    "TEXT CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')) DEFAULT 'pending'",
                ),
                ("created_at", "TIMESTAMP DEFAULT (datetime('now','localtime'))"),
            ],
        }

        for table_name, expected_columns in schemas.items():
            self.validate_table_schema(table_name, expected_columns)

    def validate_table_schema(
        self, table_name: str, expected_columns: List[Tuple[str, str]]
    ) -> None:
        """
        Validate and update table schemas.

        Args:
            table_name (str): Name of the table.
            expected_columns (List[Tuple[str, str]]): List of (column_name, column_definition) tuples.
        """
        self.cursor.execute(f"PRAGMA table_info({table_name})")
        existing_columns = {col[1]: col[2] for col in self.cursor.fetchall()}

        # Add missing columns with constraints
        for column_name, column_def in expected_columns:
            if column_name not in existing_columns:
                try:
                    self.cursor.execute(
                        f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_def}"
                    )
                    logger.info(f"Added column '{column_name}' to '{table_name}'")
                except sqlite3.OperationalError as e:
                    logger.info(
                        f"Schema update failed for {table_name}.{column_name}: {str(e)}"
                    )

        self.conn.commit()

    def clear_tables(self):
        """Clear tables in the correct order to prevent foreign key constraint failures."""
        try:
            with self.conn:
                self._clear_tables_ordered()
        except sqlite3.Error as e:
            logger.error(f"Error clearing tables: {e}")
            raise

    def _clear_tables_ordered(self):
        self.cursor.execute("PRAGMA foreign_keys = OFF;")

        dependent_tables = [
            "interaction_memory",
            "task_preferences",
            "unified_instructions",
            "instruction_operation_sequence",
            "simulation_results",
        ]
        for table in dependent_tables:
            self.cursor.execute(f"DELETE FROM {table}")

        parent_tables = [
            "users",
            "sequence_library",
            "states",
            "operation_sequence",
            "screw_op_parameters",
            "camera_vision",
            "sort_order",
            "skill_library",
        ]
        for table in parent_tables:
            self.cursor.execute(f"DELETE FROM {table}")

        self.cursor.execute("PRAGMA foreign_keys = ON;")

    def populate_database(self):  # sourcery skip: extract-method
        """Populate the database with initial data as a single transaction."""
        try:
            with self.conn:
                # Clear existing data
                self.clear_tables()

                # Populate parent tables first
                self.populate_users()  # Must come first

                self.populate_sequence_library()
                self.populate_skill_library()
                self.populate_gesture_library()

                # Now populate child tables
                self.populate_states()
                self.populate_operation_sequence()
                # self.populate_camera_vision()
                self.populate_sort_order()
                self.populate_task_preferences()
                self.populate_interaction_memory()
                self.populate_simulation_results()

                # self.populate_instructions()
                # self.populate_screw_op_parameters()
                # self.populate_instruction_operation_sequence()

            logger.info("Database populated successfully.")
        except sqlite3.Error as e:
            logger.error(f"Database population failed: {str(e)}")

    def populate_sequence_library(self):
        """
        Populate sequence_library table with provided data.

        Args:
            data (List[Tuple]): List of tuples containing sequence data.
        """
        sequence_library = [
            (
                "pick",
                "PickBlockRd",
                "Pick up an object",
                "gripper is clear",
                "object in gripper",
                1,
                "aaa",
                0,
            ),
            (
                "travel",
                "ReachToPlacementRd",
                "Move to the target location",
                "object in gripper",
                "at target location",
                1,
                "aaa",
                0,
            ),
            (
                "drop",
                "DropRd",
                "Drop the object",
                "at target location",
                "object dropped",
                1,
                "aaa",
                0,
            ),
            (
                "screw",
                "ScrewRd",
                "Screw the object two times",
                "task complete",
                "robot at home position",
                1,
                "thresh_met and self.context.gripper_has_block",
                1,
            ),
            (
                "go_home",
                "GoHome",
                "Return to the home position",
                "task complete",
                "robot at home position",
                1,
                "aaa",
                0,
            ),
        ]
        self.cursor.executemany(
            "INSERT INTO sequence_library (sequence_name, node_name, description, conditions, post_conditions, is_runnable_count, is_runnable_condition, is_runnable_exit) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            sequence_library,
        )

    def populate_states(self):
        """
        Populate states table with provided data.

        Args:
            data (List[Tuple]): List of tuples containing state data.
        """
        states = [
            (
                "LiftState",
                "Lift an object vertically",
                "gripper is clear",
                "object in gripper",
                1,
            ),
            (
                "SlideState",
                "Slide an object along X-axis",
                "object in gripper",
                "at target location",
                1,
            ),
        ]
        self.cursor.executemany(
            "INSERT INTO states (task_name, description, conditions, post_conditions, sequence_id) VALUES (?, ?, ?, ?, ?)",
            states,
        )

    def populate_operation_sequence(self):
        operation_sequence = [
            (1, "travel", ""),
            (1, "pick", "BlueCube"),
            (1, "travel", ""),
            (1, "screw", "BlueCube"),
            (1, "drop", ""),
            (2, "travel", ""),
            (2, "pick", "YellowCube"),
            (2, "travel", ""),
            (2, "screw", "YellowCube"),
            (2, "drop", ""),
            (3, "travel", ""),
            (3, "pick", "GreenCube"),
            (3, "travel", ""),
            (3, "screw", "GreenCube"),
            (3, "drop", ""),
            (4, "travel", ""),
            (4, "pick", "RedCube"),
            (4, "travel", ""),
            (4, "screw", "RedCube"),
            (4, "drop", ""),
        ]
        self.cursor.executemany(
            "INSERT INTO operation_sequence (operation_id, sequence_name, object_name) VALUES (?, ?, ?)",
            operation_sequence,
        )

    def populate_camera_vision(self):
        camera_vision = [
            (
                "RedCube",
                "Red",
                "[0.7, 0.0, 0.0]",
                0.3,
                -0.4,
                0.026,
                0.0,
                0.0,
                0.0,
                "Cube.usd",
            ),
            (
                "BlueCube",
                "Blue",
                "[0.0, 0.0, 0.7]",
                0.43,
                -0.4,
                0.026,
                0.0,
                0.0,
                0.0,
                "Cube.usd",
            ),
            (
                "YellowCube",
                "Yellow",
                "[0.7, 0.7, 0.0]",
                0.56,
                -0.4,
                0.026,
                0.0,
                0.0,
                0.0,
                "Cube.usd",
            ),
        ]
        self.cursor.executemany(
            "INSERT INTO camera_vision (object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            camera_vision,
        )

    def populate_sort_order(self):
        sort_order = [
            ("RedCube", "Red"),
            ("BlueCube", "Blue"),
            ("YellowCube", "Yellow"),
        ]
        self.cursor.executemany(
            "INSERT INTO sort_order (object_name, object_color) VALUES (?, ?)",
            sort_order,
        )

    def populate_users(self):
        users = [
            (
                "Oscar",
                "Ikechukwu",
                "oscik559",
                "oscik559@student.liu.se",
                "admin",
                '{"likes": ["AI", "Robotics"]}',
                "/images/oscar.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
            ),
            (
                "Rahul",
                "Chiramel",
                "rahch515",
                "rahch515@student.liu.se",
                "admin",
                '{"likes": ["Aeroplanes", "Automation"]}',
                "/images/rahul.jpg",
                '{"last_task": "Screw object", "successful_tasks": 10}',
            ),
            (
                "Sanjay",
                "Nambiar",
                "sanna58",
                "sanjay.nambiar@liu.se",
                "operator",
                '{"likes": ["Programming", "Machine Learning"]}',
                "/images/sanjay.jpg",
                '{"last_task": "Slide object", "successful_tasks": 7}',
            ),
            (
                "Mehdi",
                "Tarkian",
                "mehta77",
                "mehdi.tarkian@liu.se",
                "guest",
                '{"likes": ["Running", "Cats"]}',
                "/images/mehdi.jpg",
                '{"last_task": "Drop object", "successful_tasks": 2}',
            ),
        ]
        self.cursor.executemany(
            "INSERT INTO users (first_name, last_name, liu_id, email, role, preferences, profile_image_path, user_interaction_memory) VALUES (?, ?, ?,?, ?, ?, ?, ?)",
            users,
        )

    def populate_task_preferences(self):
        task_preferences = [
            (1, "Pick Object", '{"time": "morning", "location": "shelf"}'),
            (2, "Place Object", '{"time": "afternoon", "location": "table"}'),
            (1, "Inspect Object", '{"tools": ["camera", "gripper"]}'),
        ]
        self.cursor.executemany(
            "INSERT INTO task_preferences (user_id, task_name, preference_data) VALUES (?, ?, ?)",
            task_preferences,
        )

    def populate_interaction_memory(self):
        interactions = [
            (
                1,
                1,
                "task_query",
                '{"task": "Pick Object"}',
                "2023-10-01 09:00:00",
                "2023-10-01 17:00:00",
            ),
            (
                2,
                1,
                "preference_update",
                '{"preference": {"time": "morning"}}',
                "2023-10-01 09:00:00",
                "2023-10-01 17:00:00",
            ),
            (
                1,
                2,
                "task_execution",
                '{"status": "success", "task": "Place Object"}',
                "2023-10-02 09:00:00",
                "2023-10-02 17:00:00",
            ),
        ]
        self.cursor.executemany(
            "INSERT INTO interaction_memory (user_id, instruction_id, interaction_type, data, start_time, end_time) VALUES (?, ?, ?, ?, ?, ?)",
            interactions,
        )

    def populate_skill_library(self):
        skill_library = [
            (
                "pick",
                "Pick up object",
                '{"gripper_force": 0.5}',
                '{"gripper": true}',
                2.5,
            ),
            ("place", "Place object", '{"precision": 0.01}', '{"vision": true}', 3.0),
        ]
        self.cursor.executemany(
            "INSERT INTO skill_library (skill_name, description, parameters, required_capabilities, average_duration) VALUES (?, ?, ?, ?, ?)",
            skill_library,
        )

    def populate_simulation_results(self):
        results = [
            (1, True, '{"accuracy": 0.95, "time_taken": 2.5}', "No errors"),
            (2, False, '{"accuracy": 0.8, "time_taken": 3.0}', "Gripper misalignment"),
        ]
        self.cursor.executemany(
            "INSERT INTO simulation_results (instruction_id, success, metrics, error_log) VALUES (?, ?, ?, ?)",
            results,
        )

    def require_role(allowed_roles):
        """
        Decorator to require one or more roles to access a function.
        `allowed_roles` can be a single role (string) or an iterable of roles.
        """

        def decorator(func):
            @wraps(func)
            def wrapper(self, user_id, *args, **kwargs):
                user_role = self.get_user_role(user_id)
                if isinstance(allowed_roles, (list, tuple, set)):
                    if user_role not in allowed_roles:
                        raise PermissionError(
                            f"Access denied. Requires one of the roles: {allowed_roles}"
                        )
                else:
                    if user_role != allowed_roles:
                        raise PermissionError(
                            f"Access denied. Requires role: {allowed_roles}"
                        )
                return func(self, user_id, *args, **kwargs)

            return wrapper

        return decorator

    def get_user_role(self, user_id):
        """Fetch user role from the database."""
        query = "SELECT role FROM users WHERE user_id = ?"
        self.cursor.execute(query, (user_id,))
        result = self.cursor.fetchone()
        return result[0] if result else "guest"

    def populate_gesture_library(self):
        gesture_library = [
            (
                "thumbs_up",
                "Approval",
                "The thumb is raised above the index finger.",
                '{"threshold": 0.0}',
            ),
            (
                "open_hand",
                "Stop",
                "All fingers are extended, signaling stop.",
                '{"threshold": 0.0}',
            ),
            (
                "pointing",
                "Select Object",
                "The index finger is extended while other fingers are curled.",
                '{"threshold": 0.0}',
            ),
            (
                "closed_fist",
                "Grab",
                "The hand is clenched into a fist.",
                '{"threshold": 0.0}',
            ),
            (
                "victory",
                "Confirm",
                "The hand forms a V-shape with the index and middle fingers extended.",
                '{"threshold": 0.0}',
            ),
            (
                "ok_sign",
                "OK",
                "The thumb and index finger are touching to form a circle.",
                '{"threshold": 0.05}',
            ),
        ]
        query = """
            INSERT OR IGNORE INTO gesture_library (gesture_type, gesture_text, natural_description, config)
            VALUES (?, ?, ?, ?)
        """
        self.cursor.executemany(query, gesture_library)
        self.conn.commit()

    def close(self):
        """Close the database connection."""
        self.conn.close()


if __name__ == "__main__":
    db_handler = DatabaseHandler()
    db_handler.populate_database()
    atexit.register(db_handler.close)

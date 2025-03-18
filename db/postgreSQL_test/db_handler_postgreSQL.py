# core/db_handler_postgreSQL.py

import atexit
import logging
from datetime import datetime
from typing import Dict, List, Optional, Tuple

import psycopg2
from psycopg2 import Error as Psycopg2Error
from psycopg2 import sql

# DB_URL = "postgresql://oscar:oscik559@localhost:5432/sequences_db"
DB_URL = "dbname=sequences_db user=oscar password=oscik559 host=localhost"

# # from config.app_config import (
#     setup_logging,  # e.g., "dbname=mydb user=myuser password=mypass host=localhost"
# )
# from config.app_config import (
#     DB_URL,
# )

# Initialize logging with desired level (optional)
# setup_logging(level=logging.INFO)
logger = logging.getLogger("dbHandler")


class DatabaseHandler:
    """
    A class to handle database operations using PostgreSQL.
    """

    def __init__(self, db_url: str = DB_URL) -> None:
        """
        Initialize the DatabaseHandler.

        Args:
            db_url (str): PostgreSQL connection URL.
        """
        self.db_url = db_url
        try:
            self.conn = psycopg2.connect(self.db_url)
            self.conn.autocommit = False
            self.cursor = self.conn.cursor()
            self.initialize_database()
        except Psycopg2Error as e:
            logger.error(f"Error connecting to PostgreSQL database: {e}")
            raise

    def initialize_database(self) -> None:
        """
        Initialize the database by creating tables and indexes.
        """
        self.create_tables()
        # Skipping dynamic schema updates in PostgreSQL; use migrations instead.
        # self.update_table_schemas()
        self.create_indexes()

    def create_tables(self) -> None:
        """
        Create all necessary tables if they do not exist.
        The tables are created in an order that respects foreign key dependencies.
        """
        tables = {
            "sequence_library": """
                CREATE TABLE IF NOT EXISTS sequence_library (
                    sequence_id SERIAL PRIMARY KEY,
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
            "users": """
                CREATE TABLE IF NOT EXISTS users (
                    user_id SERIAL PRIMARY KEY,
                    first_name TEXT NOT NULL,
                    last_name TEXT NOT NULL,
                    liu_id TEXT UNIQUE,
                    email TEXT UNIQUE,
                    preferences TEXT,
                    profile_image_path TEXT,
                    interaction_memory TEXT,
                    face_encoding BYTEA,
                    voice_embedding BYTEA,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """,
            "skills": """
                CREATE TABLE IF NOT EXISTS skills (
                    skill_id SERIAL PRIMARY KEY,
                    skill_name TEXT NOT NULL UNIQUE,
                    description TEXT,
                    parameters TEXT,
                    required_capabilities TEXT,
                    average_duration REAL
                );
            """,
            "instructions": """
                CREATE TABLE IF NOT EXISTS instructions (
                    id SERIAL PRIMARY KEY,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    user_id INTEGER,
                    modality TEXT CHECK(modality IN ('voice', 'gesture', 'text')),
                    language TEXT NOT NULL,
                    instruction_type TEXT NOT NULL,
                    processed BOOLEAN DEFAULT FALSE,
                    content TEXT,
                    sync_id INTEGER UNIQUE,
                    confidence REAL CHECK(confidence BETWEEN 0 AND 1),
                    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
                );
            """,
            "states": """
                CREATE TABLE IF NOT EXISTS states (
                    task_id SERIAL PRIMARY KEY,
                    task_name TEXT NOT NULL,
                    description TEXT,
                    conditions TEXT,
                    post_conditions TEXT,
                    sequence_id INTEGER,
                    FOREIGN KEY (sequence_id) REFERENCES sequence_library(sequence_id) ON DELETE CASCADE
                );
            """,
            "operation_sequence": """
                CREATE TABLE IF NOT EXISTS operation_sequence (
                    sequence_id SERIAL PRIMARY KEY,
                    operation_id INTEGER,
                    sequence_name TEXT NOT NULL,
                    object_name TEXT
                );
            """,
            "screw_op_parameters": """
                CREATE TABLE IF NOT EXISTS screw_op_parameters (
                    sequence_id SERIAL PRIMARY KEY,
                    operation_order INTEGER,
                    object_id TEXT,
                    rotation_dir BOOLEAN,
                    number_of_rotations INTEGER,
                    current_rotation INTEGER,
                    operation_status BOOLEAN
                );
            """,
            "camera_vision": """
                CREATE TABLE IF NOT EXISTS camera_vision (
                    object_id SERIAL PRIMARY KEY,
                    object_name TEXT NOT NULL,
                    object_color TEXT NOT NULL,
                    color_code TEXT,
                    pos_x REAL NOT NULL,
                    pos_y REAL NOT NULL,
                    pos_z REAL NOT NULL,
                    rot_x REAL NOT NULL,
                    rot_y REAL NOT NULL,
                    rot_z REAL NOT NULL,
                    usd_name TEXT NOT NULL,
                    last_detected TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """,
            "sort_order": """
                CREATE TABLE IF NOT EXISTS sort_order (
                    sequence_id SERIAL PRIMARY KEY,
                    object_name TEXT NOT NULL,
                    object_color TEXT NOT NULL
                );
            """,
            "interaction_memory": """
                CREATE TABLE IF NOT EXISTS interaction_memory (
                    interaction_id SERIAL PRIMARY KEY,
                    user_id INTEGER,
                    instruction_id INTEGER,
                    interaction_type TEXT,
                    data TEXT,
                    start_time TIMESTAMP,
                    end_time TIMESTAMP,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
                    FOREIGN KEY (instruction_id) REFERENCES instructions(id) ON DELETE CASCADE
                );
            """,
            "simulation_results": """
                CREATE TABLE IF NOT EXISTS simulation_results (
                    simulation_id SERIAL PRIMARY KEY,
                    instruction_id INTEGER,
                    success BOOLEAN,
                    metrics TEXT,
                    error_log TEXT,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (instruction_id) REFERENCES instructions(id) ON DELETE CASCADE
                );
            """,
            "task_preferences": """
                CREATE TABLE IF NOT EXISTS task_preferences (
                    preference_id SERIAL PRIMARY KEY,
                    user_id INTEGER,
                    task_id TEXT,
                    task_name TEXT,
                    preference_data TEXT,
                    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
                );
            """,
            "unified_instructions": """
                CREATE TABLE IF NOT EXISTS unified_instructions (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT,
                    timestamp TIMESTAMP,
                    voice_command TEXT,
                    gesture_command TEXT,
                    unified_command TEXT
                );
            """,
            "instruction_operation_sequence": """
                CREATE TABLE IF NOT EXISTS instruction_operation_sequence (
                    task_id SERIAL PRIMARY KEY,
                    instruction_id INTEGER,
                    skill_id INTEGER,
                    skill_name TEXT,
                    sequence_id INTEGER,
                    sequence_name TEXT NOT NULL,
                    object_id INTEGER,
                    object_name TEXT,
                    status TEXT CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')) DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (instruction_id) REFERENCES instructions(id) ON DELETE CASCADE,
                    FOREIGN KEY (skill_id) REFERENCES skills(skill_id),
                    FOREIGN KEY (sequence_id) REFERENCES sequence_library(sequence_id),
                    FOREIGN KEY (object_id) REFERENCES camera_vision(object_id)
                );
            """,
        }
        try:
            for create_statement in tables.values():
                self.cursor.execute(create_statement)
            self.conn.commit()
        except Psycopg2Error as e:
            logger.error(f"Error creating tables: {e}")
            self.conn.rollback()
            raise

    def create_indexes(self) -> None:
        """
        Create indexes on frequently queried columns to optimize query performance.
        """
        indexes = [
            "CREATE INDEX IF NOT EXISTS idx_users_liu_id ON users(liu_id);",
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);",
            "CREATE INDEX IF NOT EXISTS idx_interaction_memory_user_id ON interaction_memory(user_id);",
            "CREATE INDEX IF NOT EXISTS idx_task_preferences_user_id ON task_preferences(user_id);",
            "CREATE INDEX IF NOT EXISTS idx_conv_memory_instruction ON interaction_memory(instruction_id);",
            "CREATE INDEX IF NOT EXISTS idx_skills_name ON skills(skill_name);",
            "CREATE INDEX IF NOT EXISTS idx_simulation_instruction ON simulation_results(instruction_id);",
            "CREATE INDEX IF NOT EXISTS idx_operation_sequence_object ON instruction_operation_sequence(object_id);",
            "CREATE INDEX IF NOT EXISTS idx_camera_vision_last_detected ON camera_vision(last_detected);",
            "CREATE INDEX IF NOT EXISTS idx_user_prefs_task ON task_preferences(user_id, task_id);",
        ]
        try:
            for index in indexes:
                self.cursor.execute(index)
            self.conn.commit()
        except Psycopg2Error as e:
            logger.error(f"Error creating indexes: {e}")
            self.conn.rollback()
            raise

    def update_table_schemas(self):
        """
        Schema validation and dynamic alteration is not implemented for PostgreSQL.
        Consider using a migration tool like Alembic.
        """
        logger.info(
            "Skipping schema update. Use migrations for PostgreSQL schema changes."
        )

    def clear_tables(self):
        """
        Clear all tables using TRUNCATE with RESTART IDENTITY and CASCADE to reset sequences
        and remove all rows, ensuring that foreign key constraints will be satisfied on new inserts.
        """
        try:
            tables = [
                "instruction_operation_sequence",
                "simulation_results",
                "interaction_memory",
                "task_preferences",
                "instructions",
                "states",
                "operation_sequence",
                "screw_op_parameters",
                "camera_vision",
                "sort_order",
                "skills",
                "sequence_library",
                "users",
                "unified_instructions",
            ]
            truncate_query = (
                "TRUNCATE TABLE " + ", ".join(tables) + " RESTART IDENTITY CASCADE;"
            )
            self.cursor.execute(truncate_query)
            self.conn.commit()
        except Psycopg2Error as e:
            logger.error(f"Error clearing tables: {e}")
            self.conn.rollback()
            raise

    def populate_database(self):
        """Populate the database with initial data as a single transaction."""
        try:
            # Clear existing data and reset sequences
            self.clear_tables()

            # Populate parent tables first
            self.populate_users()  # Must come first
            self.populate_sequence_library()
            self.populate_skills()
            self.populate_instructions()  # New method to populate instructions

            # Now populate child tables
            self.populate_states()
            self.populate_operation_sequence()
            self.populate_sort_order()
            self.populate_task_preferences()
            self.populate_interaction_memory()
            self.populate_simulation_results()

            self.conn.commit()
            logger.info("Database populated successfully.")
        except Psycopg2Error as e:
            logger.error(f"Database population failed: {e}")
            self.conn.rollback()

    def populate_sequence_library(self):
        """
        Populate sequence_library table with provided data.
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
                False,  # Boolean value for is_runnable_exit
            ),
            (
                "travel",
                "ReachToPlacementRd",
                "Move to the target location",
                "object in gripper",
                "at target location",
                1,
                "aaa",
                False,
            ),
            (
                "drop",
                "DropRd",
                "Drop the object",
                "at target location",
                "object dropped",
                1,
                "aaa",
                False,
            ),
            (
                "screw",
                "ScrewRd",
                "Screw the object two times",
                "task complete",
                "robot at home position",
                1,
                "thresh_met and self.context.gripper_has_block",
                True,
            ),
            (
                "go_home",
                "GoHome",
                "Return to the home position",
                "task complete",
                "robot at home position",
                1,
                "aaa",
                False,
            ),
        ]
        insert_query = """
            INSERT INTO sequence_library
            (sequence_name, node_name, description, conditions, post_conditions, is_runnable_count, is_runnable_condition, is_runnable_exit)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, sequence_library)

    def populate_users(self):
        users = [
            (
                "Oscar",
                "Ikechukwu",
                "oscik559",
                "oscik559@student.liu.se",
                '{"likes": ["AI", "Robotics"]}',
                "/images/oscar.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
            ),
            (
                "Rahul",
                "Chiramel",
                "rahch515",
                "rahch515@student.liu.se",
                '{"likes": ["Aeroplanes", "Automation"]}',
                "/images/rahul.jpg",
                '{"last_task": "Screw object", "successful_tasks": 10}',
            ),
            (
                "Sanjay",
                "Nambiar",
                "sanna58",
                "sanjay.nambiar@liu.se",
                '{"likes": ["Programming", "Machine Learning"]}',
                "/images/sanjay.jpg",
                '{"last_task": "Slide object", "successful_tasks": 7}',
            ),
            (
                "Mehdi",
                "Tarkian",
                "mehta77",
                "mehdi.tarkian@liu.se",
                '{"likes": ["Running", "Cats"]}',
                "/images/mehdi.jpg",
                '{"last_task": "Drop object", "successful_tasks": 2}',
            ),
        ]
        insert_query = """
            INSERT INTO users (first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, users)

    def populate_skills(self):
        skills = [
            (
                "pick",
                "Pick up object",
                '{"gripper_force": 0.5}',
                '{"gripper": true}',
                2.5,
            ),
            ("place", "Place object", '{"precision": 0.01}', '{"vision": true}', 3.0),
        ]
        insert_query = """
            INSERT INTO skills (skill_name, description, parameters, required_capabilities, average_duration)
            VALUES (%s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, skills)

    def populate_instructions(self):
        """
        Populate instructions table with provided data.
        This ensures that foreign key references in child tables (e.g., interaction_memory, simulation_results)
        will find matching instruction rows.
        """
        instructions = [
            (1, "voice", "en", "command", False, "Pick up object", None, 0.95),
            (2, "text", "en", "command", False, "Place object", None, 0.90),
        ]
        insert_query = """
            INSERT INTO instructions (user_id, modality, language, instruction_type, processed, content, sync_id, confidence)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, instructions)

    def populate_states(self):
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
        insert_query = """
            INSERT INTO states (task_name, description, conditions, post_conditions, sequence_id)
            VALUES (%s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, states)

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
        insert_query = """
            INSERT INTO operation_sequence (operation_id, sequence_name, object_name)
            VALUES (%s, %s, %s);
        """
        self.cursor.executemany(insert_query, operation_sequence)

    def populate_sort_order(self):
        sort_order = [
            ("RedCube", "Red"),
            ("BlueCube", "Blue"),
            ("YellowCube", "Yellow"),
        ]
        insert_query = """
            INSERT INTO sort_order (object_name, object_color)
            VALUES (%s, %s);
        """
        self.cursor.executemany(insert_query, sort_order)

    def populate_task_preferences(self):
        task_preferences = [
            (1, "Pick Object", '{"time": "morning", "location": "shelf"}'),
            (2, "Place Object", '{"time": "afternoon", "location": "table"}'),
            (1, "Inspect Object", '{"tools": ["camera", "gripper"]}'),
        ]
        insert_query = """
            INSERT INTO task_preferences (user_id, task_name, preference_data)
            VALUES (%s, %s, %s);
        """
        self.cursor.executemany(insert_query, task_preferences)

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
        insert_query = """
            INSERT INTO interaction_memory (user_id, instruction_id, interaction_type, data, start_time, end_time)
            VALUES (%s, %s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, interactions)

    def populate_simulation_results(self):
        results = [
            (1, True, '{"accuracy": 0.95, "time_taken": 2.5}', "No errors"),
            (2, False, '{"accuracy": 0.8, "time_taken": 3.0}', "Gripper misalignment"),
        ]
        insert_query = """
            INSERT INTO simulation_results (instruction_id, success, metrics, error_log)
            VALUES (%s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, results)

    def close(self):
        """Close the database connection."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()


if __name__ == "__main__":
    db_handler = DatabaseHandler()
    db_handler.populate_database()
    atexit.register(db_handler.close)

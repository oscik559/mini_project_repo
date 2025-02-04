# data_handler.py

import os
import sqlite3
from datetime import datetime
from config import *



# This class likely manages interactions with a database.
class DatabaseHandler:
    def __init__(self, db_name=DB_PATH):
        self.db_name = db_name
        self.conn = sqlite3.connect(self.db_name)
        self.cursor = self.conn.cursor()
        self.initialize_database()

    def initialize_database(self):
        self.create_tables()
        self.update_table_schemas()

    def create_tables(self):
        """Create all necessary tables if they do not exist."""
        tables = {
            "sequence_library": """
                CREATE TABLE IF NOT EXISTS sequence_library (
                    sequence_id INTEGER PRIMARY KEY,
                    sequence_name TEXT NOT NULL,
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
                    FOREIGN KEY (sequence_id) REFERENCES sequence_library (sequence_id)
                );
            """,
            "operation_sequence": """
                CREATE TABLE IF NOT EXISTS operation_sequence (
                    sequence_id INTEGER PRIMARY KEY,
                    operation_id INTEGER,
                    sequence_name TEXT NOT NULL,
                    object_name TEXT
                );
            """,
            "screw_op_parameters": """
                CREATE TABLE IF NOT EXISTS screw_op_parameters (
                    sequence_id INTEGER PRIMARY KEY,
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
                    sequence_id INTEGER PRIMARY KEY,
                    object_name TEXT,
                    object_color TEXT,
                    color_code TEXT,
                    pos_X FLOAT,
                    pos_Y FLOAT,
                    pos_Z FLOAT,
                    rot_X FLOAT,
                    rot_Y FLOAT,
                    rot_Z FLOAT,
                    usd_name TEXT
                );
            """,
            "sort_order": """
                CREATE TABLE IF NOT EXISTS sort_order (
                    sequence_id INTEGER PRIMARY KEY,
                    object_name TEXT,
                    object_color TEXT
                );
            """,
            "user_profiles": """
                CREATE TABLE IF NOT EXISTS user_profiles (
                    user_id INTEGER PRIMARY KEY,
                    first_name TEXT NOT NULL,
                    last_name TEXT NOT NULL,
                    LIU_id TEXT UNIQUE,
                    email TEXT UNIQUE,
                    preferences TEXT,
                    profile_image_path TEXT,
                    interaction_history TEXT,
                    face_encoding BLOB,
                    voice_embedding BLOB,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """,
            "interaction_history": """
                CREATE TABLE IF NOT EXISTS interaction_history (
                    interaction_id INTEGER PRIMARY KEY,
                    user_id INTEGER,
                    interaction_type TEXT,
                    data TEXT,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES user_profiles (user_id)
                );
            """,
            "user_task_preferences": """
                CREATE TABLE IF NOT EXISTS user_task_preferences (
                    preference_id INTEGER PRIMARY KEY,
                    user_id INTEGER,
                    task_name TEXT,
                    preference_data TEXT,
                    FOREIGN KEY (user_id) REFERENCES user_profiles (user_id)
                );
            """,
            "instructions": """
                CREATE TABLE IF NOT EXISTS instructions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    user_id INTEGER,
                    modality TEXT CHECK(modality IN ('voice', 'gesture', 'sensor','haptic', 'image','text','video','other')),
                    audio_language TEXT,
                    instruction_type TEXT NOT NULL,
                    content TEXT,
                    sync_id INTEGER UNIQUE,
                    processed BOOLEAN DEFAULT FALSE,
                    confidence FLOAT CHECK(confidence BETWEEN 0 AND 1),
                    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id)
                );
            """,
            "instruction_operation_sequence": """
                CREATE TABLE IF NOT EXISTS instruction_operation_sequence (
                    task_id INTEGER PRIMARY KEY,
                    instruction_id INTEGER,
                    operation_id INTEGER,
                    sequence_name TEXT NOT NULL,
                    object_name TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (instruction_id) REFERENCES instructions(id)
                );
            """
        }

        for table_name, create_statement in tables.items():
            self.cursor.execute(create_statement)

    def update_table_schemas(self):
        """Ensure all tables have the expected schema."""
        schemas = {
            "sequence_library": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("sequence_name", "TEXT NOT NULL"),
                ("node_name", "TEXT"),
                ("description", "TEXT"),
                ("conditions", "TEXT"),
                ("post_conditions", "TEXT"),
                ("is_runnable_count", "INTEGER"),
                ("is_runnable_condition", "TEXT"),
                ("is_runnable_exit", "BOOLEAN")
            ],
            "states": [
                ("task_id", "INTEGER PRIMARY KEY"),
                ("task_name", "TEXT NOT NULL"),
                ("description", "TEXT"),
                ("conditions", "TEXT"),
                ("post_conditions", "TEXT"),
                ("sequence_id", "INTEGER")
            ],
            "operation_sequence": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("operation_id", "INTEGER NOT NULL"),
                ("sequence_name", "TEXT NOT NULL"),
                ("object_name", "TEXT")
            ],
            "screw_op_parameters": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("operation_order", "INTEGER NOT NULL"),
                ("object_id", "TEXT NOT NULL"),
                ("rotation_dir", "BOOLEAN NOT NULL"),
                ("number_of_rotations", "INTEGER NOT NULL"),
                ("current_rotation", "INTEGER NOT NULL"),
                ("operation_status", "BOOLEAN NOT NULL")
            ],
            "camera_vision": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("object_name", "TEXT NOT NULL"),
                ("object_color", "TEXT NOT NULL"),
                ("color_code", "TEXT"),
                ("pos_X", "FLOAT NOT NULL"),
                ("pos_Y", "FLOAT NOT NULL"),
                ("pos_Z", "FLOAT NOT NULL"),
                ("rot_X", "FLOAT NOT NULL"),
                ("rot_Y", "FLOAT NOT NULL"),
                ("rot_Z", "FLOAT NOT NULL"),
                ("usd_name", "TEXT NOT NULL")
            ],
            "sort_order": [
                ("sequence_id", "INTEGER PRIMARY KEY"),
                ("object_name", "TEXT NOT NULL"),
                ("object_color", "TEXT NOT NULL")
            ],
            "user_profiles": [
                ("user_id", "INTEGER PRIMARY KEY"),
                ("first_name", "TEXT NOT NULL"),
                ("last_name", "TEXT NOT NULL"),
                ("LIU_id", "TEXT UNIQUE"),
                ("email", "TEXT UNIQUE"),
                ("preferences", "TEXT"),
                ("profile_image_path", "TEXT"),
                ("interaction_history", "TEXT"),
                ("face_encoding", "BLOB"),
                ("voice_embedding", "BLOB"),
                ("created_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"),
                ("last_updated", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
            ],
            "interaction_history": [
                ("interaction_id", "INTEGER PRIMARY KEY"),
                ("user_id", "INTEGER"),
                ("interaction_type", "TEXT"),
                ("data", "TEXT"),
                ("timestamp", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
            ],
            "user_task_preferences": [
                ("preference_id", "INTEGER PRIMARY KEY"),
                ("user_id", "INTEGER"),
                ("task_name", "TEXT"),
                ("preference_data", "TEXT")
            ],
            "instructions": [
                ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
                ("timestamp", "DATETIME DEFAULT CURRENT_TIMESTAMP"),
                ("user_id", "INTEGER"),
                ("modality", "TEXT CHECK(modality IN ('voice', 'gesture', 'sensor','haptic', 'image','text','video','other'))"),
                ("audio_language", "TEXT"),
                ("instruction_type", "TEXT NOT NULL"),
                ("content", "TEXT"),
                ("sync_id", "INTEGER UNIQUE"),
                ("processed", "BOOLEAN DEFAULT FALSE"),
                ("confidence", "FLOAT CHECK(confidence BETWEEN 0 AND 1)")
            ],
            "instruction_operation_sequence": [
                ("task_id", "INTEGER PRIMARY KEY"),
                ("instruction_id", "INTEGER"),
                ("operation_id", "INTEGER"),
                ("sequence_name", "TEXT NOT NULL"),
                ("object_name", "TEXT"),
                ("created_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
            ]
        }

        for table_name, expected_columns in schemas.items():
            self.validate_table_schema(table_name, expected_columns)


    def validate_table_schema(self, table_name, expected_columns):
        """Validate and update table schemas"""
        self.cursor.execute(f"PRAGMA table_info({table_name})")
        existing_columns = {col[1]: col[2] for col in self.cursor.fetchall()}

        # Add missing columns with constraints
        for column_name, column_def in expected_columns:
            if column_name not in existing_columns:
                try:
                    self.cursor.execute(f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_def}")
                    print(f"Added column '{column_name}' to '{table_name}'")
                except sqlite3.OperationalError as e:
                    print(f"Schema update failed for {table_name}.{column_name}: {str(e)}")

        self.conn.commit()

    def populate_database(self):
        """Populate the database with initial data."""
        # Clear existing data
        self.clear_tables()

        # Populate tables with example data
        self.populate_sequences()
        self.populate_states()
        self.populate_operation_sequence()
        self.populate_camera_vision()
        self.populate_sort_order()
        self.populate_user_profiles()
        self.populate_task_preferences()
        self.populate_interaction_history()

        # Commit changes
        self.conn.commit()
        print("Database populated successfully.")

    def clear_tables(self):
        """Clear data from all tables."""
        tables = [
            "sequence_library", "states", "operation_sequence", "screw_op_parameters",
            "camera_vision", "sort_order", "user_profiles", "interaction_history", "user_task_preferences", "instructions"
        ]

        for table in tables:
            self.cursor.execute(f"DELETE FROM {table}")

    def populate_sequences(self):
        # Populate sequence_library
        sequence_library = [
        ("pick", "PickBlockRd", "Pick up an object", "gripper is clear", "object in gripper", 1, "aaa", 0),
        ("travel", "ReachToPlacementRd", "Move to the target location", "object in gripper", "at target location", 1, "aaa", 0),
        ("drop", "DropRd", "Drop the object", "at target location", "object dropped", 1, "aaa", 0),
        ("screw", "ScrewRd", "Screw the object two times", "task complete", "robot at home position", 1, "thresh_met and self.context.gripper_has_block", 1),
        ("go_home", "GoHome", "Return to the home position", "task complete", "robot at home position", 1, "aaa", 0),
        ]
        self.cursor.executemany(
            "INSERT INTO sequence_library (sequence_name, node_name, description, conditions, post_conditions, is_runnable_count, is_runnable_condition, is_runnable_exit) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            sequence_library
        )

    def populate_states(self):
        states = [
            ("LiftState", "Lift an object vertically", "gripper is clear", "object in gripper", 1),
            ("SlideState", "Slide an object along X-axis", "object in gripper", "at target location", 1)
        ]
        self.cursor.executemany(
            "INSERT INTO states (task_name, description, conditions, post_conditions, sequence_id) VALUES (?, ?, ?, ?, ?)",
            states
        )

    def populate_operation_sequence(self):
        operation_sequence = [( 1, "travel", ""),( 1, "pick", "BlueCube"),( 1, "travel", ""),( 1, "screw", "BlueCube"),( 1, "drop", ""),
                              ( 2, "travel", ""),( 2, "pick", "YellowCube"),( 2, "travel", ""),( 2, "screw", "YellowCube"),( 2, "drop", ""),
                              ( 3, "travel", ""),( 3, "pick", "GreenCube"),( 3, "travel", ""),( 3, "screw", "GreenCube"),( 3, "drop", ""),
                              ( 4, "travel", ""),( 4, "pick", "RedCube"),( 4, "travel", ""),( 4, "screw", "RedCube"),( 4, "drop", "")
        ]
        self.cursor.executemany(
            "INSERT INTO operation_sequence (operation_id, sequence_name, object_name) VALUES (?, ?, ?)",
            operation_sequence
        )

    def populate_camera_vision(self):
        camera_vision = [
            ("RedCube", "Red", "[0.7, 0.0, 0.0]", 0.3, -0.4, 0.026, 0.0, 0.0, 0.0, "Cube.usd"),
            ("BlueCube", "Blue", "[0.0, 0.0, 0.7]", 0.43, -0.4, 0.026, 0.0, 0.0, 0.0, "Cube.usd"),
            ("YellowCube", "Yellow", "[0.7, 0.7, 0.0]", 0.56, -0.4, 0.026, 0.0, 0.0, 0.0, "Cube.usd"),
        ]
        self.cursor.executemany(
            "INSERT INTO Camera_Vision (object_name, object_color, color_code, pos_X, pos_Y, pos_Z, rot_X, rot_Y, rot_Z, usd_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            camera_vision
        )

    def populate_sort_order(self):
        sort_order = [
            ("RedCube", "Red"),
            ("BlueCube", "Blue"),
            ("YellowCube", "Yellow"),
        ]
        self.cursor.executemany(
            "INSERT INTO sort_order (object_name, object_color) VALUES (?, ?)",
            sort_order
        )

    def populate_user_profiles(self):
        user_profiles = [
            ("Oscar", "Ikechukwu", "oscik559","oscik559@student.liu.se", '{"likes": ["AI", "Robotics"]}', "/images/oscar.jpg", '{"last_task": "Pick object", "successful_tasks": 5}'),
            ("Rahul", "Chiramel","rahch515","rahch515@student.liu.se", '{"likes": ["Aeroplanes", "Automation"]}', "/images/rahul.jpg", '{"last_task": "Screw object", "successful_tasks": 10}'),
            ("Sanjay", "Nambiar", "sanna58","sanjay.nambiar@liu.se", '{"likes": ["Programming", "Machine Learning"]}', "/images/sanjay.jpg", '{"last_task": "Slide object", "successful_tasks": 7}'),
            ("Mehdi", "Tarkian", "mehta77","mehdi.tarkian@liu.se", '{"likes": ["Running", "Cats"]}', "/images/mehdi.jpg", '{"last_task": "Drop object", "successful_tasks": 2}')
        ]
        self.cursor.executemany(
            "INSERT INTO user_profiles (first_name, last_name, LIU_id, email, preferences, profile_image_path, interaction_history) VALUES (?, ?, ?, ?, ?, ?, ?)",
            user_profiles
        )

    def populate_task_preferences(self):
        user_task_preferences = [
            (1, "Pick Object", '{"time": "morning", "location": "shelf"}'),
            (2, "Place Object", '{"time": "afternoon", "location": "table"}'),
            (1, "Inspect Object", '{"tools": ["camera", "gripper"]}')
        ]
        self.cursor.executemany(
            "INSERT INTO user_task_preferences (user_id, task_name, preference_data) VALUES (?, ?, ?)",
            user_task_preferences
        )

    def populate_interaction_history(self):
        interactions = [
            (1, "task_query", '{"task": "Pick Object"}'),
            (2, "preference_update", '{"preference": {"time": "morning"}}'),
            (1, "task_execution", '{"status": "success", "task": "Place Object"}')
        ]
        self.cursor.executemany(
            "INSERT INTO interaction_history (user_id, interaction_type, data) VALUES (?, ?, ?)",
            interactions
        )

    def check_table_schema(self, table_name):
        """Print the schema of a table."""
        self.cursor.execute(f"PRAGMA table_info({table_name})")
        schema = self.cursor.fetchall()
        print(f"Schema of {table_name}:")
        for column in schema:
            print(column)

    def close(self):
        """Close the database connection."""
        self.conn.close()

    # Add instruction-related methods as needed
    def log_instruction(self, user_id, modality, audio_language, instruction_type,  content, confidence=None):
        """Insert a new instruction record with validation"""
        query = """
            INSERT INTO instructions
            (user_id, modality,audio_language, instruction_type, content, confidence, sync_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        sync_id = int(datetime.now().timestamp() * 1000)  # Millisecond precision

        try:
            self.cursor.execute(query, (
                user_id,
                modality,
                audio_language,
                instruction_type,
                content,
                confidence,
                sync_id
            ))
            self.conn.commit()
            return True
        except sqlite3.IntegrityError as e:
            print(f"Failed to log instruction: {str(e)}")
            return False

if __name__ == "__main__":
    # db_path = os.path.join(r"C:\Users\oscik559\Projects\user_profile", "sequences.db")
    # db_handler = DatabaseHandler(db_path)
    db_handler = DatabaseHandler()
    db_handler.populate_database()

    # Test instructions table
    # db_handler.log_instruction(
    #     user_id = None,
    #     audio_language='en',
    #     modality='voice',
    #     instruction_type='navigation',
    #     content='Move to assembly station',
    #     confidence=0.92
    # )
    db_handler.close()

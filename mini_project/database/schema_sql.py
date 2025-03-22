# Just a dict of table creation SQL strings


tables = {
    "usd_data": """
                CREATE TABLE IF NOT EXISTS USD_data (
                sequence_id INTEGER PRIMARY KEY,
                usd_name TEXT NOT NULL,
                type_of_usd TEXT NOT NULL,
                repository TEXT NOT NULL,
                scale_x FLOAT NOT NULL,
                scale_y FLOAT NOT NULL,
                scale_z FLOAT NOT NULL,
                prim_path TEXT NOT NULL,
                initial_pos_x FLOAT NOT NULL,
                initial_pos_y FLOAT NOT NULL,
                initial_pos_z FLOAT NOT NULL,
                register_obstacle BOOLEAN NOT NULL
            );
            """,
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
                    color_code FLOAT8[],
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

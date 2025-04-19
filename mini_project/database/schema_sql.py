# Just a dict of table creation SQL strings

from collections import OrderedDict

tables = OrderedDict(
    [
        (
            "users",
            """
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
                role TEXT CHECK(role IN ('robot','team', 'guest', 'admin')) DEFAULT 'guest',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
    """,
        ),
        (
            "usd_data",
            """
            CREATE TABLE IF NOT EXISTS usd_data (
                sequence_id INTEGER PRIMARY KEY,
                usd_name TEXT NOT NULL,
                type_of_usd TEXT NOT NULL,
                repository TEXT NOT NULL,
                block_height FLOAT NOT NULL,
                block_pick_height FLOAT NOT NULL,
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
        ),
        (
            "isaac_sim_gui",
            """
            CREATE TABLE IF NOT EXISTS isaac_sim_gui (
                sequence_id SERIAL PRIMARY KEY,
                gui_feature TEXT NOT NULL,
                operation_status TEXT NOT NULL
            );
    """,
        ),
        (
            "sequence_library",
            """
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
        ),
        (
            "operation_library",
            """
            CREATE TABLE IF NOT EXISTS operation_library (
                id SERIAL PRIMARY KEY,

                -- Core operation metadata
                operation_name TEXT UNIQUE NOT NULL,       -- e.g., 'tray_holder_detection'
                task_order TEXT,                           -- e.g., 'detect, pick, place'
                description TEXT,                          -- Human-readable label

                -- Script & trigger metadata
                trigger_keywords TEXT[],                   -- Words that trigger this operation
                script_path TEXT,                          -- e.g., 'camera_vision_pgSQL_rs.py'
                is_triggerable BOOLEAN DEFAULT TRUE,       -- Can be triggered from LLM

                -- Trigger state tracking
                trigger BOOLEAN DEFAULT FALSE,             -- Used by LLM to trigger script
                status TEXT DEFAULT 'idle',                -- idle | triggered | running | completed | failed
                last_triggered TIMESTAMP                   -- When it was last set to TRUE
            );
    """,
        ),
        (
            "access_logs",
            """
            CREATE TABLE IF NOT EXISTS access_logs (
                log_id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                action_type TEXT NOT NULL,
                target_table TEXT,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            );
    """,
        ),
        (
            "skills",
            """
            CREATE TABLE IF NOT EXISTS skills (
                skill_id SERIAL PRIMARY KEY,
                skill_name TEXT NOT NULL UNIQUE,
                description TEXT,
                parameters TEXT,
                required_capabilities TEXT,
                average_duration REAL
            );
    """,
        ),
        (
            "instructions",
            """
            CREATE TABLE IF NOT EXISTS instructions (
                id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
        ),
        (
            "states",
            """
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
        ),
        (
            "screw_op_parameters",
            """
            CREATE TABLE IF NOT EXISTS screw_op_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                rotation_dir BOOLEAN NOT NULL,
                number_of_rotations INTEGER NOT NULL,
                current_rotation INTEGER NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "pick_op_parameters",
            """
            CREATE TABLE IF NOT EXISTS pick_op_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                slide_state_status BOOLEAN NOT NULL,
                slide_direction TEXT NOT NULL,
                distance_travel FLOAT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "drop_op_parameters",
            """
                CREATE TABLE IF NOT EXISTS drop_op_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                drop_height FLOAT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "travel_op_parameters",
            """
            CREATE TABLE IF NOT EXISTS travel_op_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                travel_height FLOAT NOT NULL,
                gripper_rotation TEXT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "lift_state_parameters",
            """
            CREATE TABLE IF NOT EXISTS lift_state_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                lift_height FLOAT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "slide_state_parameters",
            """
            CREATE TABLE IF NOT EXISTS slide_state_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                lift_distance FLOAT NOT NULL,
                pos_x FLOAT NOT NULL,
                pos_y FLOAT NOT NULL,
                pos_z FLOAT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "rotate_state_parameters",
            """
            CREATE TABLE IF NOT EXISTS rotate_state_parameters (
                sequence_id SERIAL PRIMARY KEY,
                operation_order INTEGER NOT NULL,
                object_id TEXT NOT NULL,
                rotation_angle FLOAT NOT NULL,
                operation_status BOOLEAN NOT NULL
            );
    """,
        ),
        (
            "camera_vision",
            """
            CREATE TABLE IF NOT EXISTS camera_vision (
                object_id SERIAL PRIMARY KEY,
                object_name TEXT NOT NULL,
                object_color TEXT NOT NULL,
                color_code FLOAT8[],
                pos_x DOUBLE PRECISION NOT NULL,
                pos_y DOUBLE PRECISION NOT NULL,
                pos_z DOUBLE PRECISION NOT NULL,
                rot_x DOUBLE PRECISION NOT NULL,
                rot_y DOUBLE PRECISION NOT NULL,
                rot_z DOUBLE PRECISION NOT NULL,
                usd_name TEXT NOT NULL,
                last_detected TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
    """,
        ),
        (
            "task_templates",
            """
            CREATE TABLE IF NOT EXISTS task_templates (
                task_id SERIAL PRIMARY KEY,
                task_name TEXT UNIQUE NOT NULL,
                description TEXT,
                default_sequence TEXT[]
            );
    """,
        ),
        (
            "sort_order",
            """
            CREATE TABLE IF NOT EXISTS sort_order (
                order_id SERIAL PRIMARY KEY,
                object_name TEXT,
                object_color TEXT
            );
    """,
        ),
        (
            "interaction_memory",
            """
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
        ),
        (
            "simulation_results",
            """
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
        ),
        (
            "task_preferences",
            """
            CREATE TABLE IF NOT EXISTS task_preferences (
                preference_id SERIAL PRIMARY KEY,
                user_id INTEGER,
                task_id TEXT,
                task_name TEXT,
                preference_data TEXT,
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
            );
    """,
        ),
        (
            "unified_instructions",
            """
            CREATE TABLE IF NOT EXISTS unified_instructions (
                id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                session_id TEXT,
                timestamp TIMESTAMP,
                liu_id TEXT,
                voice_command TEXT,
                gesture_command TEXT,
                unified_command TEXT,
                confidence FLOAT CHECK(confidence BETWEEN 0 AND 1),
                processed BOOLEAN DEFAULT FALSE,
                FOREIGN KEY (liu_id) REFERENCES users(liu_id) ON DELETE CASCADE
            );
    """,
        ),
        (
            "operation_sequence",
            """
            CREATE TABLE IF NOT EXISTS operation_sequence (
                id SERIAL PRIMARY KEY,
                operation_id INTEGER NOT NULL,         -- order of execution
                sequence_id INTEGER NOT NULL,          -- FK to sequence_library
                sequence_name TEXT NOT NULL,           -- redundant but helpful for readability
                object_name TEXT,
                command_id INTEGER,                    -- FK to unified_instructions(id)
                processed BOOLEAN DEFAULT FALSE,       -- ✅ track if step is completed
                execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

                FOREIGN KEY (sequence_id) REFERENCES sequence_library(sequence_id),
                FOREIGN KEY (command_id) REFERENCES unified_instructions(id)
            );
    """,
        ),
        (
            "gesture_library",
            """
            CREATE TABLE IF NOT EXISTS gesture_library (
                id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                gesture_type TEXT UNIQUE NOT NULL,
                gesture_text TEXT NOT NULL,
                natural_description TEXT,
                config JSONB

            );
    """,
        ),
        (
            "gesture_instructions",
            """
            CREATE TABLE IF NOT EXISTS gesture_instructions (
                id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                session_id TEXT NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                gesture_text TEXT NOT NULL,
                natural_description TEXT,
                confidence REAL,
                hand_label TEXT,
                processed BOOLEAN DEFAULT FALSE
            );
    """,
        ),
        (
            "voice_instructions",
            """
            CREATE TABLE IF NOT EXISTS voice_instructions (
                id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                session_id TEXT NOT NULL,
                transcribed_text TEXT NOT NULL,
                confidence REAL,
                language TEXT NOT NULL,
                processed BOOLEAN DEFAULT FALSE,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
    """,
        ),
        (
            "instruction_operation_sequence",
            """
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
        ),
        (
            "task_history",
            """
            CREATE TABLE IF NOT EXISTS task_history (
                id SERIAL PRIMARY KEY,
                command_text TEXT,
                generated_plan JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """,
        ),
    ]
)

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
    "CREATE INDEX IF NOT EXISTS idx_voice_session_id ON voice_instructions(session_id);",
    "CREATE INDEX IF NOT EXISTS idx_voice_processed ON voice_instructions(processed);",
    "CREATE INDEX IF NOT EXISTS idx_task_templates_name ON task_templates(task_name);",
    "CREATE INDEX IF NOT EXISTS idx_task_templates_sequence ON task_templates(default_sequence);",
    "CREATE INDEX IF NOT EXISTS idx_unified_instructions_session_id ON unified_instructions(session_id);",
]

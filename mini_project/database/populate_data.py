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

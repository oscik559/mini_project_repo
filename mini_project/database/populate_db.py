class DatabasePopulator:
    def __init__(self, cursor):
        self.cursor = cursor

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

    def populate_usd_data(self):
        """
        Populate usd_data table with provided data.
        """
        usd_data = [
            (
                1,
                "Fixture.usd",
                "GeometryPrim",
                "/fixture_description/Slide_Fixture.usd",
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                0.20,
                -0.07,
                0.094,
                False,
            ),
            (
                2,
                "Slide_Holder.usd",
                "GeometryPrim",
                "/fixture_description/Slide_Holder.usd",
                0.001,
                0.001,
                0.001,
                "/World",
                0.47,
                0.05,
                0.180,
                False,
            ),
            (
                3,
                "Cuboid.usd",
                "DynamicCuboid",
                "/basicshapes/cuboid.usd",
                0.0825,
                0.0825,
                0.0825,
                "/World/fixtureprim/Fixture",
                0.0,
                0.0,
                0.0,
                False,
            ),
            (
                4,
                "Cylinder.usd",
                "DynamicCuboid",
                "/basicshapes/cylinder.usd",
                0.0825,
                0.0825,
                0.0825,
                "/World/fixtureprim/Fixture",
                0.0,
                0.0,
                0.0,
                False,
            ),
            (
                5,
                "Slide.usd",
                "DynamicCuboid",
                "aaa",
                75.0,
                24.4,
                2.0,
                "/World/fixtureprim/Fixture",
                0.0,
                0.0,
                0.0,
                True,
            ),
        ]
        insert_query = """
            INSERT INTO usd_data (
                    sequence_id, usd_name, type_of_usd, repository, scale_x, scale_y, scale_z,
                    prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle
                )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        self.cursor.executemany(insert_query, usd_data)

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
            (1, "pick", "Slide_1"),
            (1, "travel", "Slide_1"),
            (1, "drop", "Slide_1"),
            (2, "pick", "Slide_2"),
            (2, "travel", "Slide_2"),
            (2, "drop", "Slide_2"),
            (3, "pick", "Slide_3"),
            (3, "travel", "Slide_3"),
            (3, "drop", "Slide_3"),
            (4, "go_home", ""),
        ]
        insert_query = """
            INSERT INTO operation_sequence (operation_id, sequence_name, object_name)
            VALUES (%s, %s, %s);
        """
        self.cursor.executemany(insert_query, operation_sequence)

    def populate_sort_order(self):
        sort_order = [
            ("Slide_1", "Green"),
            ("Slide_2", "Orange"),
            ("Slide_3", "Pink"),
        ]
        insert_query = """
            INSERT INTO sort_order (object_name, object_color)
            VALUES (%s, %s);
        """
        self.cursor.executemany(insert_query, sort_order)

    def populate_task_templates(self):
        task_templates = [
            (
                "sort",
                "Default sorting task: pick, move, drop",
                ["pick", "travel", "drop"],
            ),
            (
                "assemble",
                "Assembly involves pick and screw",
                ["pick", "travel", "screw", "go_home"],
            ),
            (
                "inspect",
                "Inspect task involves scan and return",
                ["travel", "inspect", "go_home"],
            ),
            (
                "cleanup",
                "Cleanup task involves pick, rotate, drop",
                ["pick", "rotate", "drop"],
            ),
        ]
        insert_query = """
            INSERT INTO task_templates (task_name, description, default_sequence)
            VALUES (%s, %s, %s);
        """
        self.cursor.executemany(insert_query, task_templates)

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

    def populate_manual_operations(self):
        # -- Screw Operation Parameters
        self.cursor.execute(
            "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'screw'"
        )
        screw_data = self.cursor.fetchall()
        screw_op_parameters = [
            (i + 1, seq_id, obj_name, i % 2 == 0, 3, 0, False)
            for i, (seq_id, obj_name) in enumerate(screw_data)
        ]
        self.cursor.executemany(
            """
            INSERT INTO screw_op_parameters (
                operation_order, sequence_id, object_id,
                rotation_dir, number_of_rotations,
                current_rotation, operation_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            screw_op_parameters,
        )

        # -- Rotate State Parameters
        self.cursor.execute(
            "SELECT sequence_id, operation_order, object_id FROM screw_op_parameters"
        )
        rotate_data = self.cursor.fetchall()
        rotate_state_parameters = [
            (seq_id, operation_order, obj_id, 90, False)
            for (seq_id, operation_order, obj_id) in rotate_data
        ]
        self.cursor.executemany(
            """
            INSERT INTO rotate_state_parameters (
                sequence_id, operation_order, object_id,
                rotation_angle, operation_status
            )
            VALUES (%s, %s, %s, %s, %s)
            """,
            rotate_state_parameters,
        )

        # -- Pick Operation Parameters
        self.cursor.execute(
            "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'pick'"
        )
        pick_data = self.cursor.fetchall()
        pick_op_parameters = [
            (seq_id, i + 1, obj_name, False, "y", 0.01, False)
            for i, (seq_id, obj_name) in enumerate(pick_data)
        ]
        self.cursor.executemany(
            """
            INSERT INTO pick_op_parameters (
                sequence_id, operation_order, object_id,
                slide_state_status, slide_direction,
                distance_travel, operation_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            pick_op_parameters,
        )

        # -- Travel Operation Parameters
        self.cursor.execute(
            "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'travel'"
        )
        travel_data = self.cursor.fetchall()
        travel_op_parameters = [
            (seq_id, i + 1, obj_name, 0.085, "z-axis", False)
            for i, (seq_id, obj_name) in enumerate(travel_data)
        ]
        self.cursor.executemany(
            """
            INSERT INTO travel_op_parameters (
                sequence_id, operation_order, object_id,
                travel_height, gripper_rotation,
                operation_status
            )
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            travel_op_parameters,
        )

        # -- Isaac GUI Features
        isaac_sim_gui = [("Start", False), ("Reset", False), ("Load", False)]
        self.cursor.executemany(
            """
            INSERT INTO isaac_sim_gui (gui_feature, operation_status)
            VALUES (%s, %s)
            """,
            isaac_sim_gui,
        )

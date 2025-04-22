# database/populate_db.py
"""This module contains the `DatabasePopulator` class, which is responsible for populating various database tables
with predefined data. The class provides methods to populate tables such as `sequence_library`, `usd_data`,
`operation_library`, `users`, `skills`, `instructions`, `states`, `operation_sequence`, `sort_order`,
`task_templates`, `task_preferences`, `interaction_memory`, `simulation_results`, and `manual_operations`.
Each method in the class corresponds to a specific table in the database and inserts predefined data into it.
The methods ensure that data is inserted only when necessary, avoiding duplication by checking existing records
where applicable.
Classes:
    - DatabasePopulator: A class that provides methods to populate database tables with predefined data.
Methods:
    - populate_sequence_library: Populates the `sequence_library` table with predefined sequences.
    - populate_usd_data: Populates the `usd_data` table with predefined USD data.
    - populate_operation_library: Populates the `operation_library` table with predefined operations.
    - populate_users: Populates the `users` table with predefined user data.
    - populate_skills: Populates the `skills` table with predefined skill data.
    - populate_instructions: Populates the `instructions` table with predefined instruction data.
    - populate_states: Populates the `states` table with predefined state data.
    - populate_operation_sequence: Populates the `operation_sequence` table with predefined operation sequences.
    - populate_sort_order: Populates the `sort_order` table with predefined object sorting orders.
    - populate_task_templates: Populates the `task_templates` table with predefined task templates.
    - populate_task_preferences: Populates the `task_preferences` table with predefined user task preferences.
    - populate_interaction_memory: Populates the `interaction_memory` table with predefined interaction data.
    - populate_simulation_results: Populates the `simulation_results` table with predefined simulation results.
    - populate_manual_operations: Populates various operation parameter tables with predefined manual operation data.

"""


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
                "rotate",
                "RotateRd",
                "Rotate the object once",
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
                0.0,
                0.0,
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
                0.0,
                0.0,
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                40,
                17,
                8,
                False,
            ),
            (
                3,
                "Slide.usd",
                "RigidPrim",
                "/fixture_description/Slide1.usd",
                0.002,
                0.016,
                1,
                1,
                0.06,
                "/World/fixtureprim/Fixture",
                0.0,
                0.0,
                0.0,
                True,
            ),
            (
                4,
                "Cuboid.usd",
                "RigidPrim",
                "/yumi_basic_shapes/cuboid.usd",
                0.025,
                0.015,
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                0.55475,
                -0.116,
                0.113,
                True,
            ),
            (
                5,
                "Cylinder.usd",
                "RigidPrim",
                "/yumi_basic_shapes/cylinder.usd",
                0.025,
                0.015,
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                0.41475,
                -0.116,
                0.113,
                True,
            ),
            (
                6,
                "Cube.usd",
                "RigidPrim",
                "/yumi_basic_shapes/cube.usd",
                0.025,
                0.015,
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                0.34475,
                -0.116,
                0.113,
                True,
            ),
            (
                7,
                "Hexagon.usd",
                "RigidPrim",
                "/yumi_basic_shapes/hexagon.usd",
                0.025,
                0.015,
                0.1,
                0.1,
                0.1,
                "/World/fixtureprim",
                0.48475,
                -0.116,
                0.113,
                True,
            ),
        ]
        insert_query = """
            INSERT INTO usd_data (
                    sequence_id, usd_name, type_of_usd, repository,block_height,block_pick_height, scale_x, scale_y, scale_z,
                    prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle
                )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        self.cursor.executemany(insert_query, usd_data)

    def populate_operation_library(self):
        self.cursor.execute("SELECT COUNT(*) FROM operation_library")
        count = self.cursor.fetchone()[0]
        if count > 0:
            return
        operation_library = [
            (
                "slide_sorting",  # operation_name	Internal task name
                "pick, travel, drop",  # List of phases like pick/travel/drop
                "Sort slides by shape and color into trays",  # Human-readable explanation
                [
                    "sort",
                    "slide",
                    "sorting",
                    "arrange",
                ],  # trigger_keywords	Voice-trigger words
                "detect_slides_pgSQL.py",  # Path to run on vision system
                True,  # is_triggerable, Whether LLM can set trigger = TRUE
                False,  # trigger,  Defaults to FALSE (used as flag)
                "idle",  # state, 'idle' initially
                None,  # last_triggered_time, None until first run
            ),
            (
                "shape_stacking",
                "pick, travel, drop",
                "Stack blocks of shapes based on their type and color",
                ["stack", "shape", "pile"],
                "detect_shapes_pgSQL.py",
                True,
                False,
                "idle",
                None,
            ),
        ]
        insert_query = """
            INSERT INTO operation_library (
                operation_name, task_order, description, trigger_keywords,
                script_path, is_triggerable, trigger, state, last_triggered
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        self.cursor.executemany(insert_query, operation_library)

    def populate_users(self):
        self.cursor.execute("SELECT COUNT(*) FROM users")
        count = self.cursor.fetchone()[0]
        if count > 0:
            return
        users = [
            (
                "Yumi",
                "Robot",
                "yumi100",
                "yumi100@lab.liu.ai",
                '{"likes": ["AI", "Robotics"]}',
                "/images/yumi001.jpg",
                '{"last_task": "Assistance", "successful_tasks": 100}',
                "robot",
            ),
            (
                "Oscar",
                "Ikechukwu",
                "oscik559",
                "oscik559@student.liu.se",
                '{"likes": ["AI", "Robotics"]}',
                "/images/oscik559.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "admin",
            ),
            (
                "Rahul",
                "Chiramel",
                "rahch515",
                "rahch515@student.liu.se",
                '{"likes": ["Aeroplanes", "Automation"]}',
                "/images/rahch515.jpg",
                '{"last_task": "Screw object", "successful_tasks": 10}',
                "admin",
            ),
            (
                "Sanjay",
                "Nambiar",
                "sanna58",
                "sanjay.nambiar@liu.se",
                '{"likes": ["Programming", "Machine Learning"]}',
                "/images/sanna58.jpg",
                '{"last_task": "Slide object", "successful_tasks": 7}',
                "admin",
            ),
            (
                "Mehdi",
                "Tarkian",
                "mehta77",
                "mehdi.tarkian@liu.se",
                '{"likes": ["Running", "Cats"]}',
                "/images/mehta77.jpg",
                '{"last_task": "Drop object", "successful_tasks": 2}',
                "team",
            ),
            (
                "Marie",
                "Jonsson",
                "marjo33",
                "marie.s.jonsson@liu.se",
                '{"likes": ["Robots", "Composites"]}',
                "/images/marjo33.jpg",
                '{"last_task": "Fix robot battery", "successful_tasks": 2}',
                "team",
            ),
            (
                "Aref",
                "Aghaee",
                "areag806",
                "areag806@student.liu.se",
                '{"likes": ["CATIA", "Turbine Blades"]}',
                "/images/areag806.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "guest",
            ),
            (
                "Thomson",
                "Kalliyath",
                "thoka981",
                "thoka981@student.liu.se",
                '{"likes": ["Omniverse", "Aeronautics"]}',
                "/images/thoka981.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "guest",
            ),
            (
                "Hamideh",
                "Pourrasoul",
                "hampo845",
                "hampo845@student.liu.se",
                '{"likes": ["CATIA", "Turbine Blades"]}',
                "/images/hampo845.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "guest",
            ),
            (
                "John",
                "Ashish",
                "johas759",
                "johas759@student.liu.se",
                '{"likes": ["python", "aircraft wings"]}',
                "/images/johas759.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "guest",
            ),
            (
                "Danial",
                "Nikpey",
                "danni741",
                "danni741@student.liu.se",
                '{"likes": ["vb.net", "aircraft wings"]}',
                "/images/danni741.jpg",
                '{"last_task": "Pick object", "successful_tasks": 5}',
                "guest",
            ),
        ]
        insert_query = """
            INSERT INTO users (first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory, role)
            VALUES (%s, %s, %s, %s, %s,%s,%s, %s);
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
            (1, 1, "pick", "Slide_1"),
            (2, 2, "travel", "Slide_1"),
            (3, 3, "drop", "Slide_1"),
            (4, 1, "pick", "Slide_2"),
            (5, 2, "travel", "Slide_2"),
            (6, 3, "drop", "Slide_2"),
            (7, 1, "pick", "Slide_3"),
            (8, 2, "travel", "Slide_3"),
            (9, 3, "drop", "Slide_3"),
            (10, 6, "go_home", ""),
        ]

        insert_query = """
            INSERT INTO operation_sequence (
                operation_id, sequence_id, sequence_name, object_name
            ) VALUES (%s, %s, %s, %s)
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
        self.cursor.execute(
            "SELECT COUNT(*) FROM camera_vision WHERE usd_name = 'Slide.usd'"
        )
        slide_usd_count = self.cursor.fetchone()[0]
        if slide_usd_count > 0:

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
                (i + 1, obj_name, False, "y", 0.01, False)
                for i, (seq_id, obj_name) in enumerate(pick_data)
            ]
            self.cursor.executemany(
                """
                INSERT INTO pick_op_parameters (
                    operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status
                )
                VALUES (%s, %s, %s, %s, %s, %s)

                """,
                pick_op_parameters,
            )

            # -- Travel Operation Parameters
            self.cursor.execute(
                "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'travel'"
            )
            travel_data = self.cursor.fetchall()
            travel_op_parameters = [
                (i + 1, obj_name, 0.085, "y-axis", False)
                for i, (_, obj_name) in enumerate(travel_data)
            ]

            self.cursor.executemany(
                """
                INSERT INTO travel_op_parameters (
                    operation_order, object_id, travel_height, gripper_rotation, operation_status
                )
                VALUES (%s, %s, %s, %s, %s)
                """,
                travel_op_parameters,
            )

            # -- Drop Operation Parameters
            self.cursor.execute(
                "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'drop'"
            )
            drop_data = self.cursor.fetchall()

            drop_op_parameters = [
                (i + 1, obj_name, -0.003, False)
                for i, (_, obj_name) in enumerate(drop_data)
            ]

            self.cursor.executemany(
                """
                INSERT INTO drop_op_parameters (
                    operation_order, object_id, drop_height, operation_status
                )
                VALUES (%s, %s, %s, %s)
                """,
                drop_op_parameters,
            )
        else:
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
                (i + 1, obj_name, False, "y", 0.01, False)
                for i, (seq_id, obj_name) in enumerate(pick_data)
            ]
            self.cursor.executemany(
                """
                INSERT INTO pick_op_parameters (
                    operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status
                )
                VALUES (%s, %s, %s, %s, %s, %s)

                """,
                pick_op_parameters,
            )

            # -- Travel Operation Parameters
            self.cursor.execute(
                "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'travel'"
            )
            travel_data = self.cursor.fetchall()
            travel_op_parameters = [
                (i + 1, obj_name, 0.085, "z-axis", False)
                for i, (_, obj_name) in enumerate(travel_data)
            ]

            self.cursor.executemany(
                """
                INSERT INTO travel_op_parameters (
                    operation_order, object_id, travel_height, gripper_rotation, operation_status
                )
                VALUES (%s, %s, %s, %s, %s)
                """,
                travel_op_parameters,
            )

            # -- Drop Operation Parameters
            self.cursor.execute(
                "SELECT sequence_id, object_name FROM operation_sequence WHERE sequence_name = 'drop'"
            )
            drop_data = self.cursor.fetchall()

            drop_op_parameters = [
                (i + 1, obj_name, -0.003, False)
                for i, (_, obj_name) in enumerate(drop_data)
            ]

            self.cursor.executemany(
                """
                INSERT INTO drop_op_parameters (
                    operation_order, object_id, drop_height, operation_status
                )
                VALUES (%s, %s, %s, %s)
                """,
                drop_op_parameters,
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

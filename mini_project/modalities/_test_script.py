# [2025-03-24 18:19:07] INFO - VoiceProcessor - 🚀 Starting voice capture process...
# [2025-03-24 18:19:07] INFO - VoiceProcessor - 🔈 Calibrating ambient noise...
# [2025-03-24 18:19:09] INFO - VoiceProcessor - ✅ Ambient noise calibration complete. Noise floor: 7.41
# [2025-03-24 18:19:09] INFO - VoiceProcessor - 🎚️ Amplitude threshold set to: 107.41 (Noise floor: 7.41 + Margin: 100)
# [2025-03-24 18:19:11] INFO - VoiceProcessor - 🗣️ Voice recording: Please speak now...
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 🎤 Recording completed. Duration: 6.37 seconds
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 💾 Audio saved to C:\Users\oscik559\Projects\mini_project_repo\assets\temp_audio\voice_recording.wav
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 📥 Audio recording completed. Starting transcription...
# [2025-03-24 18:19:19] INFO - faster_whisper - 🧠 Processing audio with duration 00:06.330
# [2025-03-24 18:19:19] INFO - faster_whisper - 🌐 Detected language 'en' with probability 0.56
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 📝 Transcription completed. Detected language: English
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 🗃️ Storing voice instruction in the database...
# [2025-03-24 18:19:20] INFO - VoiceProcessor - ✅ Voice instruction stored successfully in voice_instructions table.
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 🎉 Voice instruction captured and stored successfully!


        # Fetch and Populate Screw_Op_Parmeters
        self.cursor.execute(
            "SELECT sequence_id, object_name FROM Operation_Sequence WHERE sequence_name = 'screw'"
        )
        screw_data = self.cursor.fetchall()
        screw_op_parameters = [
            (i + 1, seq_id, obj_name, i % 2 == 0, 3, 0, False)  # Change 0 to False
            for i, (seq_id, obj_name) in enumerate(screw_data)
        ]
        self.cursor.executemany(
            "INSERT INTO Screw_Op_Parmeters (sequence_id, operation_order, object_id, rotation_dir, number_of_rotations, current_rotation, operation_status) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            screw_op_parameters,
        )







        # #rotate_state

        self.cursor.execute(
            "SELECT sequence_id, operation_order, object_id FROM Screw_Op_Parmeters "
        )
        rotate_data = self.cursor.fetchall()
        rotate_state_parameters = [
            (seq_id, operation_order, obj_name, 90, False)
            for (seq_id, operation_order, obj_name) in rotate_data
        ]

        # self.cursor.executemany(
        #     "INSERT INTO rotate_state_parmeters (sequence_id, operation_order, object_id,rotation_angle, operation_status) VALUES (%s, %s, %s, %s, %s)",
        #     rotate_state_parameters
        # )
        self.cursor.executemany(
            "INSERT INTO rotate_state_parmeters (sequence_id, operation_order, object_id, rotation_angle, operation_status) VALUES (%s, %s, %s, %s, %s)",
            rotate_state_parameters,
        )











        # Fetch and Populate Pick_Op_Parmeters

        self.cursor.execute(
            "SELECT sequence_id, object_name FROM Operation_Sequence WHERE sequence_name = 'pick'"
        )
        pick_data = self.cursor.fetchall()
        pick_op_parameters = [
            (seq_id, i + 1, obj_name, False, "y", 0.01, False)
            for i, (seq_id, obj_name) in enumerate(pick_data)
        ]
        self.cursor.executemany(
            "INSERT INTO Pick_Op_Parmeters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel,operation_status) VALUES (%s, %s, %s, %s, %s,%s,%s)",
            pick_op_parameters,
        )









        # Fetch and Populate Travel_Op_Parmeters
        self.cursor.execute(
            "SELECT sequence_id, object_name FROM Operation_Sequence WHERE sequence_name = 'travel'"
        )
        travel_data = self.cursor.fetchall()
        Travel_op_parameters = [
            (seq_id, i + 1, obj_name, 0.085, "z-axis", False)
            for i, (seq_id, obj_name) in enumerate(travel_data)
        ]
        self.cursor.executemany(
            "INSERT INTO Travel_Op_Parmeters (sequence_id, operation_order, object_id,travel_height ,gripper_rotation, operation_status) VALUES (%s, %s, %s, %s, %s,%s)",
            Travel_op_parameters,
        )








        # Populate isaac_sim_Gui
        isaac_sim_gui = [("Start", False), ("Reset", False), ("Load", False)]
        self.cursor.executemany(
            "INSERT INTO isaac_sim_Gui (GUI_feature, operation_status) VALUES (%s, %s)",
            isaac_sim_gui,
        )


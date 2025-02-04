#!/usr/bin/env python3
"""
facial_auth.py (with offline voice feedback)
"""

import pickle
import re
import sqlite3
import threading
from typing import Dict, Optional, Tuple, List

import cv2
import face_recognition
import numpy as np
import faiss
import pyttsx3  # Offline text-to-speech library

# Import your custom modules
from config import *
from db_handler import DatabaseHandler
from face_utils import FaceUtils


class FacialAuthSystem:
    def __init__(self):
        self.db_handler = DatabaseHandler(DB_PATH)
        self.face_utils = FaceUtils()
        self.known_encodings = self._preload_encodings()
        self.faiss_index = self._build_faiss_index()

        # Initialize voice feedback system
        self.voice_enabled = True
        self.tts_engine = None
        self._init_voice_system()

    def _init_voice_system(self):
        """Initialize the text-to-speech engine with error handling."""
        try:
            self.tts_engine = pyttsx3.init()
            # Configure voice properties
            voices = self.tts_engine.getProperty('voices')
            if voices:
                self.tts_engine.setProperty('voice', voices[0].id)  # Use the first available voice
            self.tts_engine.setProperty('rate', 150)  # Speaking speed
        except Exception as e:
            print(f"Voice system disabled: {str(e)}")
            self.voice_enabled = False

    def voice_feedback(self, text: str):
        """
        Provide non-blocking voice feedback using pyttsx3.
        Runs in a separate thread to avoid blocking the main program.
        """
        if not self.voice_enabled or not self.tts_engine:
            return

        def speak():
            try:
                self.tts_engine.say(text)
                self.tts_engine.runAndWait()
            except Exception as e:
                print(f"Voice feedback error: {str(e)}")

        # Run in a separate thread to avoid blocking
        threading.Thread(target=speak, daemon=True).start()

    def _preload_encodings(self) -> Dict[str, dict]:
        """Preload all face encodings from the database."""
        encodings = {}
        try:
            users = self.db_handler.cursor.execute(
                "SELECT user_id, first_name, last_name, LIU_id, face_encoding FROM user_profiles"
            ).fetchall()

            for user in users:
                if user[4]:  # face_encoding exists
                    encodings[user[3]] = {
                        'user_id': user[0],
                        'first_name': user[1],
                        'last_name': user[2],
                        'encodings': pickle.loads(user[4])
                    }
        except sqlite3.Error as e:
            print(f"Database error during encoding preload: {str(e)}")
        return encodings

    def _build_faiss_index(self):
        """Build a FAISS index for fast face encoding search."""
        if not self.known_encodings:
            return None

        # Flatten all encodings into a single array
        all_encodings = []
        self.user_ids = []  # Maps FAISS index to LIU IDs
        for LIU_id, user in self.known_encodings.items():
            for encoding in user['encodings']:
                all_encodings.append(encoding)
                self.user_ids.append(LIU_id)

        if not all_encodings:
            return None

        # Convert to a NumPy array and build FAISS index
        all_encodings = np.array(all_encodings, dtype=np.float32)
        index = faiss.IndexFlatL2(all_encodings.shape[1])  # L2 distance for similarity
        index.add(all_encodings)
        return index

    def _validate_user_input(self, LIU_id: str, email: str) -> bool:
        """Validate LIU ID and email formats."""
        if not re.match(LIU_ID_PATTERN, LIU_id):
            self.voice_feedback("Invalid LIU ID format. Expected format: abc123.")
            print("Invalid LIU ID format. Expected format: abc123")
            return False
        if not re.match(EMAIL_PATTERN, email):
            self.voice_feedback("Invalid email format.")
            print("Invalid email format")
            return False
        return True

    def _capture_face(self, capture_mode: str = 'auto') -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture face using specified mode (auto/manual) with voice guidance."""
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            self.voice_feedback("Camera not accessible. Please check your camera connection.")
            print("Error: Camera not accessible.")
            return None

        # Voice guidance based on capture mode
        if capture_mode == 'manual':
            self.voice_feedback("Manual capture mode. Position your face and press S when ready.")
        else:
            self.voice_feedback("Automatic capture in progress. Please face the camera directly.")

        consecutive_detections = 0
        captured_frame = None
        captured_encoding = None

        try:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break

                face_locations, face_encodings = self.face_utils.detect_faces(frame)
                frame = self.face_utils.draw_bounding_boxes(frame, face_locations)

                # Add instructional text on the frame
                cv2.putText(frame, "Press 's' to save, 'q' to quit" if capture_mode == 'manual' else "Face detected, capturing...",
                            (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

                if capture_mode == 'manual' and len(face_encodings) >= 1:
                    cv2.putText(frame, "Face detected!", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

                cv2.imshow("Face Capture", frame)
                key = cv2.waitKey(1) & 0xFF

                if key == ord('q'):
                    break
                if capture_mode == 'manual' and key == ord('s'):
                    if len(face_encodings) == 1:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        self.voice_feedback("Face captured successfully.")
                        break
                    else:
                        self.voice_feedback("Capture failed. Ensure one face is visible.")
                        print("No face or multiple faces detected!")
        finally:
            cap.release()
            cv2.destroyAllWindows()

        return captured_frame, captured_encoding

    def register_user(self):
        """Handle new user registration flow with voice guidance."""
        self.voice_feedback("Starting registration process.")
        frame_encoding = self._capture_face("manual")
        if not frame_encoding:
            self.voice_feedback("Face capture failed. Please try again.")
            print("Face capture failed")
            return

        frame, encoding = frame_encoding

        # Check if face is already registered using FAISS index
        if self.faiss_index is not None:
            query_encoding = np.array([encoding], dtype=np.float32)
            distances, indices = self.faiss_index.search(query_encoding, k=1)
            if distances[0][0] <= FACE_MATCH_THRESHOLD:
                matched_LIU_id = self.user_ids[indices[0][0]]
                existing_user = self.known_encodings.get(matched_LIU_id)
                if existing_user:
                    msg = f"User already registered as {existing_user['first_name']} {existing_user['last_name']}."
                    self.voice_feedback(msg + " Registration aborted.")
                    print(f"\n{msg}. Registration aborted.")
                    return

        # Voice-guided input collection
        self.voice_feedback("Please provide your details.")
        fields = [
            ('first_name', 'First Name'),
            ('last_name', 'Last Name'),
            ('LIU_id', 'LIU ID'),
            ('email', 'Email')
        ]

        user_data = {}
        for field, prompt in fields:
            self.voice_feedback(f"Please enter your {prompt.replace('_', ' ')}")
            user_data[field] = input(f"{prompt}: ").strip()

        # Validate input with voice feedback
        if not self._validate_user_input(user_data['LIU_id'], user_data['email']):
            self.voice_feedback("Invalid input format detected. Please check your details.")
            return

        # Database operations
        try:
            # Check for existing user by LIU ID or email
            existing = self.db_handler.cursor.execute(
                "SELECT user_id, face_encoding FROM user_profiles WHERE LIU_id = ? OR email = ?",
                (user_data['LIU_id'], user_data['email'])
            ).fetchone()

            if existing:
                self.voice_feedback("User already exists. Updating face encoding.")
                print("User already exists. Updating face encoding...")
                user_id, existing_encoding_blob = existing
                existing_encodings = pickle.loads(existing_encoding_blob) if existing_encoding_blob else []
                existing_encodings.append(encoding)
                existing_encodings = existing_encodings[-MAX_ENCODINGS_PER_USER:]  # Keep last N encodings

                # Update database
                self.db_handler.cursor.execute(
                    "UPDATE user_profiles SET face_encoding = ? WHERE user_id = ?",
                    (pickle.dumps(existing_encodings), user_id)
                )
                self.db_handler.conn.commit()
                self.voice_feedback(f"Face encoding updated for {user_data['first_name']} {user_data['last_name']}.")
                print(f"Face encoding updated for {user_data['first_name']} {user_data['last_name']}")
                return

            # Prepare extended fields
            profile_image_path = str(FACE_CAPTURE_PATH / f"{user_data['LIU_id']}.jpg")
            preferences = '{}'  # Default empty preferences
            interaction_history = '[]'  # Default empty history

            encoding_blob = pickle.dumps([encoding])
            self.db_handler.cursor.execute(
                """INSERT INTO user_profiles
                (first_name, last_name, LIU_id, email, face_encoding,
                preferences, profile_image_path, interaction_history)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (user_data['first_name'], user_data['last_name'], user_data['LIU_id'], user_data['email'], encoding_blob,
                 preferences, profile_image_path, interaction_history)
            )

            cv2.imwrite(profile_image_path, frame)
            self.db_handler.conn.commit()
            self.voice_feedback(f"Registration successful. Welcome {user_data['first_name']}!")
            print(f"User {user_data['first_name']} {user_data['last_name']} registered successfully")

        except sqlite3.Error as e:
            self.voice_feedback("Registration failed due to database error.")
            print(f"Database error: {str(e)}")
            self.db_handler.conn.rollback()

    def identify_user(self) -> Optional[dict]:
        """Identify user from face capture with voice feedback."""
        self.voice_feedback("Starting identification process.")
        frame_encoding = self._capture_face("auto")
        if not frame_encoding:
            self.voice_feedback("Face capture failed. Please try again.")
            return None

        _, encoding = frame_encoding

        if self.faiss_index is None:
            self.voice_feedback("No users registered in the database.")
            print("No users registered in the database.")
            return None

        # Convert encoding to FAISS-compatible format
        query_encoding = np.array([encoding], dtype=np.float32)

        # Search FAISS index
        distances, indices = self.faiss_index.search(query_encoding, k=1)
        if distances[0][0] > FACE_MATCH_THRESHOLD:
            self.voice_feedback("No match found.")
            print("No match found.")
            return None

        # Get the matched user based on LIU ID mapping
        matched_LIU_id = self.user_ids[indices[0][0]]
        user = self.known_encodings[matched_LIU_id]
        self.voice_feedback(f"Welcome back, {user['first_name']} {user['last_name']}!")
        print(f"\nWelcome back, {user['first_name']} {user['last_name']}!")
        return user

    def run(self):
        """Main application flow with voice navigation."""
        self.voice_feedback("Facial authentication system ready. Main menu options: 1. Identify User. 2. Register User. 3. Exit.")

        while True:
            print("\n1. Identify User\n2. Register User\n3. Exit")
            choice = input("Choice: ").strip()

            if choice == '1':
                self.voice_feedback("You selected user identification.")
                if not self.known_encodings:
                    self.voice_feedback("No registered users found.")
                    print("No registered users found.")
                    option = input("Would you like to register? (1: Register, 2: Exit): ").strip()
                    if option == '1':
                        self.register_user()
                    else:
                        self.db_handler.close()
                        self.voice_feedback("Exiting system. Goodbye!")
                        print("Exiting...")
                        break
                    continue

                user = self.identify_user()
                if not user:
                    self.voice_feedback("User not recognized.")
                    print("\nUser not recognized.")
                    option = input("Options:\n1. Register new user\n2. Exit\nChoice: ").strip()
                    if option == '1':
                        self.register_user()
                    else:
                        self.db_handler.close()
                        self.voice_feedback("Exiting system. Goodbye!")
                        print("Exiting...")
                        break

            elif choice == '2':
                self.voice_feedback("You selected user registration.")
                self.register_user()

            elif choice == '3':
                self.db_handler.close()
                self.voice_feedback("Exiting system. Goodbye!")
                print("Exiting...")
                break

            else:
                self.voice_feedback("Invalid option. Please try again.")
                print("Invalid choice!")


if __name__ == "__main__":
    FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
    FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)

    auth_system = FacialAuthSystem()
    auth_system.run()
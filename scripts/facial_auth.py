"""
facial_auth.py (optimized with FAISS and database-centric design)

Modifications:
- Automatic identify user process.
- If user not recognized, offer only: 1. Register new user  2. Exit.
- Registration face capture is forced to manual mode.
"""

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

import pickle
import re
import sqlite3
from typing import Dict, List, Optional, Tuple

import cv2
import face_recognition
import faiss  # For fast similarity search
import numpy as np
from config.config import *
# from config.config import DB_PATH
from db_handler import DatabaseHandler
from face_utils import FaceUtils


class FacialAuthSystem:
    def __init__(self):
        self.db_handler = DatabaseHandler(DB_PATH)
        self.face_utils = FaceUtils()
        self.known_encodings = self._preload_encodings()
        self.faiss_index = self._build_faiss_index()  # FAISS index for fast search

    def _preload_encodings(self) -> Dict[str, dict]:
        """Preload all face encodings from database"""
        encodings = {}
        try:
            users = self.db_handler.cursor.execute(
                "SELECT user_id, first_name, last_name, liu_id, face_encoding FROM users"
            ).fetchall()

            for user in users:
                if user[4]:  # face_encoding exists
                    encodings[user[3]] = {
                        "user_id": user[0],
                        "first_name": user[1],
                        "last_name": user[2],
                        "encodings": pickle.loads(user[4]),
                    }
        except sqlite3.Error as e:
            print(f"Database error during encoding preload: {str(e)}")
        return encodings

    def _build_faiss_index(self):
        """Build a FAISS index for fast face encoding search"""
        if not self.known_encodings:
            return None

        # Flatten all encodings into a single array
        all_encodings = []
        self.user_ids = []  # Maps FAISS index to LIU IDs
        for liu_id, user in self.known_encodings.items():
            for encoding in user["encodings"]:
                all_encodings.append(encoding)
                self.user_ids.append(liu_id)

        if not all_encodings:
            return None

        # Convert to a NumPy array and build FAISS index
        all_encodings = np.array(all_encodings, dtype=np.float32)
        index = faiss.IndexFlatL2(all_encodings.shape[1])  # L2 distance for similarity
        index.add(all_encodings)
        return index

    def _validate_user_input(self, liu_id: str, email: str) -> bool:
        """Validate LIU ID and email formats"""
        if not re.match(LIU_ID_PATTERN, liu_id):
            print("Invalid LIU ID format. Expected format: abc123")
            return False
        if not re.match(EMAIL_PATTERN, email):
            print("Invalid email format")
            return False
        return True

    def _capture_face(
        self, capture_mode: str = "auto"
    ) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture face using specified mode (auto/manual)"""
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            print("Error: Camera not accessible.")
            return None

        consecutive_detections = 0
        captured_frame = None
        captured_encoding = None
        instructions = {
            "auto": "Face detected, capturing...",
            "manual": "Press 's' to save, 'q' to quit",
        }

        try:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break

                face_locations, face_encodings = self.face_utils.detect_faces(frame)
                frame = self.face_utils.draw_bounding_boxes(frame, face_locations)

                # Add instructional text on the frame
                cv2.putText(
                    frame,
                    instructions[capture_mode],
                    (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0),
                    2,
                )

                if capture_mode == "auto":
                    if len(face_encodings) == 1:
                        consecutive_detections += 1
                        cv2.putText(
                            frame,
                            f"Detected: {consecutive_detections}/{AUTO_CAPTURE_FRAME_COUNT}",
                            (10, 60),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.7,
                            (0, 255, 0),
                            2,
                        )
                        if consecutive_detections >= AUTO_CAPTURE_FRAME_COUNT:
                            captured_frame = frame
                            captured_encoding = face_encodings[0]
                            break
                    else:
                        consecutive_detections = 0
                else:  # manual mode
                    if len(face_encodings) >= 1:
                        cv2.putText(
                            frame,
                            "Face detected!",
                            (10, 60),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.7,
                            (0, 255, 0),
                            2,
                        )

                cv2.imshow("Face Capture", frame)
                key = cv2.waitKey(1) & 0xFF

                if key == ord("q"):
                    break
                if capture_mode == "manual" and key == ord("s"):
                    if len(face_encodings) == 1:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        break
                    else:
                        print("No face or multiple faces detected!")
        finally:
            cap.release()
            cv2.destroyAllWindows()

        if captured_frame is not None:
            return captured_frame, captured_encoding
        return None

    def register_user(self):
        """Handle new user registration flow (manual capture forced)"""
        # Force manual capture for registration
        capture_mode = "manual"
        frame_encoding = self._capture_face(capture_mode)
        if not frame_encoding:
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
                    print(
                        f"\nUser already registered as {existing_user['first_name']} {existing_user['last_name']} (LIU ID: {matched_LIU_id})."
                    )
                    print("Registration aborted.")
                    return

        print("\n--- New User Registration ---")
        first_name = input("First Name: ").strip()
        last_name = input("Last Name: ").strip()
        liu_id = input("LIU ID: ").strip()
        email = input("Email: ").strip()

        if not self._validate_user_input(liu_id, email):
            return

        try:
            # Check for existing user by LIU ID or email
            existing = self.db_handler.cursor.execute(
                "SELECT user_id, face_encoding FROM users WHERE liu_id = ? OR email = ?",
                (liu_id, email),
            ).fetchone()

            if existing:
                print("User already exists. Updating face encoding...")
                user_id, existing_encoding_blob = existing
                existing_encodings = (
                    pickle.loads(existing_encoding_blob)
                    if existing_encoding_blob
                    else []
                )
                existing_encodings.append(encoding)
                existing_encodings = existing_encodings[
                    -MAX_ENCODINGS_PER_USER:
                ]  # Keep last N encodings

                # Update database
                self.db_handler.cursor.execute(
                    "UPDATE users SET face_encoding = ? WHERE user_id = ?",
                    (pickle.dumps(existing_encodings), user_id),
                )
                self.db_handler.conn.commit()
                print(f"Face encoding updated for {first_name} {last_name}")
                return

            # Prepare extended fields
            profile_image_path = str(FACE_CAPTURE_PATH / f"{liu_id}.jpg")
            preferences = "{}"  # Default empty preferences
            interaction_memory = "[]"  # Default empty history

            encoding_blob = pickle.dumps([encoding])
            self.db_handler.cursor.execute(
                """INSERT INTO users
                (first_name, last_name, liu_id, email, face_encoding,
                preferences, profile_image_path, interaction_memory)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (
                    first_name,
                    last_name,
                    liu_id,
                    email,
                    encoding_blob,
                    preferences,
                    profile_image_path,
                    interaction_memory,
                ),
            )

            cv2.imwrite(profile_image_path, frame)
            self.db_handler.conn.commit()
            print(f"User {first_name} {last_name} registered successfully")

        except sqlite3.Error as e:
            print(f"Database error: {str(e)}")
            self.db_handler.conn.rollback()

    def identify_user(self) -> Optional[dict]:
        """Identify user from face capture using FAISS for fast matching with automatic capture"""
        # Force automatic capture for identification
        capture_mode = "auto"
        frame_encoding = self._capture_face(capture_mode)
        if not frame_encoding:
            return None

        _, encoding = frame_encoding

        if self.faiss_index is None:
            print("No users registered in the database.")
            return None

        # Convert encoding to FAISS-compatible format
        query_encoding = np.array([encoding], dtype=np.float32)

        # Search FAISS index
        distances, indices = self.faiss_index.search(query_encoding, k=1)
        if distances[0][0] > FACE_MATCH_THRESHOLD:
            print("No match found.")
            return None

        # Get the matched user based on LIU ID mapping
        matched_LIU_id = self.user_ids[indices[0][0]]
        return self.known_encodings[matched_LIU_id]

    def run(self):
        """Main application flow"""
        while True:
            print("\n1. Identify User\n2. Register User\n3. Exit")
            choice = input("Choice: ").strip()

            if choice == "1":
                if not self.known_encodings:
                    print("No registered users found.")
                    option = input(
                        "Would you like to register? (1: Register, 2: Exit): "
                    ).strip()
                    if option == "1":
                        self.register_user()
                    else:
                        self.db_handler.close()
                        print("Exiting...")
                        break
                    continue

                user = self.identify_user()
                if user:
                    print(f"\nWelcome back, {user['first_name']} {user['last_name']}!")
                else:
                    print("\nUser not recognized.")
                    option = input(
                        "Options:\n1. Register new user\n2. Exit\nChoice: "
                    ).strip()
                    if option == "1":
                        self.register_user()
                    else:
                        self.db_handler.close()
                        print("Exiting...")
                        break

            elif choice == "2":
                self.register_user()

            elif choice == "3":
                self.db_handler.close()
                print("Exiting...")
                break


if __name__ == "__main__":
    FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
    FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)

    auth_system = FacialAuthSystem()
    auth_system.run()

import logging
import pickle
import re
import sqlite3
import sys
import unittest
from contextlib import closing
from pathlib import Path
from typing import Dict, List, Optional, Tuple

sys.path.append(str(Path(__file__).parent.parent))

import cv2
import face_recognition
import faiss  # For fast similarity search
import numpy as np
from db_handler import DatabaseHandler

# Import configuration variables.
from config.config import \
    MAX_ENCODINGS_PER_USER  # Set to 5 in your configuration
from config.config import (AUTO_CAPTURE_FRAME_COUNT, DB_PATH, EMAIL_PATTERN,
                           FACE_CAPTURE_PATH, FACE_MATCH_THRESHOLD,
                           FACIAL_DATA_PATH, LIU_ID_PATTERN)

# Configure logging with granular levels.
logging.basicConfig(level=logging.DEBUG, format="%(asctime)s [%(levelname)s] %(message)s")


class FaceUtils:
    """Utility methods for face processing with OpenCV and face_recognition."""

    @staticmethod
    def detect_faces(frame: np.ndarray) -> Tuple[List[tuple], List[np.ndarray]]:
        """
        Detect faces and compute encodings in a frame.

        Returns:
            Tuple containing the list of face locations and corresponding encodings.
        """
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)
        return face_locations, face_encodings

    @staticmethod
    def draw_bounding_boxes(frame: np.ndarray, face_locations: List[tuple]) -> np.ndarray:
        """Draw bounding boxes around detected faces."""
        for (top, right, bottom, left) in face_locations:
            cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
        return frame

    @staticmethod
    def draw_text(
        frame: np.ndarray,
        text: str,
        position: Tuple[int, int] = (10, 30),
        font_scale: float = 0.7,
        color: Tuple[int, int, int] = (0, 255, 0),
        thickness: int = 2,
    ) -> None:
        """Draw text on a frame at the given position."""
        cv2.putText(frame, text, position, cv2.FONT_HERSHEY_SIMPLEX, font_scale, color, thickness)

    @staticmethod
    def select_best_face(face_encodings: List[np.ndarray], face_locations: List[tuple]) -> int:
        """Select the largest face when multiple faces are detected."""
        face_sizes = [
            (bottom - top) * (right - left)
            for (top, right, bottom, left) in face_locations
        ]
        return int(np.argmax(face_sizes))


class FaceAuthSystem:
    def __init__(self) -> None:
        self.db_handler = DatabaseHandler(DB_PATH)
        self.face_utils = FaceUtils()
        self.known_encodings: Dict[str, dict] = self._preload_encodings()
        self.faiss_index: Optional[faiss.IndexFlatL2] = self._build_faiss_index()

    def _preload_encodings(self) -> Dict[str, dict]:
        """Preload all face encodings from the database."""
        encodings: Dict[str, dict] = {}
        try:
            with self.db_handler.conn:
                cursor = self.db_handler.conn.cursor()
                users = cursor.execute(
                    "SELECT user_id, first_name, last_name, liu_id, face_encoding FROM users"
                ).fetchall()
            for user in users:
                if user[4]:  # Ensure face_encoding exists.
                    encodings[user[3]] = {
                        "user_id": user[0],
                        "first_name": user[1],
                        "last_name": user[2],
                        "encodings": pickle.loads(user[4]),
                    }
        except sqlite3.Error as e:
            logging.error("Database error during encoding preload: %s", e)
        return encodings

    def _build_faiss_index(self) -> Optional[faiss.IndexFlatL2]:
        """Build a FAISS index for fast face encoding search."""
        if not self.known_encodings:
            logging.debug("No known encodings to build FAISS index.")
            return None

        all_encodings: List[np.ndarray] = []
        self.user_ids: List[str] = []  # Maps FAISS index entries to LIU IDs.
        for liu_id, user in self.known_encodings.items():
            for encoding in user["encodings"]:
                all_encodings.append(encoding)
                self.user_ids.append(liu_id)

        if not all_encodings:
            logging.debug("No encodings found after processing known_encodings.")
            return None

        all_encodings_np = np.array(all_encodings, dtype=np.float32)
        index = faiss.IndexFlatL2(all_encodings_np.shape[1])
        index.add(all_encodings_np)
        logging.debug("FAISS index built with %d encodings.", all_encodings_np.shape[0])
        return index

    def _refresh_index(self) -> None:
        """Refresh the in-memory known encodings and rebuild the FAISS index."""
        self.known_encodings = self._preload_encodings()
        self.faiss_index = self._build_faiss_index()
        logging.info("FAISS index and known encodings refreshed.")

    def _validate_user_input(self, liu_id: str, email: str) -> bool:
        """Validate LIU ID and email formats."""
        if not re.match(LIU_ID_PATTERN, liu_id):
            logging.error("Invalid LIU ID format. Expected format: abc123")
            return False
        if not re.match(EMAIL_PATTERN, email):
            logging.error("Invalid email format")
            return False
        return True

    def _process_frame(self, cap: cv2.VideoCapture, instruction: str) -> Tuple[Optional[np.ndarray], List[tuple], List[np.ndarray]]:
        """
        Read a frame from the camera, process it (face detection, bounding boxes),
        and overlay instruction text.

        Returns:
            A tuple of (frame, face_locations, face_encodings) or (None, [], []) if frame read fails.
        """
        ret, frame = cap.read()
        if not ret:
            logging.debug("No frame retrieved from camera.")
            return None, [], []
        face_locations, face_encodings = self.face_utils.detect_faces(frame)
        frame = self.face_utils.draw_bounding_boxes(frame, face_locations)
        self.face_utils.draw_text(frame, instruction)
        return frame, face_locations, face_encodings

    def _capture_face_auto(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture a face in automatic mode."""
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            logging.error("Error: Camera not accessible.")
            return None

        consecutive_detections = 0  # Counter for consecutive frames with exactly one face detected.
        captured_frame: Optional[np.ndarray] = None
        captured_encoding: Optional[np.ndarray] = None

        try:
            while True:
                # Process the frame with an instruction.
                frame, face_locations, face_encodings = self._process_frame(cap, "Face detected, capturing...")
                if frame is None:
                    logging.debug("Frame processing failed; exiting auto capture loop.")
                    break

                # If exactly one face is detected, increment the counter.
                if len(face_encodings) == 1:
                    consecutive_detections += 1
                    self.face_utils.draw_text(
                        frame,
                        f"Detected: {consecutive_detections}/{AUTO_CAPTURE_FRAME_COUNT}",
                        position=(10, 60),
                    )
                    # Once the counter reaches the threshold, capture the frame.
                    if consecutive_detections >= AUTO_CAPTURE_FRAME_COUNT:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logging.debug("Auto capture threshold reached; capturing face.")
                        break
                else:
                    # Reset the counter if no face or multiple faces are detected.
                    consecutive_detections = 0

                cv2.imshow("Face Capture - Auto", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logging.info("Auto capture aborted by user.")
                    break
        finally:
            cap.release()
            cv2.destroyAllWindows()

        if captured_frame is not None and captured_encoding is not None:
            return captured_frame, captured_encoding
        return None

    def _capture_face_manual(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture a face in manual mode."""
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            logging.error("Error: Camera not accessible.")
            return None

        captured_frame: Optional[np.ndarray] = None
        captured_encoding: Optional[np.ndarray] = None

        try:
            while True:
                frame, face_locations, face_encodings = self._process_frame(cap, "Press 's' to save, 'q' to quit")
                if frame is None:
                    logging.debug("Frame processing failed; exiting manual capture loop.")
                    break

                if len(face_encodings) >= 1:
                    self.face_utils.draw_text(frame, "Face detected!", position=(10, 60))

                cv2.imshow("Face Capture - Manual", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logging.info("Manual capture aborted by user.")
                    break
                if key == ord("s"):
                    if len(face_encodings) == 1:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logging.debug("Face captured in manual mode.")
                        break
                    else:
                        logging.warning("No face or multiple faces detected; cannot capture.")
        finally:
            cap.release()
            cv2.destroyAllWindows()

        if captured_frame is not None and captured_encoding is not None:
            return captured_frame, captured_encoding
        return None

    def _capture_face(self, capture_mode: str = "auto") -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture a face using the specified mode (auto/manual)."""
        if capture_mode == "auto":
            return self._capture_face_auto()
        else:
            return self._capture_face_manual()

    def register_user(self) -> None:
        """
        Handle new user registration (manual capture forced).

        This method now queries the database for an existing user (by LIU ID or email)
        after capturing the face. If an existing user is found, it prompts the user to confirm
        whether to update the stored face encoding.
        """
        # Force manual capture for registration.
        frame_encoding = self._capture_face("manual")
        if not frame_encoding:
            logging.error("Face capture failed during registration.")
            return

        frame, encoding = frame_encoding
        logging.info("Face captured for registration.")

        # Ask for registration details.
        logging.info("--- New User Registration ---")
        first_name = input("First Name: ").strip()
        last_name = input("Last Name: ").strip()
        liu_id = input("LIU ID: ").strip()
        email = input("Email: ").strip()

        # Check for empty first or last names.
        if not first_name or not last_name:
            logging.error("First name and last name cannot be empty.")
            return

        if not self._validate_user_input(liu_id, email):
            return

        try:
            with self.db_handler.conn:
                cursor = self.db_handler.conn.cursor()
                # Query the database for an existing user with the same LIU ID or email.
                existing = cursor.execute(
                    "SELECT user_id, face_encoding FROM users WHERE liu_id = ? OR email = ?",
                    (liu_id, email),
                ).fetchone()

                if existing:
                    logging.info("User already exists. Prompting for update confirmation...")
                    confirm = input("Update face encoding? (y/n): ").strip().lower()
                    if confirm != "y":
                        logging.info("Registration aborted by user.")
                        return
                    else:
                        logging.info("User confirmed update of face encoding.")
                        user_id, existing_encoding_blob = existing
                        existing_encodings = (
                            pickle.loads(existing_encoding_blob)
                            if existing_encoding_blob
                            else []
                        )
                        existing_encodings.append(encoding)
                        # Enforce maximum of MAX_ENCODINGS_PER_USER.
                        existing_encodings = existing_encodings[-MAX_ENCODINGS_PER_USER:]
                        cursor.execute(
                            "UPDATE users SET face_encoding = ? WHERE user_id = ?",
                            (pickle.dumps(existing_encodings), user_id),
                        )
                        logging.info("Face encoding updated for %s %s", first_name, last_name)
                        self._refresh_index()
                        return

                else:
                    # Insert new user into the database.
                    profile_image_path = str(FACE_CAPTURE_PATH / f"{liu_id}.jpg")
                    preferences = "{}"  # Default empty preferences.
                    interaction_memory = "[]"  # Default empty history.
                    encoding_blob = pickle.dumps([encoding])
                    cursor.execute(
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
                    logging.info("User %s %s registered successfully", first_name, last_name)
        except sqlite3.Error as e:
            logging.error("Database error: %s", e)
            self.db_handler.conn.rollback()
            return

        # Refresh the in-memory encodings and rebuild the FAISS index after registration.
        self._refresh_index()

    def identify_user(self) -> Optional[dict]:
        """Identify a user using FAISS-based matching with automatic face capture."""
        frame_encoding = self._capture_face("auto")
        if not frame_encoding:
            return None

        _, encoding = frame_encoding

        if self.faiss_index is None:
            logging.error("No users registered in the database.")
            return None

        query_encoding = np.array([encoding], dtype=np.float32)
        distances, indices = self.faiss_index.search(query_encoding, k=1)
        if distances[0][0] > FACE_MATCH_THRESHOLD:
            logging.info("No match found during identification.")
            return None

        matched_LIU_id = self.user_ids[indices[0][0]]
        return self.known_encodings.get(matched_LIU_id)

    def run(self) -> None:
        """Main application flow."""
        while True:
            print("\n1. Identify User\n2. Register User\n3. Exit")
            choice = input("Choice: ").strip()

            if choice == "1":
                if not self.known_encodings:
                    logging.info("No registered users found.")
                    option = input("Would you like to register? (1: Register, 2: Exit): ").strip()
                    if option == "1":
                        self.register_user()
                    else:
                        self.db_handler.close()
                        logging.info("Exiting...")
                        break
                    continue

                user = self.identify_user()
                if user:
                    logging.info("Welcome back, %s %s!", user["first_name"], user["last_name"])
                else:
                    logging.info("User not recognized.")
                    option = input("Options:\n1. Register new user\n2. Exit\nChoice: ").strip()
                    if option == "1":
                        self.register_user()
                    else:
                        self.db_handler.close()
                        logging.info("Exiting...")
                        break

            elif choice == "2":
                self.register_user()

            elif choice == "3":
                self.db_handler.close()
                logging.info("Exiting...")
                break


# Unit tests for critical components.

# (Other imports and your FaceAuthSystem and FaceUtils classes go here.)

class TestFaceUtils(unittest.TestCase):
    def test_detect_faces_empty(self):
        # Create an empty black image.
        import numpy as np
        frame = np.zeros((100, 100, 3), dtype=np.uint8)
        locations, encodings = FaceUtils.detect_faces(frame)
        self.assertIsInstance(locations, list)
        self.assertIsInstance(encodings, list)

class TestInputValidation(unittest.TestCase):
    def test_validate_user_input(self):
        auth = FaceAuthSystem()
        # Assuming LIU_ID_PATTERN and EMAIL_PATTERN are set to accept "abc123" and a valid email.
        self.assertTrue(auth._validate_user_input("abc123", "test@example.com"))
        self.assertFalse(auth._validate_user_input("wrong", "wrong"))

class TestFaissIndexBuilding(unittest.TestCase):
    def test_build_faiss_index_empty(self):
        auth = FaceAuthSystem()
        auth.known_encodings = {}
        index = auth._build_faiss_index()
        self.assertIsNone(index)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        # Remove the "test" argument so that unittest doesn't get confused.
        sys.argv.pop(1)
        unittest.main(verbosity=2)
    else:
        # Run your main application code.
        # Ensure required directories exist.
        from config.config import FACE_CAPTURE_PATH, FACIAL_DATA_PATH
        FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
        FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)

        auth_system = FaceAuthSystem()
        auth_system.run()

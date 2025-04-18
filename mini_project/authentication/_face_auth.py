# authentication/face_auth_pgSQL.py
"""
Classes:
    FaceUtils:
        A utility class for face detection, bounding box drawing, and encoding selection.
    FaceAuthSystem:
        The main class for managing face authentication, including:
        - Preloading and managing face encodings.
        - Building and refreshing a FAISS index for similarity search.
        - Capturing faces in automatic, manual, or multi-face modes.
        - Registering new users with face and voice data.
        - Identifying users based on captured face data.
Functions:
    VideoCaptureContext(index: int = 0):
        A context manager for handling video capture resources.
    main():
        Entry point for the FaceAuthSystem application. Initializes directories and starts the system.
Constants:
    AUTO_CAPTURE_FRAME_COUNT: Number of consecutive frames required for automatic face capture.
    EMAIL_PATTERN: Regular expression pattern for validating email addresses.
    FACE_CAPTURE_PATH: Path for saving captured face images.
    FACE_MATCH_THRESHOLD: Threshold for face similarity matching.
    FACIAL_DATA_PATH: Path for storing facial data.
    IDENTIFICATION_FRAMES: Number of frames to process during user identification.
    LIU_ID_PATTERN: Regular expression pattern for validating LIU IDs.
    MAX_ENCODINGS_PER_USER: Maximum number of face encodings to store per user.
    TEMP_AUDIO_PATH: Path for storing temporary audio files.
    TIMEDELAY: Delay between frames during identification.
    VOICE_DATA_PATH: Path for storing voice data.
"""


# import sys
import logging
import pickle
import re
import time
from contextlib import contextmanager
from typing import Dict, List, Optional, Tuple

import cv2
import face_recognition
import faiss  # For fast similarity search
import numpy as np
import psycopg2

from config.app_config import (
    AUTO_CAPTURE_FRAME_COUNT,
    EMAIL_PATTERN,
    FACE_CAPTURE_PATH,
    FACE_MATCH_THRESHOLD,
    FACIAL_DATA_PATH,
    IDENTIFICATION_FRAMES,
    LIU_ID_PATTERN,
    MAX_ENCODINGS_PER_USER,
    TEMP_AUDIO_PATH,
    TIMEDELAY,
    VOICE_DATA_PATH,
    setup_logging,
)
from mini_project.authentication._voice_auth import VoiceAuth
from mini_project.database.connection import get_connection

logger = logging.getLogger("FaceAuthSystem")


# Context manager for handling an video session.
@contextmanager
def VideoCaptureContext(index: int = 0):
    cap = cv2.VideoCapture(index)
    try:
        yield cap
    finally:
        cap.release()


class FaceUtils:

    @staticmethod
    def detect_faces(frame: np.ndarray) -> Tuple[List[tuple], List[np.ndarray]]:
        """
        Detect faces and compute encodings in a frame.

        Returns:
            A tuple of (face_locations, face_encodings).
        """
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)
        return face_locations, face_encodings

    @staticmethod
    def draw_bounding_boxes(
        frame: np.ndarray, face_locations: List[tuple]
    ) -> np.ndarray:
        """Draw bounding boxes around detected faces."""
        for top, right, bottom, left in face_locations:
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
        """Overlay text on the frame at the given position."""
        cv2.putText(
            frame,
            text,
            position,
            cv2.FONT_HERSHEY_SIMPLEX,
            font_scale,
            color,
            thickness,
        )

    @staticmethod
    def select_best_face(
        face_encodings: List[np.ndarray], face_locations: List[tuple]
    ) -> int:
        """
        Select the largest face when multiple faces are detected.

        Returns:
            The index of the face with the largest bounding box.
        """
        face_sizes = [
            (bottom - top) * (right - left)
            for (top, right, bottom, left) in face_locations
        ]
        return int(np.argmax(face_sizes))


class FaceAuthSystem:
    def __init__(self) -> None:
        self.conn = get_connection()
        self.cursor = self.conn.cursor()
        self.face_utils = FaceUtils()
        self.known_encodings: Dict[str, dict] = self._preload_encodings()
        self.faiss_index: Optional[faiss.IndexFlatL2] = self._build_faiss_index()

    def _preload_encodings(self) -> Dict[str, dict]:
        """Preload all face encodings from the database."""
        encodings: Dict[str, dict] = {}
        try:
            self.cursor.execute(
                "SELECT user_id, first_name, last_name, liu_id, face_encoding, voice_embedding FROM users"
            )
            users = self.cursor.fetchall()
            for user in users:
                if user[4]:
                    encodings[user[3]] = {
                        "user_id": user[0],
                        "first_name": user[1],
                        "last_name": user[2],
                        "liu_id": user[3],
                        "encodings": pickle.loads(user[4].tobytes()),
                        "voice_embedding": (
                            pickle.loads(user[5].tobytes())[0] if user[5] else None
                        ),
                    }
        except psycopg2.Error as e:
            logger.error("🔴 Database error during encoding preload: %s", e)
        return encodings

    def _build_faiss_index(self) -> Optional[faiss.IndexFlatL2]:
        """Build a FAISS index for fast face encoding search."""
        if not self.known_encodings:
            logger.debug("No known encodings to build FAISS index.")
            return None

        all_encodings: List[np.ndarray] = []
        self.user_ids: List[str] = []  # Maps FAISS index entries to LIU IDs.
        for liu_id, user in self.known_encodings.items():
            for encoding in user["encodings"]:
                all_encodings.append(encoding)
                self.user_ids.append(liu_id)
        if not all_encodings:
            logger.debug("No encodings found after processing known_encodings.")
            return None

        all_encodings_np = np.array(all_encodings, dtype=np.float32)
        index = faiss.IndexFlatL2(all_encodings_np.shape[1])
        index.add(all_encodings_np)
        logger.debug("FAISS index built with %d encodings.", all_encodings_np.shape[0])
        return index

    def _refresh_index(self) -> None:
        """Refresh the in-memory known encodings and rebuild the FAISS index."""
        self.known_encodings = self._preload_encodings()
        self.faiss_index = self._build_faiss_index()
        logger.info("✅ FAISS index and known encodings refreshed.")

    def _validate_user_input(self, liu_id: str, email: str) -> bool:
        """Validate LIU ID and email formats."""
        if not re.match(LIU_ID_PATTERN, liu_id):
            logger.error("🔴 Invalid LIU ID format. Expected format: abc123")
            return False
        if not re.match(EMAIL_PATTERN, email):
            logger.error("🔴 Invalid email format")
            return False
        return True

    def _process_frame(
        self, cap: cv2.VideoCapture, instruction: str
    ) -> Tuple[Optional[np.ndarray], List[tuple], List[np.ndarray]]:
        """
        Read a frame from the camera, process it (face detection and bounding boxes),
        and overlay instruction text.

        Returns:
            A tuple of (frame, face_locations, face_encodings) or (None, [], []) if frame read fails.
        """
        ret, frame = cap.read()
        if not ret:
            logger.debug("No frame retrieved from camera.")
            return None, [], []
        face_locations, face_encodings = self.face_utils.detect_faces(frame)
        frame = self.face_utils.draw_bounding_boxes(frame, face_locations)
        self.face_utils.draw_text(frame, instruction)
        return frame, face_locations, face_encodings

    def _capture_face_auto(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Capture a face in automatic mode.
        Uses a consecutive detection counter to ensure stable detection.
        """
        with VideoCaptureContext(0) as cap:
            if not cap.isOpened():
                logger.error("🔴 Error: Camera not accessible.")
                return None
            consecutive_detections = (
                0  # Count of consecutive frames with exactly one face.
            )
            captured_frame: Optional[np.ndarray] = None
            captured_encoding: Optional[np.ndarray] = None

            while True:
                frame, _, face_encodings = self._process_frame(
                    cap, "Face detected, capturing..."
                )
                if frame is None:
                    logger.debug("Frame processing failed; exiting auto capture loop.")
                    break

                if len(face_encodings) == 1:
                    consecutive_detections += 1
                    self.face_utils.draw_text(
                        frame,
                        f"Detected: {consecutive_detections}/{AUTO_CAPTURE_FRAME_COUNT}",
                        position=(10, 60),
                    )
                    if consecutive_detections >= AUTO_CAPTURE_FRAME_COUNT:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logger.debug("Auto capture threshold reached; capturing face.")
                        break
                else:
                    # Reset the counter if no face or multiple faces are detected.
                    consecutive_detections = 0

                cv2.imshow("Face Capture - Auto", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logger.info("Auto capture aborted by user.")
                    break

            cv2.destroyAllWindows()
            if captured_frame is not None and captured_encoding is not None:
                return captured_frame, captured_encoding
            return None

    def _capture_face_manual(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Capture a face in manual mode.
        The user must press 's' to save when a single face is detected.
        """
        with VideoCaptureContext(0) as cap:
            if not cap.isOpened():
                logger.error("🔴 Error: Camera not accessible.")
                return None

            captured_frame: Optional[np.ndarray] = None
            captured_encoding: Optional[np.ndarray] = None

            while True:
                frame, _, face_encodings = self._process_frame(
                    cap, "Press 's' to save, 'q' to quit"
                )
                if frame is None:
                    logger.debug(
                        "Frame processing failed; exiting manual capture loop."
                    )
                    break

                if len(face_encodings) >= 1:
                    self.face_utils.draw_text(
                        frame, "Face detected!", position=(10, 60)
                    )

                cv2.imshow("Face Capture - Manual", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logger.info("Manual capture aborted by user.")
                    break
                if key == ord("s"):
                    if len(face_encodings) == 1:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logger.debug("Face captured in manual mode.")
                        break
                    else:
                        logger.warning(
                            "No face or multiple faces detected; cannot capture."
                        )

            cv2.destroyAllWindows()
            if captured_frame is not None and captured_encoding is not None:
                return captured_frame, captured_encoding
            return None

    def _capture_face(
        self, capture_mode: str = "auto"
    ) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """Capture a face using the specified mode (auto/manual)."""
        if capture_mode == "auto":
            return self._capture_face_auto()
        else:
            return self._capture_face_manual()

    def _capture_face_multi(
        self,
    ) -> Optional[Tuple[np.ndarray, List[np.ndarray], List[tuple]]]:
        """
        Capture a single frame and return all detected face encodings and locations.
        This mode is used for identification whether one or multiple faces are present.
        """
        with VideoCaptureContext(0) as cap:
            if not cap.isOpened():
                logger.error("🔴 Error: Camera not accessible.")
                return None
            ret, frame = cap.read()
            if not ret:
                logger.error("🔴 Failed to capture frame for multi-face detection.")
                return None
            face_locations, face_encodings = self.face_utils.detect_faces(frame)
            return frame, face_encodings, face_locations

    def register_user(self) -> None:
        """
        Registers a new user or updates an existing user's face encoding in the database.
        This method captures a user's face, collects their personal details, and stores
        the information in the database. If the user already exists (based on LIU ID or email),
        it prompts the user to confirm whether to update their face encoding.
        Steps:
        1. Captures the user's face encoding.
        2. Collects user details: first name, last name, LIU ID, and email.
        3. Validates the user input.
        4. Checks if the user already exists in the database:
           - If the user exists, prompts for confirmation to update the face encoding.
           - If the user does not exist, creates a new user record.
        5. Updates or inserts the user's face encoding and other details in the database.
        6. Refreshes the face recognition index.
        Returns:
            None
        Raises:
            psycopg2.Error: If there is a database error during the registration process.
        Logs:
            - Logs success or failure messages for each step of the process.
            - Logs errors if face capture fails or if required inputs are missing.
        Notes:
            - The maximum number of face encodings stored per user is enforced.
            - The face image is saved to a predefined path for the user's profile.
        """
        frame_encoding = self._capture_face("manual")
        if not frame_encoding:
            logger.error("🔴 Face capture failed during registration.")
            return False

        frame, encoding = frame_encoding
        logger.info("🟢 Face captured for registration.")

        # Gather registration details once.
        first_name = input("🚫 Enter your first name: ").strip()
        last_name = input("🚫 Enter your last name: ").strip()
        liu_id = input("🚫 Enter your LIU ID (e.g. abcxy123): ").strip()
        email = input("🚫 Enter your Email: ").strip()

        if not first_name or not last_name:
            logger.error("🔴 First name and last name cannot be empty.")
            return False

        if not self._validate_user_input(liu_id, email):
            return False

        try:
            with self.conn:
                cursor = self.conn.cursor()
                # Query for an existing user with the same LIU ID or email.
                cursor.execute(
                    "SELECT user_id, face_encoding FROM users WHERE liu_id = %s OR email = %s",
                    (liu_id, email),
                )
                existing = cursor.fetchone()

                if existing:
                    logger.info(
                        "🟢 User already exists. Prompting for update confirmation..."
                    )
                    confirm = input("🚫 Update face encoding? (y/n): ").strip().lower()
                    if confirm != "y":
                        logger.info("🔴 Registration aborted by user.")
                        return False
                    else:
                        logger.info("✅ User confirmed update of face encoding.")
                        user_id, existing_encoding_bytea = existing
                        existing_encodings = (
                            pickle.loads(existing_encoding_bytea)
                            if existing_encoding_bytea
                            else []
                        )
                        existing_encodings.append(encoding)
                        # Enforce maximum stored encodings.
                        existing_encodings = existing_encodings[
                            -MAX_ENCODINGS_PER_USER:
                        ]
                        cursor.execute(
                            "UPDATE users SET face_encoding = %s WHERE user_id = %s",
                            (
                                psycopg2.Binary(pickle.dumps(existing_encodings)),
                                user_id,
                            ),
                        )
                        logger.info(
                            "✅ Face encoding updated for %s %s", first_name, last_name
                        )
                        # self._refresh_index()
                        # return
                        user_row_id = user_id

                else:
                    profile_image_path = str(FACE_CAPTURE_PATH / f"{liu_id}.jpg")
                    preferences = "{}"
                    interaction_memory = "[]"
                    face_blob = psycopg2.Binary(pickle.dumps([encoding]))
                    cursor.execute(
                        """INSERT INTO users
                           (first_name, last_name, liu_id, email, face_encoding,
                           preferences, profile_image_path, interaction_memory)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
                        (
                            first_name,
                            last_name,
                            liu_id,
                            email,
                            face_blob,
                            preferences,
                            profile_image_path,
                            interaction_memory,
                        ),
                    )
                    cv2.imwrite(profile_image_path, frame)
                    user_row_id = cursor.lastrowid
                    logger.info(
                        "✅ User %s %s registered successfully with LIU ID: %s",
                        first_name,
                        last_name,
                        liu_id,
                    )
            self._refresh_index()
        except psycopg2.Error as e:
            self.conn.rollback()
            logger.error("🔴 Registration failed: %s", e)
            raise
        # On success:
        self._refresh_index()
        logger.info("✅ User registered successfully.")
        return True

    def identify_user(self) -> None:
        """
        Capture several frames in multi-face mode and combine the results:
          - For each frame, perform identification on each detected face.
          - A dictionary tallies recognized users (using their LIU ID) across frames.
          - If any frame produces an unknown face (i.e. no match), an unknown flag is set.

        After processing:
          - Recognized users are welcomed.
          - If any unknown face is detected, the system explains that the capture from identification
            is not used for registration and calls register_user to re-capture the face.

        Inline Comment: The system uses multiple frames to improve reliability.
        """

        logger.info("🟢 Starting face identification. Please look at the camera..")
        recognized_users = {}  # key: liu_id, value: count across frames
        unknown_found = False

        for i in range(IDENTIFICATION_FRAMES):
            result = self._capture_face_multi()
            if result is None:
                logger.error(
                    "🔴 Frame %d: Failed to capture frame for identification.", i + 1
                )
                continue
            _, face_encodings, _ = result
            if not face_encodings:
                logger.debug("Frame %d: No faces detected.", i + 1)
                continue

            for encoding in face_encodings:
                query_encoding = np.array([encoding], dtype=np.float32)
                if self.faiss_index is not None:
                    distances, indices = self.faiss_index.search(query_encoding, k=1)
                    if distances[0][0] <= FACE_MATCH_THRESHOLD:
                        liu_id = self.user_ids[indices[0][0]]
                        recognized_users[liu_id] = recognized_users.get(liu_id, 0) + 1
                    else:
                        unknown_found = True
                else:
                    unknown_found = True
            time.sleep(TIMEDELAY)  # Slight delay between frames

        # Welcome recognized users (if recognized in any frame)
        if recognized_users:
            for liu_id in recognized_users:
                best_liu = max(recognized_users, key=recognized_users.get)
                user = self.known_encodings.get(best_liu)
                if user:
                    logger.info(
                        f"✅ Welcome back, {user['first_name']} {user['last_name']}!"
                    )
                    return user
        else:
            logger.info("🔴 No known faces detected.")

        # Prompt if any unknown face was found.
        if unknown_found:
            logger.info(
                "🤝 A detected face is unknown, the system will re-capture it during registration."
            )
            response = (
                input("🚫 Would you like to register a user? (y/n): ").strip().lower()
            )
            if response == "y":
                self.register_user()

                # ✅ Re-identify after registration and return the user
                user = self.identify_user()
                if user:
                    logger.info(
                        f"✅ User Authenticated after registration. Welcome {user['first_name']} {user['last_name']}, (liu_id: {user['liu_id']})"
                    )
                    return user
            else:
                logger.info("❌ Registration declined. Authentication aborted.")
                return None
        return None

    def run(self) -> None:
        """
        Main application loop in auto-identification mode.
        The system continuously calls the identify function so that users are identified (and welcomed) immediately.
        After each identification round, the operator can re-run identification or quit.
        """
        logger.info(f"🟢 Auto-identification mode enabled. Press Ctrl+C to exit.")
        try:
            while True:
                self.identify_user()
                choice = (
                    input("🟢 Press Enter to re-run identification or 'q' to quit: ")
                    .strip()
                    .lower()
                )
                if choice == "q":
                    self.close()
                    logger.info("🟢 Exiting...")
                    break
        except KeyboardInterrupt:
            self.close()
            logger.info("Exiting auto-identification mode.")

    def close(self):
        self.cursor.close()
        self.conn.close()


def main() -> None:
    """Entry point for the FaceAuthSystem application."""
    FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
    FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)
    auth_system = FaceAuthSystem()
    auth_system.run()


if __name__ == "__main__":
    main()


# try:
#                         # Call the public method from the separate VoiceAuth module.
#                         self.voice_auth.register_voice_for_user(
#                             first_name, last_name, liu_id
#                         )
#                         logger.info(
#                             "Voice registration completed for user %s %s",
#                             first_name,
#                             last_name,
#                         )
#                     except Exception as e:
#                         logger.error(
#                             "🔴 Voice registration failed after face registration: %s",
#                             e,
#                         )
#                     logger.info(
#                         "User %s %s registered successfully", first_name, last_name
#                     )

# authentication/_face_auth.py

"""
authentication/_face_auth.py
This module provides classes and functions for face authentication using computer vision and deep learning techniques.
It supports user registration and identification based on facial features, with optional integration for voice authentication.
    - Utility class for face detection, drawing bounding boxes, overlaying text, and selecting the best face from multiple detections.
    - Main class for managing face authentication.
    - Handles:
        - Preloading and managing face encodings from a PostgreSQL database.
        - Building and refreshing a FAISS index for fast similarity search.
        - Validating user input and managing user records.
    - Context manager for handling video capture resources using OpenCV.
    - Entry point for the FaceAuthSystem application.
    - Initializes required directories and starts the authentication system.
Constants (imported from config):
    AUTO_CAPTURE_FRAME_COUNT: int
    - Number of consecutive frames required for automatic face capture.
    EMAIL_PATTERN: str
    - Regular expression pattern for validating email addresses.
    FACE_CAPTURE_PATH: Path
    - Path for saving captured face images.
    FACE_MATCH_THRESHOLD: float
    - Threshold for face similarity matching.
    FACIAL_DATA_PATH: Path
    - Path for storing facial data.
    IDENTIFICATION_FRAMES: int
    - Number of frames to process during user identification.
    LIU_ID_PATTERN: str
    - Regular expression pattern for validating LIU IDs.
    MAX_ENCODINGS_PER_USER: int
    - Maximum number of face encodings to store per user.
    TEMP_AUDIO_PATH: Path
    - Path for storing temporary audio files.
    TIMEDELAY: float
    - Delay between frames during identification.
    VOICE_DATA_PATH: Path
    - Path for storing voice data.
Usage:
    Run this module as a script to start the face authentication system.
    The system will prompt for user registration or identification as needed.
Dependencies:
    - OpenCV (cv2)
    - face_recognition
    - faiss
    - numpy
    - psycopg2
    - mini_project.authentication._voice_auth
    - mini_project.config.app_config
    - mini_project.database.connection
"""


# ========== Standard Library Imports ==========
import logging  # For structured logging of authentication events
import pickle  # For serializing face encodings to/from database
import re  # For regex pattern matching (email, LIU ID validation)
import time  # For adding delays between frame captures
from contextlib import contextmanager  # For managing OpenCV video capture resources
from typing import (
    Dict,
    List,
    Optional,
    Tuple,
)  # Type hints for better code documentation

# ========== Third-Party Library Imports ==========
import cv2  # OpenCV for computer vision and camera operations
import face_recognition  # For face detection and encoding generation
import faiss  # Facebook AI Similarity Search for fast face matching
import numpy as np  # Numerical operations for face encoding arrays
import psycopg2  # PostgreSQL database adapter for user data storage

# ========== Local Project Imports ==========
from mini_project.authentication._voice_auth import (
    VoiceAuth,
)  # Voice authentication integration
from mini_project.config.app_config import (  # Configuration constants and paths
    AUTO_CAPTURE_FRAME_COUNT,  # Number of frames needed for automatic capture
    EMAIL_PATTERN,  # Regex pattern for email validation
    FACE_CAPTURE_PATH,  # Directory path for storing face images
    FACE_MATCH_THRESHOLD,  # Similarity threshold for face matching
    FACIAL_DATA_PATH,  # Directory path for facial recognition data
    IDENTIFICATION_FRAMES,  # Number of frames to process during identification
    LIU_ID_PATTERN,  # Regex pattern for LIU ID validation
    MAX_ENCODINGS_PER_USER,  # Maximum face encodings stored per user
    TEMP_AUDIO_PATH,  # Temporary audio file storage path
    TIMEDELAY,  # Delay between identification frames
    VOICE_DATA_PATH,  # Voice data storage path
    setup_logging,  # Logging configuration setup
)
from mini_project.database.connection import (
    get_connection,
)  # Database connection utility

# Initialize logger for face authentication system
logger = logging.getLogger("FaceAuthSystem")


# ========== Video Capture Resource Management ==========


@contextmanager
def VideoCaptureContext(index: int = 0):
    """
    Context manager for safely handling OpenCV video capture resources.

    Ensures proper cleanup of camera resources even if exceptions occur during
    video capture operations. Automatically releases the camera when exiting
    the context, preventing resource leaks.

    Args:
        index (int): Camera index (0 for default camera)

    Yields:
        cv2.VideoCapture: OpenCV video capture object
    """
    cap = cv2.VideoCapture(index)
    try:
        yield cap
    finally:
        # Ensure camera resource is always released
        cap.release()


# ========== Face Detection and Processing Utilities ==========


class FaceUtils:
    """
    Utility class providing static methods for face detection and image processing operations.

    This class encapsulates common computer vision operations used throughout the face
    authentication system, including face detection, bounding box visualization,
    text overlay, and face selection algorithms.
    """

    @staticmethod
    def detect_faces(frame: np.ndarray) -> Tuple[List[tuple], List[np.ndarray]]:
        """
        Detect faces and compute their encodings from a camera frame.

        Converts the frame from BGR to RGB format (required by face_recognition),
        detects face locations, and generates 128-dimensional face encodings
        for each detected face.

        Args:
            frame (np.ndarray): Input image frame in BGR format from OpenCV

        Returns:
            Tuple[List[tuple], List[np.ndarray]]:
                - face_locations: List of (top, right, bottom, left) coordinates
                - face_encodings: List of 128-dimensional encoding vectors
        """
        # Convert BGR (OpenCV) to RGB (face_recognition requirement)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # Detect face locations using HOG-based detector
        face_locations = face_recognition.face_locations(rgb_frame)
        # Generate 128-dimensional encodings for each detected face
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)
        return face_locations, face_encodings

    @staticmethod
    def draw_bounding_boxes(
        frame: np.ndarray, face_locations: List[tuple]
    ) -> np.ndarray:
        """
        Draw green bounding boxes around detected faces for visual feedback.

        Args:
            frame (np.ndarray): Input image frame
            face_locations (List[tuple]): Face coordinates as (top, right, bottom, left)

        Returns:
            np.ndarray: Frame with bounding boxes drawn
        """
        for top, right, bottom, left in face_locations:
            # Draw green rectangle around each detected face
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
        """
        Overlay instructional text on camera frame for user guidance.

        Draws text on the video frame to provide real-time feedback and instructions
        to users during face capture and authentication processes.

        Args:
            frame (np.ndarray): Input image frame to modify
            text (str): Text string to display
            position (Tuple[int, int]): (x, y) pixel coordinates for text placement
            font_scale (float): Font size scaling factor
            color (Tuple[int, int, int]): BGR color tuple for text
            thickness (int): Text line thickness
        """
        # Draw text overlay using OpenCV's built-in font
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
        Select the largest face when multiple faces are detected in a frame.

        When multiple faces are present, this method identifies the face with
        the largest bounding box area, assuming it's the primary subject
        closest to the camera.

        Args:
            face_encodings (List[np.ndarray]): Face encoding vectors (unused but kept for consistency)
            face_locations (List[tuple]): Face coordinates as (top, right, bottom, left)

        Returns:
            int: Index of the face with the largest bounding box area
        """
        # Calculate area for each detected face
        face_sizes = [
            (bottom - top) * (right - left)
            for (top, right, bottom, left) in face_locations
        ]
        # Return index of the largest face
        return int(np.argmax(face_sizes))


# ========== Main Face Authentication System ==========


class FaceAuthSystem:
    """
    Main face authentication system managing user registration and identification.

    This system provides comprehensive face-based authentication capabilities including:
    - Face detection and encoding generation
    - User registration with database storage
    - Fast face matching using FAISS similarity search
    - Multi-frame identification for improved accuracy
    - Integration with voice authentication system

    The system maintains an in-memory cache of face encodings and a FAISS index
    for efficient similarity searches during user identification.
    """

    def __init__(self) -> None:
        """
        Initialize the face authentication system with database connection and indices.

        Sets up database connection, preloads existing user encodings, and builds
        a FAISS index for fast similarity search during identification.
        """
        # Database connection and cursor for user data operations
        self.conn = get_connection()
        self.cursor = self.conn.cursor()

        # Face processing utilities
        self.face_utils = FaceUtils()

        # In-memory cache of user face encodings loaded from database
        self.known_encodings: Dict[str, dict] = self._preload_encodings()

        # FAISS index for fast similarity search during identification
        self.faiss_index: Optional[faiss.IndexFlatL2] = self._build_faiss_index()

    # ========== Database and Index Management ==========

    def _preload_encodings(self) -> Dict[str, dict]:
        """
        Load all user face encodings from the database into memory.

        Retrieves user records from the database and deserializes face encodings
        for fast access during identification. Also loads voice embeddings if available.

        Returns:
            Dict[str, dict]: Dictionary mapping LIU IDs to user data including
                           face encodings, personal info, and voice embeddings
        """
        encodings: Dict[str, dict] = {}
        try:
            # Query all users with their face and voice data
            self.cursor.execute(
                "SELECT user_id, first_name, last_name, liu_id, face_encoding, voice_embedding FROM users"
            )
            users = self.cursor.fetchall()

            # Process each user record
            for user in users:
                # Only process users with face encodings
                if user[4]:
                    encodings[user[3]] = {
                        "user_id": user[0],
                        "first_name": user[1],
                        "last_name": user[2],
                        "liu_id": user[3],
                        # Deserialize face encodings from binary database storage
                        "encodings": pickle.loads(user[4].tobytes()),
                        # Deserialize voice embedding if present
                        "voice_embedding": (
                            pickle.loads(user[5].tobytes())[0] if user[5] else None
                        ),
                    }
        except psycopg2.Error as e:
            logger.error("🔴 Database error during encoding preload: %s", e)
        return encodings

    def _build_faiss_index(self) -> Optional[faiss.IndexFlatL2]:
        """
        Build a FAISS index for fast face encoding similarity search.

        Creates a flat L2 (Euclidean distance) index containing all face encodings
        from registered users. This enables fast nearest-neighbor search during
        face identification, significantly improving performance compared to
        brute-force comparison.

        Returns:
            Optional[faiss.IndexFlatL2]: FAISS index for similarity search,
                                       None if no encodings are available
        """
        if not self.known_encodings:
            logger.debug("No known encodings to build FAISS index.")
            return None

        all_encodings: List[np.ndarray] = []
        self.user_ids: List[str] = []  # Maps FAISS index positions to LIU IDs

        # Flatten all encodings from all users into a single list
        for liu_id, user in self.known_encodings.items():
            for encoding in user["encodings"]:
                all_encodings.append(encoding)
                self.user_ids.append(
                    liu_id
                )  # Track which user each encoding belongs to

        if not all_encodings:
            logger.debug("No encodings found after processing known_encodings.")
            return None

        # Convert to numpy array with float32 precision (FAISS requirement)
        all_encodings_np = np.array(all_encodings, dtype=np.float32)
        # Create flat L2 index with dimensionality matching face encodings (128)
        index = faiss.IndexFlatL2(all_encodings_np.shape[1])
        # Add all encodings to the index for similarity search
        index.add(all_encodings_np)
        logger.debug("FAISS index built with %d encodings.", all_encodings_np.shape[0])
        return index

    def _refresh_index(self) -> None:
        """
        Refresh the in-memory face encodings cache and rebuild the FAISS index.

        Called after user registration or updates to ensure the system
        has the latest user data available for identification. This is
        essential for recognizing newly registered users.
        """
        # Reload encodings from database
        self.known_encodings = self._preload_encodings()
        # Rebuild FAISS index with updated encodings
        self.faiss_index = self._build_faiss_index()
        logger.info("✅ FAISS index and known encodings refreshed.")

    # ========== Input Validation ==========

    def _validate_user_input(self, liu_id: str, email: str) -> bool:
        """
        Validate user input formats for LIU ID and email address.

        Ensures that user-provided LIU ID follows the expected pattern
        and email address is properly formatted before database operations.

        Args:
            liu_id (str): University ID to validate
            email (str): Email address to validate

        Returns:
            bool: True if both inputs are valid, False otherwise
        """
        # Validate LIU ID format (e.g., "abc123")
        if not re.match(LIU_ID_PATTERN, liu_id):
            logger.error("🔴 Invalid LIU ID format. Expected format: abc123")
            return False
        # Validate email format
        if not re.match(EMAIL_PATTERN, email):
            logger.error("🔴 Invalid email format")
            return False
        return True

    # ========== Frame Processing and Camera Operations ==========

    def _process_frame(
        self, cap: cv2.VideoCapture, instruction: str
    ) -> Tuple[Optional[np.ndarray], List[tuple], List[np.ndarray]]:
        """
        Capture and process a single frame from the camera with face detection.

        Reads a frame from the camera, detects faces, draws bounding boxes,
        and overlays instructional text for user guidance during capture or
        identification processes.

        Args:
            cap (cv2.VideoCapture): OpenCV video capture object
            instruction (str): Text instruction to display on the frame

        Returns:
            Tuple containing:
                - frame (Optional[np.ndarray]): Processed frame with annotations,
                  None if frame capture fails
                - face_locations (List[tuple]): Detected face coordinates
                - face_encodings (List[np.ndarray]): Face encoding vectors
        """
        # Capture frame from camera
        ret, frame = cap.read()
        if not ret:
            logger.debug("No frame retrieved from camera.")
            return None, [], []

        # Detect faces and generate encodings
        face_locations, face_encodings = self.face_utils.detect_faces(frame)
        # Draw bounding boxes around detected faces
        frame = self.face_utils.draw_bounding_boxes(frame, face_locations)
        # Overlay instruction text for user guidance
        self.face_utils.draw_text(frame, instruction)
        return frame, face_locations, face_encodings

    # ========== Face Capture Methods ==========

    def _capture_face_auto(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Capture a face using automatic mode with stability checking.

        Automatically captures a face when a single face is detected consistently
        across multiple consecutive frames. This ensures stable detection and
        reduces capture of blurry or partial faces.

        Returns:
            Optional[Tuple[np.ndarray, np.ndarray]]: Tuple of (captured_frame, face_encoding)
                                                   if successful, None if capture fails
        """
        with VideoCaptureContext(0) as cap:
            if not cap.isOpened():
                logger.error("🔴 Error: Camera not accessible.")
                return None
            # Initialize tracking variables for stable detection
            consecutive_detections = (
                0  # Count of consecutive frames with exactly one face
            )
            captured_frame: Optional[np.ndarray] = None
            captured_encoding: Optional[np.ndarray] = None

            while True:
                # Process current frame and detect faces
                frame, _, face_encodings = self._process_frame(
                    cap, "Face detected, capturing..."
                )
                if frame is None:
                    logger.debug("Frame processing failed; exiting auto capture loop.")
                    break

                # Check for stable single face detection
                if len(face_encodings) == 1:
                    consecutive_detections += 1
                    # Display progress counter to user
                    self.face_utils.draw_text(
                        frame,
                        f"Detected: {consecutive_detections}/{AUTO_CAPTURE_FRAME_COUNT}",
                        position=(10, 60),
                    )
                    # Capture when stability threshold is reached
                    if consecutive_detections >= AUTO_CAPTURE_FRAME_COUNT:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logger.debug("Auto capture threshold reached; capturing face.")
                        break
                else:
                    # Reset counter if unstable detection (no face or multiple faces)
                    consecutive_detections = 0

                # Display frame and check for user input
                cv2.imshow("Face Capture - Auto", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logger.info("Auto capture aborted by user.")
                    break

            # Clean up display window
            cv2.destroyAllWindows()
            if captured_frame is not None and captured_encoding is not None:
                return captured_frame, captured_encoding
            return None

    def _capture_face_manual(self) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Capture a face using manual mode with user control.

        Allows the user to manually trigger face capture by pressing 's' when
        satisfied with the current frame. Provides more control but requires
        user interaction. Useful when automatic capture is not reliable.

        Returns:
            Optional[Tuple[np.ndarray, np.ndarray]]: Tuple of (captured_frame, face_encoding)
                                                   if successful, None if capture fails
        """
        with VideoCaptureContext(0) as cap:
            if not cap.isOpened():
                logger.error("🔴 Error: Camera not accessible.")
                return None

            captured_frame: Optional[np.ndarray] = None
            captured_encoding: Optional[np.ndarray] = None

            while True:
                # Process frame and provide user instructions
                frame, _, face_encodings = self._process_frame(
                    cap, "Press 's' to save, 'q' to quit"
                )
                if frame is None:
                    logger.debug(
                        "Frame processing failed; exiting manual capture loop."
                    )
                    break

                # Provide visual feedback when face is detected
                if len(face_encodings) >= 1:
                    self.face_utils.draw_text(
                        frame, "Face detected!", position=(10, 60)
                    )

                # Display frame and handle user input
                cv2.imshow("Face Capture - Manual", frame)
                key = cv2.waitKey(1) & 0xFF
                if key == ord("q"):
                    logger.info("Manual capture aborted by user.")
                    break
                if key == ord("s"):
                    # Only capture if exactly one face is detected
                    if len(face_encodings) == 1:
                        captured_frame = frame
                        captured_encoding = face_encodings[0]
                        logger.debug("Face captured in manual mode.")
                        break
                    else:
                        logger.warning(
                            "No face or multiple faces detected; cannot capture."
                        )

            # Clean up display window
            cv2.destroyAllWindows()
            if captured_frame is not None and captured_encoding is not None:
                return captured_frame, captured_encoding
            return None

    def _capture_face(
        self, capture_mode: str = "auto"
    ) -> Optional[Tuple[np.ndarray, np.ndarray]]:
        """
        Capture a face using the specified mode.

        Args:
            capture_mode (str): Either "auto" for automatic capture or "manual" for user-controlled

        Returns:
            Optional[Tuple[np.ndarray, np.ndarray]]: Captured frame and face encoding
        """
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

    # ========== User Registration and Management ==========

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
        return {
            "liu_id": liu_id,
            "first_name": first_name,
            "last_name": last_name,
            "voice_embedding": None,  # or fetch from DB if needed
        }

    # ========== User Identification and Authentication ==========

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

    # ========== Image-Based Registration and Identification ==========

    def register_user_from_image(
        self, image_path, first_name, last_name, liu_id, email
    ):
        """
        Registers a user by extracting face encoding from the image and saving user info.
        Returns True if successful, False otherwise.
        """
        # Load and encode face
        image = cv2.imread(str(image_path))
        if image is None:
            logger.error("Image not found or unreadable.")
            return False
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        encodings = face_recognition.face_encodings(rgb_image)
        if not encodings:
            logger.error("No face detected in the image.")
            return False
        face_encoding = encodings[0]

        # Validate user input
        if not self._validate_user_input(liu_id, email):
            logger.error("Invalid LIU ID or email.")
            return False

        try:
            with self.conn:
                cursor = self.conn.cursor()
                # Check if user exists
                cursor.execute(
                    "SELECT user_id, face_encoding FROM users WHERE liu_id = %s OR email = %s",
                    (liu_id, email),
                )
                existing = cursor.fetchone()

                if existing:
                    user_id, existing_encoding_bytea = existing
                    existing_encodings = (
                        pickle.loads(existing_encoding_bytea)
                        if existing_encoding_bytea
                        else []
                    )
                    existing_encodings.append(face_encoding)
                    # Enforce maximum stored encodings
                    existing_encodings = existing_encodings[-MAX_ENCODINGS_PER_USER:]
                    cursor.execute(
                        "UPDATE users SET face_encoding = %s WHERE user_id = %s",
                        (psycopg2.Binary(pickle.dumps(existing_encodings)), user_id),
                    )
                    logger.info(
                        "✅ Face encoding updated for %s %s", first_name, last_name
                    )
                else:
                    profile_image_path = str(FACE_CAPTURE_PATH / f"{liu_id}.jpg")
                    preferences = "{}"
                    interaction_memory = "[]"
                    face_blob = psycopg2.Binary(pickle.dumps([face_encoding]))
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
                    cv2.imwrite(profile_image_path, image)
                    logger.info(
                        "✅ User %s %s registered successfully with LIU ID: %s",
                        first_name,
                        last_name,
                        liu_id,
                    )
            self._refresh_index()
            return True
        except Exception as e:
            self.conn.rollback()
            logger.error("🔴 Registration failed: %s", e)
            return False

    def identify_user_from_image(self, image_path: str):
        """
        Identify a user from a face image file.
        Returns user dict if matched, else None.
        """
        # Load image
        image = cv2.imread(image_path)
        if image is None:
            return None
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        face_encodings = face_recognition.face_encodings(rgb_image)
        if not face_encodings:
            return None
        query_encoding = np.array([face_encodings[0]], dtype=np.float32)
        if self.faiss_index is not None:
            distances, indices = self.faiss_index.search(query_encoding, k=1)
            if distances[0][0] <= FACE_MATCH_THRESHOLD:
                liu_id = self.user_ids[indices[0][0]]
                return self.known_encodings.get(liu_id)
        return None

    # ========== Main Application Loop and Resource Management ==========

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
        """Clean up database resources when shutting down the system."""
        self.cursor.close()
        self.conn.close()


# ========== Application Entry Point ==========


def main() -> None:
    """
    Entry point for the face authentication system application.

    Initializes required directories, creates the authentication system instance,
    and starts the main application loop for user identification and registration.
    """
    # Ensure required directories exist
    FACIAL_DATA_PATH.mkdir(parents=True, exist_ok=True)
    FACE_CAPTURE_PATH.mkdir(parents=True, exist_ok=True)

    # Initialize and run the face authentication system
    auth_system = FaceAuthSystem()
    auth_system.run()


if __name__ == "__main__":
    main()

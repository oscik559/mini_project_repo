import logging
import sqlite3
import threading
import time
import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

import cv2
import mediapipe as mp

# Configure logging for better debug and runtime insights
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)


class GestureDetector:
    def __init__(
        self,
        db_path: str = "commands.db",
        min_detection_confidence: float = 0.7,
        min_tracking_confidence: float = 0.5,
        max_num_hands: int = 2,
        frame_skip: int = 2,
    ):
        # MediaPipe setup with configurable parameters
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=max_num_hands,
            min_detection_confidence=min_detection_confidence,
            min_tracking_confidence=min_tracking_confidence,
        )
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles

        # Database setup with extended schema
        self.conn = sqlite3.connect(db_path, check_same_thread=False)
        self._init_db()

        # Session management and frame skipping
        self.session_id = str(uuid.uuid4())
        self.frame_skip = frame_skip
        self.frame_counter = 0

        # Gesture mapping dictionary (allows swappable classification functions)
        self.gesture_map = {
            "thumbs_up": {"func": self._is_thumbs_up, "text": "Approval"},
            "open_hand": {"func": self._is_open_hand, "text": "Stop"},
            "pointing": {"func": self._is_pointing, "text": "Select Object"},
            "closed_fist": {"func": self._is_closed_fist, "text": "Grab"},
            "victory": {"func": self._is_victory, "text": "Confirm"},
            # Future: extend with additional gestures, e.g. "peace_sign": {"func": self._is_peace_sign, "text": "Peace"}
        }

        # For debouncing repeated gestures
        self.last_gesture: Optional[str] = None
        self.last_log_time: float = 0
        self.min_log_interval: float = 2.0  # seconds

        # Store last detection result for consistent display (if detected in the current frame)
        self.last_detection: Optional[List[Dict[str, Any]]] = None

    def _init_db(self):
        """Initialize database table for gestures with extended schema."""
        self.conn.execute(
            """CREATE TABLE IF NOT EXISTS commands
                             (id INTEGER PRIMARY KEY AUTOINCREMENT,
                              session_id TEXT,
                              timestamp DATETIME,
                              gesture_type TEXT,
                              gesture_text TEXT,
                              natural_description TEXT,
                              confidence REAL,
                              hand_label TEXT)"""
        )
        self.conn.commit()
        logging.info("Database initialized.")

    def _log_gesture(
        self,
        gesture_type: str,
        gesture_text: str,
        natural_description: str,
        confidence: float,
        hand_label: str,
    ):
        """Store gesture in the database with session id and natural language description."""
        timestamp = datetime.now().isoformat()
        try:
            with self.conn:
                self.conn.execute(
                    """INSERT INTO commands
                                     (session_id, timestamp, gesture_type, gesture_text, natural_description, confidence, hand_label)
                                     VALUES (?, ?, ?, ?, ?, ?, ?)""",
                    (
                        self.session_id,
                        timestamp,
                        gesture_type,
                        gesture_text,
                        natural_description,
                        confidence,
                        hand_label,
                    ),
                )
            logging.info(
                f"Logged gesture: {gesture_text} [{hand_label}] with confidence {confidence:.2f} and description: {natural_description}"
            )
        except sqlite3.Error as e:
            logging.error(f"Database error: {e}")

    def _get_landmark_coords(
        self, landmarks, landmark_id: int
    ) -> Tuple[float, float, float]:
        """Get normalized coordinates (x, y, z) for a specific landmark."""
        landmark = landmarks.landmark[landmark_id]
        return (landmark.x, landmark.y, landmark.z)

    # Basic rule-based gesture functions
    def _is_thumbs_up(self, landmarks) -> bool:
        thumb_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_TIP
        )
        index_pip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_PIP
        )
        return thumb_tip[1] < index_pip[1]

    def _is_open_hand(self, landmarks) -> bool:
        fingertips = [
            self._get_landmark_coords(landmarks, tip)[1]
            for tip in [
                self.mp_hands.HandLandmark.THUMB_TIP,
                self.mp_hands.HandLandmark.INDEX_FINGER_TIP,
                self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
                self.mp_hands.HandLandmark.RING_FINGER_TIP,
                self.mp_hands.HandLandmark.PINKY_TIP,
            ]
        ]
        wrist_y = landmarks.landmark[self.mp_hands.HandLandmark.WRIST].y
        return all(y < wrist_y for y in fingertips)

    def _is_pointing(self, landmarks) -> bool:
        index_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_TIP
        )
        middle_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP
        )
        return index_tip[1] < middle_tip[1]

    def _is_closed_fist(self, landmarks) -> bool:
        fingertips = [
            self._get_landmark_coords(landmarks, tip)[1]
            for tip in [
                self.mp_hands.HandLandmark.THUMB_TIP,
                self.mp_hands.HandLandmark.INDEX_FINGER_TIP,
                self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
            ]
        ]
        mcp_joints = [
            self._get_landmark_coords(landmarks, joint)[1]
            for joint in [
                self.mp_hands.HandLandmark.THUMB_MCP,
                self.mp_hands.HandLandmark.INDEX_FINGER_MCP,
                self.mp_hands.HandLandmark.MIDDLE_FINGER_MCP,
            ]
        ]
        return all(tip > mcp for tip, mcp in zip(fingertips, mcp_joints))

    def _is_victory(self, landmarks) -> bool:
        index_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_TIP
        )
        middle_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP
        )
        ring_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.RING_FINGER_TIP
        )
        wrist_y = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.WRIST
        )[1]
        return (
            index_tip[1] < ring_tip[1]
            and middle_tip[1] < ring_tip[1]
            and ring_tip[1] > wrist_y
        )

    # Additional feature extraction functions
    def _analyze_thumb(self, landmarks) -> str:
        """Analyze thumb position."""
        thumb_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_TIP
        )
        thumb_ip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_IP
        )
        return "up" if thumb_tip[1] < thumb_ip[1] else "down"

    def _count_open_fingers(self, landmarks) -> int:
        """Count number of open fingers (excluding thumb)."""
        count = 0
        if (
            landmarks.landmark[self.mp_hands.HandLandmark.INDEX_FINGER_TIP].y
            < landmarks.landmark[self.mp_hands.HandLandmark.INDEX_FINGER_MCP].y
        ):
            count += 1
        if (
            landmarks.landmark[self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP].y
            < landmarks.landmark[self.mp_hands.HandLandmark.MIDDLE_FINGER_MCP].y
        ):
            count += 1
        if (
            landmarks.landmark[self.mp_hands.HandLandmark.RING_FINGER_TIP].y
            < landmarks.landmark[self.mp_hands.HandLandmark.RING_FINGER_MCP].y
        ):
            count += 1
        if (
            landmarks.landmark[self.mp_hands.HandLandmark.PINKY_TIP].y
            < landmarks.landmark[self.mp_hands.HandLandmark.PINKY_MCP].y
        ):
            count += 1
        return count

    def convert_features_to_description(self, gesture_type: str, hand_landmarks) -> str:
        """
        Convert gesture features into a rich natural language description.
        Uses additional features such as thumb state and count of open fingers.
        """
        thumb_state = self._analyze_thumb(hand_landmarks)
        open_fingers = self._count_open_fingers(hand_landmarks)
        if gesture_type == "thumbs_up":
            base_desc = "The thumb is raised above the index finger, indicating a thumbs-up or approval gesture."
        elif gesture_type == "open_hand":
            base_desc = "All fingers are extended, showing an open hand posture which may signal a stop command."
        elif gesture_type == "pointing":
            base_desc = "The index finger is extended while the other fingers remain curled, suggesting the user is pointing."
        elif gesture_type == "closed_fist":
            base_desc = "The hand is clenched into a fist, a posture often associated with grabbing or assertiveness."
        elif gesture_type == "victory":
            base_desc = "The hand forms a V-shape with the index and middle fingers extended, commonly used to signal victory or confirmation."
        else:
            base_desc = "A neutral gesture with no distinct features."
        return f"{base_desc} Additionally, the thumb is {thumb_state} and {open_fingers} fingers are open."

    def detect_gesture(self, frame) -> Optional[List[Dict[str, Any]]]:
        """
        Process a frame and detect gestures.
        Returns a list of dicts with keys:
        'gesture', 'gesture_text', 'confidence', 'hand_label', 'description', and 'landmarks'
        """
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(rgb_frame)
        if not results.multi_hand_landmarks or not results.multi_handedness:
            return None

        detections = []
        for hand_landmarks, handedness_info in zip(
            results.multi_hand_landmarks, results.multi_handedness
        ):
            hand_label = handedness_info.classification[0].label
            hand_confidence = handedness_info.classification[0].score
            for gesture, config in self.gesture_map.items():
                if config["func"](hand_landmarks):
                    description = self.convert_features_to_description(
                        gesture, hand_landmarks
                    )
                    detections.append(
                        {
                            "gesture": gesture,
                            "gesture_text": config["text"],
                            "confidence": hand_confidence,
                            "hand_label": hand_label,
                            "description": description,
                            "landmarks": hand_landmarks,
                        }
                    )
                    break
        return detections

    def _process_frame(self, frame):
        """Process a single frame: flip, resize, update detection and overlay gesture info."""
        # Always flip and resize the frame for consistent display
        frame = cv2.flip(frame, 1)
        frame = cv2.resize(frame, (640, 480))
        self.frame_counter += 1

        # Update detection on every frame_skip-th frame
        if self.frame_counter % self.frame_skip == 0:
            detection = self.detect_gesture(frame)
            if detection is not None:
                self.last_detection = detection
            else:
                # Clear previous detection if no hand is detected
                self.last_detection = None
            current_time = time.time()
            if self.last_detection:
                for idx, d in enumerate(self.last_detection):
                    if d["gesture"] == self.last_gesture and (
                        current_time - self.last_log_time < self.min_log_interval
                    ):
                        continue
                    self._log_gesture(
                        d["gesture"],
                        d["gesture_text"],
                        d["description"],
                        d["confidence"],
                        d["hand_label"],
                    )
                    self.last_gesture = d["gesture"]
                    self.last_log_time = current_time

        # Overlay the detection if available
        if self.last_detection:
            for idx, d in enumerate(self.last_detection):
                cv2.putText(
                    frame,
                    f"{d['gesture_text']} [{d['hand_label']}]",
                    (10, 30 + idx * 60),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 255, 0),
                    2,
                )
                cv2.putText(
                    frame,
                    d["description"],
                    (10, 70 + idx * 60),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (255, 255, 0),
                    2,
                )
                # Experiment with different overlay colors for specific gestures
                if d["gesture"] == "thumbs_up":
                    cv2.putText(
                        frame,
                        "Thumb Highlight",
                        (10, 110 + idx * 60),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.6,
                        (0, 0, 255),
                        2,
                    )

        # Draw landmarks on current frame if detections exist
        if self.last_detection:
            for d in self.last_detection:
                self.mp_drawing.draw_landmarks(
                    frame,
                    d["landmarks"],
                    self.mp_hands.HAND_CONNECTIONS,
                    self.mp_drawing_styles.get_default_hand_landmarks_style(),
                    self.mp_drawing_styles.get_default_hand_connections_style(),
                )
        else:
            # Otherwise, process the frame to draw landmarks (if any)
            rgb_for_drawing = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = self.hands.process(rgb_for_drawing)
            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    self.mp_drawing.draw_landmarks(
                        frame,
                        hand_landmarks,
                        self.mp_hands.HAND_CONNECTIONS,
                        self.mp_drawing_styles.get_default_hand_landmarks_style(),
                        self.mp_drawing_styles.get_default_hand_connections_style(),
                    )
        return frame

    def process_video_stream(self):
        """Main processing loop using threading for asynchronous processing."""
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            logging.error("Error: Could not open video stream.")
            return

        def video_loop():
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    logging.error("Failed to capture frame from camera.")
                    break

                processed_frame = self._process_frame(frame)
                cv2.imshow("Gesture Detection", processed_frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break

            cap.release()
            cv2.destroyAllWindows()
            self.conn.close()
            logging.info("Video stream ended and database connection closed.")

        video_thread = threading.Thread(target=video_loop)
        video_thread.start()
        video_thread.join()


if __name__ == "__main__":
    detector = GestureDetector()
    detector.process_video_stream()

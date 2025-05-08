# modalities/gesture_processor.py


import logging
import threading
import time
import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

import cv2
import mediapipe as mp
from psycopg2 import Error as Psycopg2Error

from config.app_config import *
from mini_project.database.connection import get_connection

setup_logging(level=logging.INFO)
logger = logging.getLogger("GestureProcessor")


class GestureDetector:
    def __init__(
        self,
        min_detection_confidence: float = MIN_DETECTION_CONFIDENCE,
        min_tracking_confidence: float = MIN_TRACKING_CONFIDENCE,
        max_num_hands: int = MAX_NUM_HANDS,
        frame_skip: int = FRAME_SKIP,
        session_id: Optional[str] = None,
    ):
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=max_num_hands,
            min_detection_confidence=min_detection_confidence,
            min_tracking_confidence=min_tracking_confidence,
        )
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles

        self.conn = get_connection()

        self._init_db()
        self.cursor = self.conn.cursor()

        self.session_id = session_id or str(uuid.uuid4())
        self.frame_skip = frame_skip
        self.frame_counter = 0

        loaded_gestures = self.load_gesture_definitions()
        if loaded_gestures:
            self.gesture_map = loaded_gestures


        self.last_gesture: Optional[str] = None
        self.last_log_time: float = 0
        self.min_log_interval: float = 2.0
        self.last_detection: Optional[List[Dict[str, Any]]] = None

    def _init_db(self):
        with self.conn.cursor() as cursor:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS gesture_instructions (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT NOT NULL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    gesture_text TEXT NOT NULL,
                    natural_description TEXT,
                    confidence REAL,
                    hand_label TEXT,
                    processed BOOLEAN DEFAULT FALSE
                )
                """
            )
        self.conn.commit()
        logger.info("Gesture table (PostgreSQL) initialized.")



    def _log_gesture(
        self,
        gesture_type: str,
        gesture_text: str,
        natural_description: str,
        confidence: float,
        hand_label: str,
    ):
        timestamp = datetime.now()
        try:
            with self.conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO gesture_instructions
                    (session_id, timestamp, gesture_text, natural_description, confidence, hand_label)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        self.session_id,
                        timestamp,
                        gesture_text,
                        natural_description,
                        confidence,
                        hand_label,
                    ),
                )
            self.conn.commit()

            logger.info(
                f"Gesture: [{gesture_text}], Hand: [{hand_label}], Confidence: [{confidence:.2f}], Description: [{natural_description}]"
            )
        except Psycopg2Error as e:
            logger.error(f"[DB:PostgreSQL] Gesture logging failed: {e}", exc_info=True)
            self.conn.rollback()

    def _get_landmark_coords(
        self, landmarks, landmark_id: int
    ) -> Tuple[float, float, float]:
        landmark = landmarks.landmark[landmark_id]
        return (landmark.x, landmark.y, landmark.z)

    def _euclidean_distance(
        self, a: Tuple[float, float, float], b: Tuple[float, float, float]
    ) -> float:
        return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2) ** 0.5

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

    def _is_ok_sign(self, landmarks) -> bool:
        thumb_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_TIP
        )
        index_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_TIP
        )
        # Define a threshold for the OK sign; adjust if needed.
        threshold = 0.05
        distance = self._euclidean_distance(thumb_tip, index_tip)
        return distance < threshold

    def _analyze_thumb(self, landmarks) -> str:
        thumb_tip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_TIP
        )
        thumb_ip = self._get_landmark_coords(
            landmarks, self.mp_hands.HandLandmark.THUMB_IP
        )
        return "up" if thumb_tip[1] < thumb_ip[1] else "down"

    def _count_open_fingers(self, landmarks) -> int:
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
        elif gesture_type == "ok_sign":
            base_desc = "The thumb and index finger are touching to form a circle, commonly known as the OK sign."
        else:
            base_desc = "A neutral gesture with no distinct features."
        return f"{base_desc} Additionally, the thumb is {thumb_state} and {open_fingers} fingers are open."

    def detect_gesture(self, frame) -> Optional[List[Dict[str, Any]]]:
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
                            "modality": "gesture",
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
        """
        Process a single frame: flip, resize, update detection, overlay gesture info, and draw landmarks.
        """
        # Flip and resize for a consistent display.
        frame = cv2.flip(frame, 1)
        frame = cv2.resize(frame, (640, 480))
        self.frame_counter += 1

        # Update detection on every frame_skip-th frame.
        if self.frame_counter % self.frame_skip == 0:
            detection = self.detect_gesture(frame)
            self.last_detection = detection if detection is not None else None
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

        # Overlay detection info if available.
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

        # Draw landmarks on the frame.
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

    def load_gesture_definitions(self) -> Dict[str, Dict[str, Any]]:
        try:
            with self.conn.cursor() as cursor:
                query = "SELECT gesture_type, gesture_text, natural_description, config FROM gesture_library"
                cursor.execute(query)
                definitions = {}
                for row in cursor.fetchall():
                    gesture_type, gesture_text, natural_description, config = row
                    definitions[gesture_type] = {
                        "text": gesture_text,
                        "description": natural_description,
                        # You can parse the JSON config if needed:
                        "config": config,
                        # Map to your detection function via gesture_map_functions:
                        "func": self.gesture_map_functions().get(gesture_type),
                    }
            return definitions
        except Psycopg2Error as e:
            logger.error(f"Error loading gesture definitions: {e}")
            return {}

    def gesture_map_functions(self) -> Dict[str, Any]:
        """Returns a mapping of gesture types to detection functions."""
        return {
            "thumbs_up": self._is_thumbs_up,
            "open_hand": self._is_open_hand,
            "pointing": self._is_pointing,
            "closed_fist": self._is_closed_fist,
            "victory": self._is_victory,
            "ok_sign": self._is_ok_sign,
        }

    def process_video_stream(self, termination_event: Optional[threading.Event] = None):
        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            logger.error("Error: Could not open video stream.")
            return

        def video_loop():
            while cap.isOpened() and not (
                termination_event and termination_event.is_set()
            ):
                ret, frame = cap.read()
                if not ret:
                    logger.error("Failed to capture frame from camera.")
                    break
                processed_frame = self._process_frame(frame)
                cv2.imshow("Gesture Detection", processed_frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break
            cap.release()
            cv2.destroyAllWindows()
            self.conn.close()
            logger.info("Video stream ended and database connection closed.")

        video_thread = threading.Thread(target=video_loop)
        video_thread.start()
        video_thread.join()


if __name__ == "__main__":
    gd = GestureDetector()
    gd.process_video_stream()

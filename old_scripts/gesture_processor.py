
import cv2
import mediapipe as mp
import sqlite3
import time
import logging
import threading
from datetime import datetime
from typing import Tuple, Optional, List

# Configure logging for better debug and runtime insights
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

class GestureDetector:
    def __init__(self, db_path: str = 'commands.db', min_detection_confidence: float = 0.7,
                 min_tracking_confidence: float = 0.5, max_num_hands: int = 2):
        # MediaPipe setup with configurable parameters
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=max_num_hands,
            min_detection_confidence=min_detection_confidence,
            min_tracking_confidence=min_tracking_confidence
        )
        self.mp_drawing = mp.solutions.drawing_utils

        # Database setup (using check_same_thread=False for multi-threaded access)
        self.conn = sqlite3.connect(db_path, check_same_thread=False)
        self._init_db()

        # Gesture mapping dictionary (allows swappable classification functions)
        self.gesture_map = {
            "thumbs_up": {"func": self._is_thumbs_up, "text": "Approval"},
            "open_hand": {"func": self._is_open_hand, "text": "Stop"},
            "pointing": {"func": self._is_pointing, "text": "Select Object"},
            "closed_fist": {"func": self._is_closed_fist, "text": "Grab"},
            "victory": {"func": self._is_victory, "text": "Confirm"}
        }

        # For debouncing repeated gestures
        self.last_gesture = None
        self.last_log_time = 0
        self.min_log_interval = 2.0  # seconds

    def _init_db(self):
        """Initialize database table for gestures."""
        self.conn.execute('''CREATE TABLE IF NOT EXISTS commands
                             (id INTEGER PRIMARY KEY AUTOINCREMENT,
                              timestamp DATETIME,
                              gesture_type TEXT,
                              gesture_text TEXT,
                              natural_description TEXT,
                              confidence REAL)''')
        self.conn.commit()
        logging.info("Database initialized.")

    def _log_gesture(self, gesture_type: str, gesture_text: str, natural_description: str, confidence: float):
        """Store gesture in the database with context and natural language description."""
        timestamp = datetime.now().isoformat()
        try:
            with self.conn:
                self.conn.execute('''INSERT INTO commands
                                     (timestamp, gesture_type, gesture_text, natural_description, confidence)
                                     VALUES (?, ?, ?, ?, ?)''',
                                  (timestamp, gesture_type, gesture_text, natural_description, confidence))
            logging.info(f"Logged gesture: {gesture_text} with description: '{natural_description}' and confidence {confidence:.2f}")
        except sqlite3.Error as e:
            logging.error(f"Database error: {e}")

    def _get_landmark_coords(self, landmarks, landmark_id: int) -> Tuple[float, float, float]:
        """Get normalized coordinates (x, y, z) for a specific landmark."""
        landmark = landmarks.landmark[landmark_id]
        return (landmark.x, landmark.y, landmark.z)

    # Rule-based gesture recognition functions (easily swappable with an ML model)
    def _is_thumbs_up(self, landmarks) -> bool:
        thumb_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.THUMB_TIP)
        index_pip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_PIP)
        return thumb_tip[1] < index_pip[1]

    def _is_open_hand(self, landmarks) -> bool:
        fingertips = [self._get_landmark_coords(landmarks, tip)[1]
                      for tip in [self.mp_hands.HandLandmark.THUMB_TIP,
                                  self.mp_hands.HandLandmark.INDEX_FINGER_TIP,
                                  self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
                                  self.mp_hands.HandLandmark.RING_FINGER_TIP,
                                  self.mp_hands.HandLandmark.PINKY_TIP]]
        wrist_y = landmarks.landmark[self.mp_hands.HandLandmark.WRIST].y
        return all(y < wrist_y for y in fingertips)

    def _is_pointing(self, landmarks) -> bool:
        index_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_TIP)
        middle_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP)
        return index_tip[1] < middle_tip[1]

    def _is_closed_fist(self, landmarks) -> bool:
        fingertips = [self._get_landmark_coords(landmarks, tip)[1]
                      for tip in [self.mp_hands.HandLandmark.THUMB_TIP,
                                  self.mp_hands.HandLandmark.INDEX_FINGER_TIP,
                                  self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP]]
        mcp_joints = [self._get_landmark_coords(landmarks, joint)[1]
                      for joint in [self.mp_hands.HandLandmark.THUMB_MCP,
                                    self.mp_hands.HandLandmark.INDEX_FINGER_MCP,
                                    self.mp_hands.HandLandmark.MIDDLE_FINGER_MCP]]
        return all(tip > mcp for tip, mcp in zip(fingertips, mcp_joints))

    def _is_victory(self, landmarks) -> bool:
        index_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.INDEX_FINGER_TIP)
        middle_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP)
        ring_tip = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.RING_FINGER_TIP)
        wrist_y = self._get_landmark_coords(landmarks, self.mp_hands.HandLandmark.WRIST)[1]
        return (index_tip[1] < ring_tip[1] and middle_tip[1] < ring_tip[1] and ring_tip[1] > wrist_y)

    def convert_features_to_description(self, gesture_type: str, landmarks) -> str:
        """
        Convert gesture features into a rich natural language description.
        This rule-based function can later be replaced with an LLM API call.
        """
        if gesture_type == "thumbs_up":
            return "The thumb is raised above the index finger, indicating a thumbs-up or approval gesture."
        elif gesture_type == "open_hand":
            return "All fingers are extended and spread apart, showing an open hand posture which may signal a stop command or neutrality."
        elif gesture_type == "pointing":
            return "The index finger is extended while the other fingers remain curled, suggesting the user is pointing towards an object."
        elif gesture_type == "closed_fist":
            return "The hand is clenched into a fist, a posture often associated with grabbing or asserting force."
        elif gesture_type == "victory":
            return "The hand forms a V-shape with the index and middle fingers extended, commonly used to signal victory or confirmation."
        else:
            return "A neutral gesture with no distinct features."

    def detect_gesture(self, frame) -> Optional[List[Tuple[str, str, float, str, str]]]:
        """
        Process a frame and detect gestures.
        Returns a list of tuples:
        (gesture_type, gesture_text, confidence, hand_label, natural_language_description)
        """
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.hands.process(rgb_frame)

        if not results.multi_hand_landmarks or not results.multi_handedness:
            return None

        detected_gestures = []
        # Zip together landmarks and handedness info for each detected hand
        for hand_landmarks, handedness_info in zip(results.multi_hand_landmarks, results.multi_handedness):
            hand_label = handedness_info.classification[0].label  # "Left" or "Right"
            hand_confidence = handedness_info.classification[0].score
            for gesture, config in self.gesture_map.items():
                if config["func"](hand_landmarks):
                    total_conf = hand_confidence  # Here you can combine additional scores if needed
                    # Convert gesture features to a rich natural language description
                    description = self.convert_features_to_description(gesture, hand_landmarks)
                    detected_gestures.append((gesture, config["text"], total_conf, hand_label, description))
                    break  # Only recognize one gesture per hand
        return detected_gestures

    def _process_frame(self, frame):
        """Process a single frame, overlay gesture info and draw hand landmarks."""
        frame = cv2.flip(frame, 1)
        gestures = self.detect_gesture(frame)
        current_time = time.time()

        if gestures:
            for gesture_type, gesture_text, confidence, hand_label, description in gestures:
                # Debounce repeated gestures to prevent flooding the database
                if gesture_type == self.last_gesture and (current_time - self.last_log_time < self.min_log_interval):
                    continue
                # Log gesture with its natural language description
                self._log_gesture(gesture_type, gesture_text, description, confidence)
                self.last_gesture = gesture_type
                self.last_log_time = current_time
                # Overlay both a short label and the detailed description for visualization
                cv2.putText(frame, f"{gesture_text} [{hand_label}]", (10, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                cv2.putText(frame, description, (10, 70),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
            # Also draw hand landmarks on the frame
            for hand_landmarks in self.hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)).multi_hand_landmarks or []:
                self.mp_drawing.draw_landmarks(frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS)
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
                cv2.imshow('Gesture Detection', processed_frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

            cap.release()
            cv2.destroyAllWindows()
            self.conn.close()
            logging.info("Video stream ended and database connection closed.")

        # Run the video loop in a separate thread
        video_thread = threading.Thread(target=video_loop)
        video_thread.start()
        video_thread.join()

if __name__ == "__main__":
    detector = GestureDetector()
    detector.process_video_stream()

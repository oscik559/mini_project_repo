import cv2
import mediapipe as mp
import sqlite3
import time
import uuid
from datetime import datetime
from typing import Optional, Dict, List

class EnhancedGestureProcessor:
    def __init__(self, db_path: str = 'commands.db'):
        # MediaPipe components
        self.mp_hands = mp.solutions.hands
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles

        # Initialize hands model
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.6,
            min_tracking_confidence=0.5
        )

        # Database setup
        self.conn = sqlite3.connect(db_path)
        self._init_db()

        # Gesture tracking state
        self.last_gesture: Optional[Dict] = None
        self.last_log_time: float = 0
        self.session_id: str = str(uuid.uuid4())

        # Configuration
        self.gesture_cooldown: float = 0.5  # Seconds between logs for same gesture
        self.frame_skip: int = 2  # Process every nth frame for performance

    def _init_db(self):
        """Initialize database with extended schema"""
        self.conn.execute('''CREATE TABLE IF NOT EXISTS commands
                            (id INTEGER PRIMARY KEY AUTOINCREMENT,
                             session_id TEXT,
                             timestamp DATETIME,
                             voice_command TEXT,
                             gesture_command TEXT,
                             unified_command TEXT,
                             structured_output TEXT,
                             confidence REAL,
                             hand_label TEXT)''')
        self.conn.commit()

    def _log_gesture(self, gesture_data: Dict):
        """Smart logging with cooldown and deduplication"""
        current_time = time.time()

        # Skip if same gesture within cooldown window
        if (self.last_gesture and
            gesture_data['gesture'] == self.last_gesture['gesture'] and
            (current_time - self.last_log_time) < self.gesture_cooldown):
            return

        timestamp = datetime.now().isoformat()
        self.conn.execute('''INSERT INTO commands
                            (session_id, timestamp, gesture_command,
                             confidence, hand_label)
                            VALUES (?, ?, ?, ?, ?)''',
                         (self.session_id, timestamp,
                          gesture_data['gesture'],
                          gesture_data['confidence'],
                          gesture_data['handedness']))
        self.conn.commit()
        self.last_log_time = current_time
        self.last_gesture = gesture_data

    def _process_landmarks(self, hand_landmarks, handedness) -> Optional[Dict]:
        """Custom gesture recognition using hand landmarks"""
        # Analyze hand state
        thumb_state = self._analyze_thumb(hand_landmarks)
        fingers_open = self._count_open_fingers(hand_landmarks)

        # Define gestures based on hand state
        if fingers_open == 5:
            gesture = "open_hand"
        elif fingers_open == 0:
            gesture = "closed_fist"
        elif thumb_state == "up" and fingers_open == 1:
            gesture = "thumbs_up"
        elif fingers_open == 2 and self._is_victory(hand_landmarks):
            gesture = "victory"
        else:
            gesture = "unknown"

        return {
            'gesture': gesture,
            'confidence': 0.9,  # Placeholder confidence
            'handedness': handedness.classification[0].label,
            'thumb_state': thumb_state,
            'fingers_open': fingers_open
        }

    def _analyze_thumb(self, landmarks) -> str:
        """Rule-based thumb position analysis"""
        thumb_tip = landmarks.landmark[self.mp_hands.HandLandmark.THUMB_TIP]
        thumb_ip = landmarks.landmark[self.mp_hands.HandLandmark.THUMB_IP]
        return "up" if thumb_tip.y < thumb_ip.y else "down"

    def _count_open_fingers(self, landmarks) -> int:
        """Count number of open fingers using landmark positions"""
        open_count = 0
        finger_tips = [
            self.mp_hands.HandLandmark.INDEX_FINGER_TIP,
            self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
            self.mp_hands.HandLandmark.RING_FINGER_TIP,
            self.mp_hands.HandLandmark.PINKY_TIP
        ]

        for tip in finger_tips:
            tip_y = landmarks.landmark[tip].y
            mcp_y = landmarks.landmark[tip - 2].y  # Corresponding MCP joint
            if tip_y < mcp_y:  # Finger is open if tip is above MCP
                open_count += 1
        return open_count

    def _is_victory(self, landmarks) -> bool:
        """Check for victory gesture (index and middle fingers up)"""
        index_tip = landmarks.landmark[self.mp_hands.HandLandmark.INDEX_FINGER_TIP]
        middle_tip = landmarks.landmark[self.mp_hands.HandLandmark.MIDDLE_FINGER_TIP]
        ring_tip = landmarks.landmark[self.mp_hands.HandLandmark.RING_FINGER_TIP]
        return (index_tip.y < ring_tip.y and
                middle_tip.y < ring_tip.y)

    def process_stream(self):
        """Main processing loop with performance optimizations"""
        cap = cv2.VideoCapture(0)
        frame_counter = 0

        try:
            while cap.isOpened():
                success, frame = cap.read()
                if not success:
                    continue

                frame_counter += 1
                if frame_counter % self.frame_skip != 0:
                    continue

                # Mirror and resize frame
                frame = cv2.flip(frame, 1)
                frame = cv2.resize(frame, (640, 480))

                # Process frame
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                hand_results = self.hands.process(rgb_frame)

                if hand_results.multi_hand_landmarks:
                    for idx, (hand_landmarks, handedness) in enumerate(
                        zip(hand_results.multi_hand_landmarks,
                            hand_results.multi_handedness)):

                        # Process and log gesture
                        gesture_data = self._process_landmarks(hand_landmarks, handedness)
                        if gesture_data:
                            self._log_gesture(gesture_data)

                        # Visual feedback
                        self.mp_drawing.draw_landmarks(
                            frame,
                            hand_landmarks,
                            self.mp_hands.HAND_CONNECTIONS,
                            self.mp_drawing_styles.get_default_hand_landmarks_style(),
                            self.mp_drawing_styles.get_default_hand_connections_style()
                        )

                        # Display gesture info
                        text = f"{gesture_data['handedness']}: {gesture_data['gesture']}"
                        cv2.putText(frame, text, (10, 30 + idx*30),
                                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

                cv2.imshow('Gesture Detection', frame)
                if cv2.waitKey(5) & 0xFF == 27:
                    break

        finally:
            cap.release()
            cv2.destroyAllWindows()
            self.conn.close()

if __name__ == "__main__":
    processor = EnhancedGestureProcessor()
    processor.process_stream()

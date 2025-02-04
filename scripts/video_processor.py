import cv2
import mediapipe as mp
import sqlite3
from datetime import datetime


class VideoProcessor:
    def __init__(self, db_path="sequences.db"):
        self.db_path = db_path
        self.conn = sqlite3.connect(self.db_path)
        self.c = self.conn.cursor()
        self.pose = mp.solutions.pose.Pose()

        # Ensure the instructions table exists
        self.c.execute('''
            CREATE TABLE IF NOT EXISTS instructions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                action_type TEXT,
                content TEXT
            )
        ''')
        self.conn.commit()

    def log_action(self, instruction_type, content=""):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.c.execute("INSERT INTO instructions (timestamp, instruction_type, content) VALUES (?, ?, ?)",
                       (timestamp, instruction_type, content))
        self.conn.commit()
        print(f"Logged action: {instruction_type}")

    def interpret_pose(self, landmarks):
        left_wrist = landmarks[mp.solutions.pose.PoseLandmark.LEFT_WRIST.value]
        right_wrist = landmarks[mp.solutions.pose.PoseLandmark.RIGHT_WRIST.value]
        left_shoulder = landmarks[mp.solutions.pose.PoseLandmark.LEFT_SHOULDER.value]

        if left_wrist.y < left_shoulder.y:
            return "hand_raised", "left hand above shoulder"
        elif right_wrist.y < left_shoulder.y:
            return "hand_raised", "right hand above shoulder"
        return "neutral", ""


the
    def process_video(self):
        cap = cv2.VideoCapture(0)

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = self.pose.process(rgb_frame)

            current_action = "neutral"
            content = ""

            if results.pose_landmarks:
                current_action, content = self.interpret_pose(results.pose_landmarks.landmark)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp.solutions.pose.POSE_CONNECTIONS)

            cv2.putText(frame, f"Current Action: {current_action}",
                        (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            if current_action != "neutral":
                self.log_action(current_action, content)

            cv2.imshow('Action Recognition', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()
        self.conn.close()


if __name__ == "__main__":
    processor = VideoProcessor()
    processor.process_video()

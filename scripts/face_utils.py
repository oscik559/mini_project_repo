# face_utils.py
from typing import List, Optional, Tuple

import cv2
import face_recognition
import numpy as np


class FaceUtils:
    @staticmethod
    def detect_faces(frame: np.ndarray) -> Tuple[List[tuple], List[np.ndarray]]:
        """Detect faces and their encodings in a frame"""
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)
        return face_locations, face_encodings

    @staticmethod
    def draw_bounding_boxes(
        frame: np.ndarray, face_locations: List[tuple]
    ) -> np.ndarray:
        """Draw bounding boxes around detected faces"""
        for top, right, bottom, left in face_locations:
            cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
        return frame

    @staticmethod
    def select_best_face(
        face_encodings: List[np.ndarray], face_locations: List[tuple]
    ) -> int:
        """Select the largest face when multiple faces are detected"""
        face_sizes = [
            (bottom - top) * (right - left)
            for (top, right, bottom, left) in face_locations
        ]
        return np.argmax(face_sizes)

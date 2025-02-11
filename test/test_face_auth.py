import unittest
import numpy as np
from pathlib import Path
import sys

# Since your project is not yet a proper package, ensure the parent directory is in the path.
sys.path.append(str(Path(__file__).parent.parent))

from old_scripts.face_auth_CLI import FaceUtils, FaceAuthSystem

class TestFaceUtils(unittest.TestCase):
    def test_detect_faces_empty(self):
        # Create an empty black image.
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
        auth.known_encodings = {}  # Force no known encodings.
        index = auth._build_faiss_index()
        self.assertIsNone(index)

if __name__ == "__main__":
    unittest.main(verbosity=2)

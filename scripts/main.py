# File: main_controller.py
import tkinter as tk
from GUI import InstructionCaptureGUI
from db_handler import DatabaseManager
from voice_processor import VoiceProcessor
from video_processor import VideoProcessor
from llm_processor import LLMProcessor

class MainController:
    def __init__(self):
        # Initialize core components
        self.db_manager = DatabaseManager()
        self.voice_processor = VoiceProcessor(self.db_manager)
        self.video_processor = VideoProcessor(self.db_manager)
        self.llm_processor = LLMProcessor(self.db_manager)

        # Initialize GUI
        self.gui = InstructionCaptureGUI(
            self.voice_processor,
            self.video_processor,
            self.llm_processor
        )

        # Start background processing
        self.start_background_services()

    def start_background_services(self):
        """Start background processing threads"""
        self.llm_processor.start_processing_loop()

    def run(self):
        """Start the application"""
        self.gui.run()

if __name__ == "__main__":
    controller = MainController()
    controller.run()




# File: GUI.py
import tkinter as tk
from tkinter import ttk, messagebox

class InstructionCaptureGUI:
    def __init__(self, voice_processor, video_processor, llm_processor):
        self.voice_processor = voice_processor
        self.video_processor = video_processor
        self.llm_processor = llm_processor

        self.root = tk.Tk()
        self._setup_ui()
        self._setup_status_bar()

    def _setup_ui(self):
        self.root.title("Intelligent Instruction Capture")
        self.root.geometry("800x600")

        # Main controls
        control_frame = ttk.Frame(self.root)
        control_frame.pack(pady=20)

        self.voice_btn = ttk.Button(
            control_frame,
            text="Capture Voice Instruction",
            command=self.capture_voice
        )
        self.voice_btn.pack(side=tk.LEFT, padx=10)

        self.video_btn = ttk.Button(
            control_frame,
            text="Capture Image Instruction",
            command=self.capture_image
        )
        self.video_btn.pack(side=tk.LEFT, padx=10)

        # Processing queue display
        self.queue_listbox = tk.Listbox(self.root)
        self.queue_listbox.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)

    def _setup_status_bar(self):
        self.status_bar = ttk.Label(
            self.root,
            text="Ready",
            relief=tk.SUNKEN,
            anchor=tk.W
        )
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)

    def capture_voice(self):
        try:
            self.voice_processor.start_recording()
            self.update_status("Recording... Speak now")
        except Exception as e:
            self.show_error(str(e))

    def capture_image(self):
        try:
            self.video_processor.capture_image()
            self.update_status("Image captured successfully")
        except Exception as e:
            self.show_error(str(e))

    def update_status(self, message):
        self.status_bar.config(text=message)
        self.root.update_idletasks()

    def show_error(self, message):
        messagebox.showerror("Error", message)

    def run(self):
        self.root.mainloop()




 # File: database_handler.py
import sqlite3
import os
from datetime import datetime

class DatabaseManager:
    def __init__(self, db_name="sequences.db"):
        self.db_name = db_name
        self.conn = sqlite3.connect(self.db_name)
        self._initialize_database()

    def _initialize_database(self):
        """Handle all database initialization"""
        self._create_tables()
        self._update_schemas()
        self._create_indexes()

    def _create_tables(self):
        # Original table creation logic from database_handler.py
        # ...

    def _update_schemas(self):
        # Schema update logic
        # ...

    def _create_indexes(self):
        self.execute("CREATE INDEX IF NOT EXISTS idx_processed ON instructions(processed)")

    def execute(self, query, params=()):
        cursor = self.conn.cursor()
        cursor.execute(query, params)
        self.conn.commit()
        return cursor

    def fetch(self, query, params=()):
        cursor = self.execute(query, params)
        return cursor.fetchall()

    def close(self):
        self.conn.close()



# File: voice_processor.py
import sounddevice as sd
import numpy as np
from scipy.io.wavfile import write
import webrtcvad
from faster_whisper import WhisperModel

class VoiceProcessor:
    def __init__(self, db_manager):
        self.db_manager = db_manager
        self.model = WhisperModel("large-v3", device="cuda", compute_type="float16")
        self.vad = webrtcvad.Vad(1)

    def start_recording(self, filename="temp_audio.wav"):
        # Recording logic with VAD
        # ...
        self._transcribe_and_store(filename)

    def _transcribe_and_store(self, filename):
        segments, info = self.model.transcribe(filename)
        original_text = " ".join([segment.text for segment in segments])

        # Store in database
        self.db_manager.execute(
            """INSERT INTO instructions
               (modality, audio_language, content, instruction_type)
               VALUES (?, ?, ?, ?)""",
            ("voice", info.language, original_text, "voice command")
        )




# File: LLM_processor.py
import ollama
import threading
import time

class LLMProcessor:
    def __init__(self, db_manager):
        self.db_manager = db_manager
        self.running = True
        self.processing_thread = threading.Thread(target=self._processing_loop)

    def start_processing_loop(self):
        self.processing_thread.start()

    def _processing_loop(self):
        while self.running:
            unprocessed = self.db_manager.fetch(
                "SELECT id, content FROM instructions WHERE processed = 0"
            )

            if unprocessed:
                self._process_batch(unprocessed)

            time.sleep(5)

    def _process_batch(self, batch):
        # LLM processing logic with confidence scoring
        # ...
        self._store_operations(processed_ops)

    def _store_operations(self, operations):
        # Database storage logic with versioning
        # ...

    def stop(self):
        self.running = False
        self.processing_thread.join()



# File: video_processor.py
import cv2
import datetime

class VideoProcessor:
    def __init__(self, db_manager):
        self.db_manager = db_manager

    def capture_image(self):
        cap = cv2.VideoCapture(0)
        ret, frame = cap.read()
        if ret:
            filename = f"capture_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            cv2.imwrite(filename, frame)
            self.db_manager.execute(
                "INSERT INTO instructions (modality, content) VALUES (?, ?)",
                ("image", filename)
            )
        cap.release()
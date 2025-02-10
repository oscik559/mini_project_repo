# task_manager

import logging
import threading
import time
import tkinter as tk
from tkinter import messagebox, scrolledtext

# Import system components
from db_handler import DatabaseHandler
from facial_auth import FacialAuthSystem
from llm_processor import InstructionProcessor
from video_processor import VideoProcessor
from old_scripts.voice_processor import VoiceProcessor


class TaskManager:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("HRI Task Manager")
        self.root.geometry("600x500")

        self.running = False  # Control flag for execution
        self.execution_thread = None

        self.authenticated_user = None

        # Initialize components
        self.db_handler = DatabaseHandler()
        self.facial_auth = FacialAuthSystem()
        self.voice_processor = VoiceProcessor()
        self.video_processor = VideoProcessor()
        self.llm_processor = InstructionProcessor()

        # UI Elements
        tk.Label(
            self.root, text="Human-Robot Interaction System", font=("Arial", 16)
        ).pack(pady=10)
        self.status_label = tk.Label(self.root, text="Status: Idle", font=("Arial", 10))
        self.status_label.pack(pady=10)

        tk.Button(
            self.root, text="Start Execution", command=self.start_execution, width=30
        ).pack(pady=5)
        tk.Button(
            self.root, text="Stop Execution", command=self.stop_execution, width=30
        ).pack(pady=5)
        tk.Button(
            self.root,
            text="Clear Instructions",
            command=self.clear_instructions,
            width=30,
        ).pack(pady=5)

        # Real-time Logging Panel
        tk.Label(self.root, text="System Logs:", font=("Arial", 12)).pack(pady=5)
        self.log_text = scrolledtext.ScrolledText(
            self.root, width=70, height=10, wrap=tk.WORD
        )
        self.log_text.pack(pady=10)

        # Set up logging
        logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
        self.logger = logging.getLogger()

    def log_event(self, message, level=logging.INFO):
        """Logs messages to both the UI and backend logger."""
        self.logger.log(level, message)
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.yview(tk.END)


    def authenticate_user(self):
        """Authenticate user using face or voice with error handling"""
        if self.authenticated_user:  # Skip re-authentication if already authenticated
            return self.authenticated_user

        self.log_event("Authenticating user...")
        user = self.facial_auth.identify_user()
        if user:
            self.authenticated_user = user
            self.log_event(f"User authenticated: {user['first_name']} {user['last_name']}")
            return user
        else:
            self.log_event("Face not recognized, switching to voice authentication...")
            return None


    def capture_user_input(self):
        """Capture voice and video input asynchronously"""
        self.log_event("Capturing user input...", level=logging.INFO)

        voice_thread = threading.Thread(target=self.voice_processor.capture_voice, daemon=True)
        # video_thread = threading.Thread(target=self.video_processor.process_video, daemon=True)

        voice_thread.start()
        # video_thread.start()

        self.log_event("Input capture started in background.")


    def process_instruction(self):
        """Process the latest instruction with error handling"""
        try:
            self.log_event("Fetching latest instruction...")
            instruction = self.llm_processor.get_latest_unprocessed_instruction()
            if instruction:
                self.log_event(f"Processing instruction: {instruction['content']}")
                self.llm_processor.process_instruction(instruction)
            else:
                self.log_event("No new instructions found.")
        except Exception as e:
            self.log_event(f"Instruction Processing Error: {str(e)}")


    def execute_pipeline(self):
            """Main execution loop"""
            if not self.authenticated_user:  # Authenticate only if no user is stored
                self.authenticated_user = self.authenticate_user()

            if self.authenticated_user:
                self.log_event(f"User {self.authenticated_user['first_name']} authenticated. Starting pipeline...")
                while self.running:
                    self.capture_user_input()
                    self.process_instruction()
                    time.sleep(5)  # Adjust for performance
            else:
                self.log_event("Authentication failed. Stopping execution.")
                self.running = False

    def start_execution(self):
        """Start execution loop in a separate thread"""
        if not self.running:
            self.running = True
            self.execution_thread = threading.Thread(target=self.execute_pipeline)
            self.execution_thread.start()
            self.log_event("Execution started.")

    def stop_execution(self):
        """Stop execution loop gracefully"""
        if self.running:
            self.running = False
            self.log_event("Stopping execution...")

            # Ensure threads complete their work before exiting
            if self.execution_thread and self.execution_thread.is_alive():
                self.execution_thread.join()

            self.log_event("Execution stopped.")


    def clear_instructions(self):
        """Clear instructions from the database"""
        self.db_handler.cursor.execute("DELETE FROM instructions")
        self.db_handler.conn.commit()
        self.log_event("All instructions cleared.")

    def run(self):
        """Run the GUI"""
        self.root.mainloop()


if __name__ == "__main__":
    manager = TaskManager()
    manager.run()

import logging
import threading
import time
import tkinter as tk
from tkinter import messagebox, scrolledtext

# Import your modules (adjust import paths as needed)
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from mini_project.core.db_handler import DatabaseHandler
from mini_project.modalities.command_processor import CommandProcessor
from mini_project.modalities.gesture_processor import GestureDetector
from mini_project.modalities.voice_processor import VoiceProcessor
from mini_project.modalities.orchestrator import (
    run_voice_capture,
    run_gesture_capture,
)
from mini_project.modalities.synchronizer import synchronize_and_unify
from config.app_config import *

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger("TaskManagerGUI")


class TaskManagerGUI:
    def __init__(self):
        # Main window setup
        self.root = tk.Tk()
        self.root.title("HRI Task Manager")
        self.root.geometry("700x550")

        # Execution control
        self.running = False
        self.execution_thread = None

        # Store authenticated user (a dict containing at least 'liu_id', 'first_name', 'last_name')
        self.authenticated_user = None

        # Initialize core components
        self.db_handler = DatabaseHandler()
        self.face_auth = FaceAuthSystem()
        # For fallback voice registration if needed
        self.voice_auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        self.voice_processor = VoiceProcessor()
        self.gesture_processor = GestureDetector()
        self.cmd_processor = CommandProcessor()

        # Session ID for the orchestrator session (could be re-generated per new command)
        self.session_id = None

        # UI Elements
        tk.Label(
            self.root, text="Human-Robot Interaction System", font=("Arial", 18)
        ).pack(pady=10)
        self.status_label = tk.Label(self.root, text="Status: Idle", font=("Arial", 12))
        self.status_label.pack(pady=5)

        # Buttons frame
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=10)

        tk.Button(
            btn_frame, text="Start Execution", width=15, command=self.start_execution
        ).grid(row=0, column=0, padx=5, pady=5)
        tk.Button(
            btn_frame, text="Stop Execution", width=15, command=self.stop_execution
        ).grid(row=0, column=1, padx=5, pady=5)
        tk.Button(
            btn_frame, text="New Command", width=15, command=self.new_command
        ).grid(row=1, column=0, padx=5, pady=5)
        tk.Button(
            btn_frame, text="Clear Tables", width=15, command=self.clear_tables
        ).grid(row=1, column=1, padx=5, pady=5)
        tk.Button(btn_frame, text="Exit", width=15, command=self.exit_application).grid(
            row=2, column=0, columnspan=2, pady=10
        )

        # Logging panel
        tk.Label(self.root, text="System Logs:", font=("Arial", 12)).pack(pady=5)
        self.log_text = scrolledtext.ScrolledText(
            self.root, width=80, height=15, wrap=tk.WORD
        )
        self.log_text.pack(pady=5)
        self.log_event("Application started. Please authenticate.")

    def log_event(self, message, level=logging.INFO):
        logger.log(level, message)
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.see(tk.END)
        self.status_label.config(text=f"Status: {message}")

    def authenticate_user(self):
        self.log_event("Authenticating user via face recognition...")
        # Try face authentication; if no face match then ask to register.
        user = self.face_auth.identify_user()
        if user:
            self.authenticated_user = user
            self.log_event(f"Welcome, {user['first_name']} {user['last_name']}!")
        else:
            self.log_event(
                "Face not recognized. Please register via face authentication."
            )
            self.face_auth.register_user()
            # After registration, attempt identification again
            user = self.face_auth.identify_user()
            if user:
                self.authenticated_user = user
                self.log_event(f"Welcome, {user['first_name']} {user['last_name']}!")
            else:
                self.log_event("Authentication failed. Try again later.")
        return self.authenticated_user

    def start_execution(self):
        if not self.running:
            if not self.authenticated_user:
                if not self.authenticate_user():
                    return
            self.session_id = self.session_id or self.generate_session_id()
            self.running = True
            self.execution_thread = threading.Thread(
                target=self.execution_pipeline, daemon=True
            )
            self.execution_thread.start()
            self.log_event("Execution started.")

    def stop_execution(self):
        if self.running:
            self.running = False
            self.log_event("Stopping execution...")
            if self.execution_thread and self.execution_thread.is_alive():
                self.execution_thread.join()
            self.log_event("Execution stopped.")

    def new_command(self):
        # Clear any previous session data and start a new session
        self.session_id = self.generate_session_id()
        self.log_event("Starting a new command capture session.")
        self.start_execution()

    def clear_tables(self):
        try:
            # Clear instructions from relevant tables; adjust table names if needed.
            self.db_handler.cursor.execute("DELETE FROM unified_instructions")
            self.db_handler.cursor.execute("DELETE FROM voice_instructions")
            self.db_handler.cursor.execute("DELETE FROM gesture_instructions")
            self.db_handler.cursor.execute("DELETE FROM instruction_operation_sequence")
            self.db_handler.conn.commit()
            self.log_event("Instructions cleared from database.")
        except Exception as e:
            self.log_event(f"Error clearing tables: {str(e)}", level=logging.ERROR)

    def exit_application(self):
        self.stop_execution()
        self.db_handler.close()
        self.root.destroy()

    def generate_session_id(self):
        import uuid

        return str(uuid.uuid4())

    def execution_pipeline(self):
        """
        This pipeline mimics your intended process:
         1. Capture voice and gesture concurrently via the orchestrator functions.
         2. After capture, the synchronizer (with liu_id passed) generates a unified command.
         3. The unified command is displayed and the user is asked: “Is this what you want?”
         4. YES → process the command (via CommandProcessor) to populate the operation sequence.
            NO  → re-run the voice/gesture capture.
        """
        # For simplicity, here we call the voice and gesture capture functions sequentially in separate threads.
        while self.running:
            self.log_event("Capturing voice and gesture input...")
            voice_thread = threading.Thread(
                target=run_voice_capture, args=(self.session_id,)
            )
            gesture_thread = threading.Thread(
                target=run_gesture_capture, args=(self.session_id,)
            )
            voice_thread.start()
            gesture_thread.start()
            voice_thread.join()
            gesture_thread.join()
            self.log_event("Capture complete. Running synchronizer...")

            # IMPORTANT: Pass the authenticated liu_id so that the unified instruction is stored with the correct identifier.
            liu_id = (
                self.authenticated_user.get("liu_id")
                if self.authenticated_user
                else None
            )
            synchronize_and_unify(db_path=DB_PATH, liu_id=liu_id)

            # Retrieve and display the unified command
            unified = self.cmd_processor.get_unprocessed_unified_command()
            if unified:
                unified_text = unified.get("unified_command", "")
                self.log_event(f"Unified Command: {unified_text}")
                # Ask user for confirmation
                answer = messagebox.askyesno(
                    "Confirm Command",
                    f"Is this your intended command?\n\n{unified_text}",
                )
                if answer:
                    self.log_event("User confirmed the command. Processing...")
                    if self.cmd_processor.process_command(unified):
                        self.log_event("Command processed successfully.")
                    else:
                        self.log_event(
                            "Command processing failed.", level=logging.ERROR
                        )
                else:
                    self.log_event("User rejected the command. Recapturing input...")
                    continue  # Loop will re-run capture
            else:
                self.log_event(
                    "No unified command found. Retrying capture...",
                    level=logging.WARNING,
                )

            time.sleep(5)  # Wait a few seconds before next cycle

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = TaskManagerGUI()
    app.run()

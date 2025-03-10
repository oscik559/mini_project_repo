# workflow/task_manager.py
# Approach 1: Task Manager GUI

import logging
import threading
import time
import tkinter as tk
import uuid
from tkinter import messagebox, scrolledtext

from config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

# Import your project modules (adjust import paths as needed)
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from mini_project.modalities.command_processor import CommandProcessor
from mini_project.modalities.orchestrator import run_gesture_capture, run_voice_capture
from experimental.synchronizer import synchronize_and_unify

# Configure logging for the application
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger("TaskManagerGUI_Approach1")


class TaskManagerGUIApproach1:
    def __init__(self):
        # Create the main GUI window
        self.root = tk.Tk()
        self.root.title("HRI Task Manager - Approach 1")
        self.root.geometry("700x550")

        # State variables for execution and session
        self.running = False
        self.session_id = None
        self.authenticated_user = (
            None  # Expected to be a dict with keys 'liu_id', 'first_name', etc.
        )

        # Instantiate core modules using existing authentication and processing components
        self.face_auth = FaceAuthSystem()
        self.voice_auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        self.cmd_processor = CommandProcessor()

        # Build GUI elements
        tk.Label(
            self.root,
            text="Human-Robot Interaction System (Approach 1)",
            font=("Arial", 18),
        ).pack(pady=10)
        self.status_label = tk.Label(self.root, text="Status: Idle", font=("Arial", 12))
        self.status_label.pack(pady=5)

        # Create a button frame and add control buttons
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=10)
        self.start_btn = tk.Button(
            btn_frame, text="Start Execution", width=15, command=self.start_execution
        )
        self.start_btn.grid(row=0, column=0, padx=5, pady=5)
        self.stop_btn = tk.Button(
            btn_frame,
            text="Stop Execution",
            width=15,
            command=self.stop_execution,
            state=tk.DISABLED,
        )
        self.stop_btn.grid(row=0, column=1, padx=5, pady=5)
        self.new_cmd_btn = tk.Button(
            btn_frame,
            text="New Command",
            width=15,
            command=self.new_command,
            state=tk.DISABLED,
        )
        self.new_cmd_btn.grid(row=1, column=0, padx=5, pady=5)
        tk.Button(
            btn_frame, text="Clear Tables", width=15, command=self.clear_tables
        ).grid(row=1, column=1, padx=5, pady=5)
        tk.Button(btn_frame, text="Exit", width=15, command=self.exit_application).grid(
            row=2, column=0, columnspan=2, pady=10
        )

        # Create a scrolling text widget to display system logs
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

    def set_controls_state(
        self, start_enabled=True, stop_enabled=False, new_cmd_enabled=False
    ):
        self.start_btn.config(state=tk.NORMAL if start_enabled else tk.DISABLED)
        self.stop_btn.config(state=tk.NORMAL if stop_enabled else tk.DISABLED)
        self.new_cmd_btn.config(state=tk.NORMAL if new_cmd_enabled else tk.DISABLED)

    def authenticate_user(self):
        self.log_event("Performing initial face identification...")
        # Attempt face authentication (blocking call)
        user = self.face_auth.identify_user()
        if user:
            self.authenticated_user = user
            self.log_event(
                f"Welcome, {user['first_name']} {user['last_name']}! (liu_id: {user['liu_id']})"
            )
        else:
            self.log_event(
                "Face not recognized. Initiating manual face registration...",
                level=logging.WARNING,
            )
            # Call face registration first
            self.face_auth.register_user()

            # Retry face identification after both registrations
            user = self.face_auth.identify_user()
            if user:
                self.authenticated_user = user
                self.log_event(
                    f"Welcome, {user['first_name']} {user['last_name']}! (liu_id: {user['liu_id']})"
                )
            else:
                self.log_event(
                    "Authentication failed. Please try again.", level=logging.ERROR
                )
        return self.authenticated_user

    def generate_session_id(self):
        self.session_id = str(uuid.uuid4())
        self.log_event(f"New session started. Session ID: {self.session_id}")
        return self.session_id

    def start_execution(self):
        if not self.running:
            # First, ensure the user is authenticated
            if not self.authenticated_user:
                if not self.authenticate_user():
                    return  # Abort if authentication fails
            if not self.session_id:
                self.generate_session_id()
            self.running = True
            self.set_controls_state(
                start_enabled=False, stop_enabled=True, new_cmd_enabled=False
            )
            threading.Thread(target=self.execution_pipeline, daemon=True).start()
            self.log_event("Execution started.")

    def stop_execution(self):
        if self.running:
            self.running = False
            self.set_controls_state(
                start_enabled=True, stop_enabled=False, new_cmd_enabled=True
            )
            self.log_event("Execution stopped.")

    def new_command(self):
        # Generate a new session ID and start a new capture cycle
        self.session_id = self.generate_session_id()
        self.log_event("New command session started.")
        self.start_execution()

    def clear_tables(self):
        try:
            cursor = self.cmd_processor.conn.cursor()
            cursor.execute("DELETE FROM unified_instructions")
            cursor.execute("DELETE FROM voice_instructions")
            cursor.execute("DELETE FROM gesture_instructions")
            cursor.execute("DELETE FROM instruction_operation_sequence")
            self.cmd_processor.conn.commit()
            self.log_event("Database instructions cleared.")
        except Exception as e:
            self.log_event(f"Error clearing tables: {str(e)}", level=logging.ERROR)

    def exit_application(self):
        self.stop_execution()
        self.cmd_processor.close()
        self.root.destroy()

    def execution_pipeline(self):
        """
        Execution Pipeline Flow:
          1. Start voice and gesture capture concurrently.
          2. Immediately after starting the threads, display a prompt: "Please speak your request".
          3. Wait for both capture threads to complete.
          4. With the pre-authenticated liu_id, merge captured inputs via the synchronizer.
          5. Retrieve the unified command and prompt the user for confirmation.
          6. If confirmed and processed successfully, end the session.
             If rejected or processing fails, re-capture inputs.
        """
        while self.running:
            try:

                # Start voice and gesture capture concurrently
                voice_thread = threading.Thread(
                    target=run_voice_capture, args=(self.session_id,), daemon=True
                )
                gesture_thread = threading.Thread(
                    target=run_gesture_capture, args=(self.session_id,), daemon=True
                )
                voice_thread.start()
                gesture_thread.start()
                # Now that capture threads are running, display the prompt.
                self.log_event(
                    "Voice and gesture capture started. Please speak your request."
                )
                voice_thread.join()
                gesture_thread.join()
                self.log_event("Voice and gesture capture complete.")

                # Use the stored liu_id from the authenticated user
                liu_id = (
                    self.authenticated_user.get("liu_id")
                    if self.authenticated_user
                    else None
                )

                self.log_event("Merging inputs...")
                synchronize_and_unify(db_path=DB_PATH, liu_id=liu_id)
                unified = self.cmd_processor.get_unprocessed_unified_command()
                if unified:
                    unified_text = unified.get("unified_command", "")
                    self.log_event(f"Unified Command: {unified_text}")
                    # Ask for confirmation via a pop-up
                    if messagebox.askyesno(
                        "Confirm Command",
                        f"Is this your intended command?\n\n{unified_text}",
                    ):
                        self.log_event("User confirmed the command. Processing...")
                        if self.cmd_processor.process_command(unified):
                            self.log_event("Command processed successfully.")
                            # End session after successful processing.
                            self.running = False
                            break

                        else:
                            self.log_event(
                                "Command processing failed. Re-capturing input...",
                                level=logging.ERROR,
                            )
                            continue
                    else:
                        self.log_event(
                            "Command rejected by user. Re-capturing input command..."
                        )
                        continue  # Repeat the input capture loop
                else:
                    self.log_event(
                        "No unified command generated. Retrying capture...",
                        level=logging.WARNING,
                    )
                time.sleep(2)  # Brief pause before next loop iteration
            except Exception as e:
                self.log_event(
                    f"Error during execution pipeline: {str(e)}", level=logging.ERROR
                )
                break
        # When loop exits, update control states appropriately
        self.set_controls_state(
            start_enabled=True, stop_enabled=False, new_cmd_enabled=True
        )
        self.log_event("Session ended. Use 'Start Execution' to begin a new session.")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = TaskManagerGUIApproach1()
    app.run()

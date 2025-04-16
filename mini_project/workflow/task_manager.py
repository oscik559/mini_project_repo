# workflow/task_manager.py

import logging
import threading
import time
import tkinter as tk
from tkinter import messagebox, scrolledtext

from config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from mini_project.modalities.command_processor_SQLite import CommandProcessor
from mini_project.modalities.orchestrator import run_gesture_capture, run_voice_capture
from mini_project.modalities.synchronizer import synchronize_and_unify
from mini_project.workflow.session_manager import SessionManager

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger("TaskManagerGUI_Approach1")


class TaskManagerGUIApproach1:
    def __init__(self):
        # Create the main GUI window
        self.root = tk.Tk()
        self.root.title("HRI Task Manager - Approach 1")
        self.root.geometry("700x550")

        # Instantiate session manager and command processor.
        self.session_manager = SessionManager()
        self.cmd_processor = CommandProcessor()

        # Build GUI elements
        tk.Label(
            self.root,
            text="Human-Robot Interaction System (Approach 1)",
            font=("Arial", 18),
        ).pack(pady=10)
        self.status_label = tk.Label(self.root, text="Status: Idle", font=("Arial", 12))
        self.status_label.pack(pady=5)

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

    def start_execution(self):
        if not self.session_manager.running:
            # Ensure that the user is authenticated.
            if not self.session_manager.authenticated_user:
                user = self.session_manager.authenticate_user()
                if not user:
                    self.log_event(
                        "Authentication failed. Aborting execution.",
                        level=logging.ERROR,
                    )
                    return
                else:
                    # Display a welcome message once authenticated.
                    welcome_msg = f"Welcome, {user['first_name']} {user['last_name']} (ID: {user['liu_id']})"
                    self.log_event(welcome_msg)
            # Create a new session if one does not exist.
            if not self.session_manager.session_id:
                self.session_manager.create_session()
            self.set_controls_state(
                start_enabled=False, stop_enabled=True, new_cmd_enabled=False
            )
            threading.Thread(target=self.execution_pipeline, daemon=True).start()
            self.log_event("Execution started.")

    def stop_execution(self):
        if self.session_manager.running:
            self.session_manager.cancel_session()
            self.set_controls_state(
                start_enabled=True, stop_enabled=False, new_cmd_enabled=True
            )
            self.log_event("Execution stopped.")

    def new_command(self):
        # Retry session and start a new capture cycle.
        self.session_manager.retry_session()
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
        Execution Pipeline:
          1. Start voice and gesture capture concurrently.
          2. Display prompt for voice input.
          3. Wait for the capture threads to complete.
          4. Merge inputs via the synchronizer.
          5. Retrieve and confirm the unified command with the user.
          6. If confirmed and processed, end the session; otherwise, repeat capture.
        """
        while self.session_manager.running:
            try:
                # Start voice and gesture capture concurrently.
                voice_thread = threading.Thread(
                    target=run_voice_capture,
                    args=(self.session_manager.session_id,),
                    daemon=True,
                )
                gesture_thread = threading.Thread(
                    target=run_gesture_capture,
                    args=(self.session_manager.session_id,),
                    daemon=True,
                )
                voice_thread.start()
                gesture_thread.start()
                self.log_event(
                    "Voice and gesture capture started. Please speak your request."
                )
                voice_thread.join()
                gesture_thread.join()
                self.log_event("Voice and gesture capture completed.")

                # Merge inputs using the synchronizer.
                liu_id = (
                    self.session_manager.authenticated_user.get("liu_id")
                    if self.session_manager.authenticated_user
                    else None
                )
                self.log_event("Merging captured inputs...")
                synchronize_and_unify(db_path=DB_PATH, liu_id=liu_id)
                unified = self.cmd_processor.get_unprocessed_unified_command()
                if unified:
                    unified_text = unified.get("unified_command", "")
                    self.log_event(f"Unified Command: {unified_text}")
                    if messagebox.askyesno(
                        "Confirm Command",
                        f"Is this your intended command?\n\n{unified_text}",
                    ):
                        self.log_event("User confirmed command. Processing...")
                        if self.cmd_processor.process_command(unified):
                            self.log_event("Command processed successfully.")
                            self.session_manager.cancel_session()
                            break
                        else:
                            self.log_event(
                                "Command processing failed. Re-capturing input...",
                                level=logging.ERROR,
                            )
                            continue
                    else:
                        self.log_event(
                            "Command rejected by user. Re-capturing input..."
                        )
                        continue  # Repeat the capture loop.
                else:
                    self.log_event(
                        "No unified command generated. Retrying capture...",
                        level=logging.WARNING,
                    )
                time.sleep(2)
            except Exception as e:
                self.log_event(
                    f"Error during execution pipeline: {str(e)}", level=logging.ERROR
                )
                break

        self.set_controls_state(
            start_enabled=True, stop_enabled=False, new_cmd_enabled=True
        )
        self.log_event("Session ended. Use 'Start Execution' to begin a new session.")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = TaskManagerGUIApproach1()
    app.run()

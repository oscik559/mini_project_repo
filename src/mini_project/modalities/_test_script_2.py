import logging
import threading
import time
import tkinter as tk
import uuid
from tkinter import messagebox, scrolledtext

from config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

# Import modules from your project
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from mini_project.modalities.command_processor import CommandProcessor
from mini_project.modalities.orchestrator import run_gesture_capture, run_voice_capture
from mini_project.modalities.synchronizer import synchronize_and_unify

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger("TaskManagerGUI_Approach2")


class TaskManagerGUIApproach2:
    def __init__(self):
        # Setup main window
        self.root = tk.Tk()
        self.root.title("HRI Task Manager - Approach 2")
        self.root.geometry("700x550")

        # Initialize session and authentication state
        self.session_id = str(uuid.uuid4())
        self.authenticated_user = None

        # Instantiate modules
        self.face_auth = FaceAuthSystem()
        self.voice_auth = VoiceAuth(DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH)
        self.cmd_processor = CommandProcessor()

        # GUI Widgets
        tk.Label(
            self.root, text="HRI Task Manager (Approach 2)", font=("Arial", 18)
        ).pack(pady=10)
        self.status_label = tk.Label(
            self.root, text="Status: Waiting for input", font=("Arial", 12)
        )
        self.status_label.pack(pady=5)

        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=10)
        tk.Button(
            btn_frame, text="Start Execution", width=15, command=self.start_execution
        ).grid(row=0, column=0, padx=5, pady=5)
        tk.Button(
            btn_frame, text="Stop Execution", width=15, command=self.stop_execution
        ).grid(row=0, column=1, padx=5, pady=5)
        tk.Button(
            btn_frame, text="Clear Tables", width=15, command=self.clear_tables
        ).grid(row=1, column=0, padx=5, pady=5)
        tk.Button(btn_frame, text="Exit", width=15, command=self.exit_application).grid(
            row=1, column=1, padx=5, pady=5
        )

        tk.Label(self.root, text="System Logs:", font=("Arial", 12)).pack(pady=5)
        self.log_text = scrolledtext.ScrolledText(
            self.root, width=80, height=15, wrap=tk.WORD
        )
        self.log_text.pack(pady=5)

        self.log_event(f"Session ID: {self.session_id} - Please speak your request.")

    def log_event(self, message, level=logging.INFO):
        logger.log(level, message)
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.see(tk.END)
        self.status_label.config(text=f"Status: {message}")

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

    def authentication_monitor(self):
        """
        Continuously monitor for user identification during input capture.
        This thread calls the face_auth.identify_user() function in a loop.
        """
        while self.running:
            user = self.face_auth.identify_user()
            if user:
                self.authenticated_user = user
                self.log_event(
                    f"User identified: {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
                )
                break
            else:
                time.sleep(2)

    def start_execution(self):
        if not self.running:
            self.running = True
            # Start authentication monitoring concurrently
            auth_thread = threading.Thread(
                target=self.authentication_monitor, daemon=True
            )
            auth_thread.start()

            # Start voice and gesture capture threads concurrently
            voice_thread = threading.Thread(
                target=run_voice_capture, args=(self.session_id,), daemon=True
            )
            gesture_thread = threading.Thread(
                target=run_gesture_capture, args=(self.session_id,), daemon=True
            )
            voice_thread.start()
            gesture_thread.start()

            # Wait for capture threads to finish
            voice_thread.join()
            gesture_thread.join()

            # If user is not identified, prompt for registration and retry authentication
            if not self.authenticated_user:
                self.log_event(
                    "User not identified. Prompting for registration...",
                    level=logging.WARNING,
                )
                self.voice_auth.register_user()
                self.authenticated_user = self.face_auth.identify_user()

            # Send captured data along with liu_id to synchronizer
            liu_id = (
                self.authenticated_user.get("liu_id")
                if self.authenticated_user
                else None
            )
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
                    else:
                        self.log_event(
                            "Command processing failed.", level=logging.ERROR
                        )
                else:
                    self.log_event("User rejected command. Re-capturing input...")
                    self.start_execution()  # Recapture input
            else:
                self.log_event(
                    "No unified command generated. Retrying capture...",
                    level=logging.WARNING,
                )
            self.log_event("Ready for next command.")
        else:
            self.log_event("Execution already running.")

    def stop_execution(self):
        if self.running:
            self.running = False
            self.log_event("Execution stopped.")

    def run(self):
        self.running = False  # Ensure execution flag is initially false
        self.root.mainloop()


if __name__ == "__main__":
    app = TaskManagerGUIApproach2()
    app.run()

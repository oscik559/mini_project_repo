# workflow/task_manager_pyside6.py

import logging
import threading
import time

# PySide6 imports
from PySide6.QtCore import (
    Qt,
    QObject,
    Signal,
    QEventLoop,
    QTimer,
)
from PySide6.QtWidgets import (
    QApplication,
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QPushButton,
    QPlainTextEdit,
    QMessageBox,
)

from config.app_config import DB_PATH
from mini_project.authentication.face_auth import FaceAuthSystem
from mini_project.authentication.voice_auth import VoiceAuth
from mini_project.modalities.command_processor import CommandProcessor
from mini_project.modalities.orchestrator import run_voice_capture, run_gesture_capture
from mini_project.modalities.synchronizer import synchronize_and_unify
from mini_project.workflow.session_manager import SessionManager

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger("TaskManagerGUI_PySide6")


class WorkerSignals(QObject):
    """
    Signals used by the background worker thread to communicate
    with the main GUI thread.
    """

    log_message = Signal(str)
    error_message = Signal(str)
    finished = Signal()

    # New signals for user confirmation flow:
    # 1) Worker requests confirmation
    confirmation_needed = Signal(str)
    # 2) GUI replies with user's answer
    confirmation_reply = Signal(bool)


class ExecutionWorker(threading.Thread):
    """
    A worker thread that handles the voice+gesture capture pipeline
    and waits for confirmation from the user, but only via signals
    (no direct GUI calls).
    """

    def __init__(self, session_manager, cmd_processor, db_path, signals):
        super().__init__(daemon=True)
        self.session_manager = session_manager
        self.cmd_processor = cmd_processor
        self.db_path = db_path
        self.signals = signals

        self._running = True
        # For storing the user's confirmation (Yes/No)
        self._confirm_result = None
        # A condition variable to wait for the main thread's response
        self._confirm_cond = threading.Condition()

        # Connect the 'confirmation_reply' signal to our local method
        # so we can receive the user's answer in this thread.
        self.signals.confirmation_reply.connect(self.on_confirmation_reply)

    def run(self):
        """
        Equivalent to your 'execution_pipeline' logic, but avoids directly
        calling GUI code (like message boxes). Instead, we emit signals and
        wait for the user’s response via a condition variable.
        """
        while self._running and self.session_manager.running:
            try:
                # Start voice & gesture capture concurrently
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
                self.signals.log_message.emit(
                    "Voice and gesture capture started. Please speak your request."
                )

                voice_thread.join()
                gesture_thread.join()
                self.signals.log_message.emit("Voice and gesture capture completed.")

                # Merge inputs with the synchronizer
                liu_id = None
                if self.session_manager.authenticated_user:
                    liu_id = self.session_manager.authenticated_user.get("liu_id")

                self.signals.log_message.emit("Merging captured inputs...")
                synchronize_and_unify(db_path=self.db_path, liu_id=liu_id)

                unified = self.cmd_processor.get_unprocessed_unified_command()
                if unified:
                    unified_text = unified.get("unified_command", "")
                    # Request user confirmation *via signal*
                    self.signals.log_message.emit(f"Unified Command: {unified_text}")
                    self.signals.confirmation_needed.emit(unified_text)

                    # Wait for the main thread’s reply
                    with self._confirm_cond:
                        self._confirm_cond.wait()
                    # self._confirm_result is set in on_confirmation_reply()

                    if self._confirm_result:
                        self.signals.log_message.emit(
                            "User confirmed command. Processing..."
                        )
                        success = self.cmd_processor.process_command(unified)
                        if success:
                            self.signals.log_message.emit(
                                "Command processed successfully."
                            )
                            self.session_manager.cancel_session()
                            break
                        else:
                            self.signals.error_message.emit(
                                "Command processing failed. Re-capturing input..."
                            )
                            continue
                    else:
                        self.signals.log_message.emit(
                            "Command rejected by user. Re-capturing input..."
                        )
                        continue
                else:
                    self.signals.log_message.emit(
                        "No unified command generated. Retrying capture..."
                    )

                time.sleep(2)

            except Exception as e:
                self.signals.error_message.emit(
                    f"Error during execution pipeline: {str(e)}"
                )
                break

        self.signals.finished.emit()

    def on_confirmation_reply(self, user_answer: bool):
        """
        Slot to receive the user’s answer from the main thread.
        """
        with self._confirm_cond:
            self._confirm_result = user_answer
            self._confirm_cond.notify()


class TaskManagerGUIApproach1(QMainWindow):
    """
    The main window (GUI). All direct Qt calls occur here on the main thread.
    """

    def __init__(self):
        super().__init__()
        self.setWindowTitle("HRI Task Manager - PySide6 Approach")
        self.resize(700, 550)

        # Instantiate session manager & command processor
        self.session_manager = SessionManager()
        self.cmd_processor = CommandProcessor()

        # Main widget & layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        main_layout = QVBoxLayout(main_widget)

        # Title label
        title_label = QLabel("Human-Robot Interaction System (Approach 1)")
        title_label.setStyleSheet("font-size: 18px;")
        main_layout.addWidget(title_label, alignment=Qt.AlignmentFlag.AlignCenter)

        # Status label
        self.status_label = QLabel("Status: Idle")
        main_layout.addWidget(self.status_label)

        # Buttons layout
        btn_layout = QHBoxLayout()
        main_layout.addLayout(btn_layout)

        self.start_btn = QPushButton("Start Execution")
        self.start_btn.clicked.connect(self.start_execution)
        btn_layout.addWidget(self.start_btn)

        self.stop_btn = QPushButton("Stop Execution")
        self.stop_btn.setEnabled(False)
        self.stop_btn.clicked.connect(self.stop_execution)
        btn_layout.addWidget(self.stop_btn)

        self.new_cmd_btn = QPushButton("New Command")
        self.new_cmd_btn.setEnabled(False)
        self.new_cmd_btn.clicked.connect(self.new_command)
        btn_layout.addWidget(self.new_cmd_btn)

        self.clear_btn = QPushButton("Clear Tables")
        self.clear_btn.clicked.connect(self.clear_tables)
        btn_layout.addWidget(self.clear_btn)

        self.exit_btn = QPushButton("Exit")
        self.exit_btn.clicked.connect(self.exit_application)
        btn_layout.addWidget(self.exit_btn)

        # Log text area
        self.log_text = QPlainTextEdit()
        self.log_text.setReadOnly(True)
        main_layout.addWidget(self.log_text)

        self.log_event("Application started. Please authenticate.")

        # Reference to background worker
        self.worker_thread = None
        # Create the shared signals object
        self.signals = WorkerSignals()

        # Connect signals that come from the worker to our handlers:
        self.signals.log_message.connect(self.on_worker_log)
        self.signals.error_message.connect(self.on_worker_log)
        self.signals.finished.connect(self.on_worker_finished)
        # Connect the 'confirmation_needed' signal so we can show a dialog
        self.signals.confirmation_needed.connect(self.on_confirmation_needed)

    def log_event(self, message, level=logging.INFO):
        logger.log(level, message)
        self.log_text.appendPlainText(message)
        # auto-scroll to bottom
        self.log_text.verticalScrollBar().setValue(
            self.log_text.verticalScrollBar().maximum()
        )
        self.status_label.setText(f"Status: {message}")

    def set_controls_state(
        self, start_enabled=True, stop_enabled=False, new_cmd_enabled=False
    ):
        self.start_btn.setEnabled(start_enabled)
        self.stop_btn.setEnabled(stop_enabled)
        self.new_cmd_btn.setEnabled(new_cmd_enabled)

    def start_execution(self):
        if not self.session_manager.running:
            # Ensure user is authenticated
            if not self.session_manager.authenticated_user:
                user = self.session_manager.authenticate_user()
                if not user:
                    self.log_event(
                        "Authentication failed. Aborting execution.", logging.ERROR
                    )
                    return
                else:
                    # Display welcome message once authenticated
                    welcome_msg = (
                        f"Welcome, {user['first_name']} {user['last_name']} "
                        f"(ID: {user['liu_id']})"
                    )
                    self.log_event(welcome_msg)

            # Create a new session if none exists
            if not self.session_manager.session_id:
                self.session_manager.create_session()

            self.set_controls_state(
                start_enabled=False, stop_enabled=True, new_cmd_enabled=False
            )
            self.log_event("Execution started.")

            # Start the worker thread for the pipeline
            self.worker_thread = ExecutionWorker(
                self.session_manager, self.cmd_processor, DB_PATH, self.signals
            )
            self.worker_thread.start()

    def stop_execution(self):
        if self.session_manager.running:
            self.session_manager.cancel_session()
            self.set_controls_state(
                start_enabled=True, stop_enabled=False, new_cmd_enabled=True
            )
            self.log_event("Execution stopped.")

    def new_command(self):
        # Retry session and start a new capture cycle
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
        self.close()

    # Slots / handlers for signals

    def on_worker_log(self, message: str):
        """Receive log or error messages from the worker."""
        self.log_event(message)

    def on_worker_finished(self):
        """Called when the worker signals it's done (finished)."""
        self.set_controls_state(
            start_enabled=True, stop_enabled=False, new_cmd_enabled=True
        )
        self.log_event("Session ended. Use 'Start Execution' to begin a new session.")

    def on_confirmation_needed(self, command_text: str):
        """
        Called on the main thread when the worker needs user confirmation.
        We show a blocking message box, then emit 'confirmation_reply' with True/False.
        """
        reply = QMessageBox.question(
            self,
            "Confirm Command",
            f"Is this your intended command?\n\n{command_text}",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
        )
        user_answer = reply == QMessageBox.StandardButton.Yes
        # Send the answer back to the worker
        self.signals.confirmation_reply.emit(user_answer)

    def run(self):
        self.show()


def main():
    import sys

    app = QApplication(sys.argv)
    window = TaskManagerGUIApproach1()
    window.run()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()

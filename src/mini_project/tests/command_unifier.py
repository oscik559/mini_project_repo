# scripts/command_unifier.py
import json
import logging
import sqlite3
import subprocess
import threading
import time
import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional

MERGE_WINDOW = 5
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)


class CommandUnifier:
    def __init__(self, db_path: str = "unified_commands.db"):
        self.db_path = db_path
        self.command_queue = []
        self.lock = threading.Lock()
        self.session_id = str(uuid.uuid4())
        self._init_db()

    def _init_db(self):
        """Initialize unified database schema"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                """CREATE TABLE IF NOT EXISTS commands
                         (id INTEGER PRIMARY KEY AUTOINCREMENT,
                          session_id TEXT,
                          timestamp DATETIME,
                          modality TEXT,
                          command_type TEXT,
                          command_text TEXT,
                          natural_description TEXT,
                          confidence REAL,
                          hand_label TEXT,
                          language TEXT,
                          content TEXT)"""
            )
            conn.commit()

    def add_command(self, command: Dict[str, Any]):
        """Thread-safe method to add commands to the queue"""
        with self.lock:
            self.command_queue.append(command)
            self._store_in_db(command)

    def _store_in_db(self, command: Dict[str, Any]):
        """Store command directly in the database"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute(
                    """INSERT INTO commands
                              (session_id, timestamp, modality, command_type,
                               command_text, natural_description, confidence,
                               hand_label, language, content)
                              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    (
                        self.session_id,
                        command.get("timestamp"),
                        command["modality"],
                        command.get("command_type"),
                        command.get("command_text"),
                        command.get("natural_description"),
                        command.get("confidence", 1.0),
                        command.get("hand_label", ""),
                        command.get("language", ""),
                        command.get("content", ""),
                    ),
                )
                conn.commit()
        except sqlite3.Error as e:
            logging.error(f"Database error: {e}")

    def process_real_time_commands(self):
        """Real-time command processing (simple heuristics)"""
        while True:
            with self.lock:
                if self.command_queue:
                    cmd = self.command_queue.pop(0)
                    self._execute_basic_command(cmd)
            time.sleep(0.1)

    def _execute_basic_command(self, cmd: Dict[str, Any]):
        """Immediate response for critical commands"""
        if cmd["modality"] == "gesture":
            if cmd["command_type"] == "thumbs_up":
                logging.info("Real-time feedback: 👍 Action approved!")
            elif cmd["command_type"] == "open_hand":
                logging.info("Real-time feedback: ✋ Stopping current action")

    def post_process_unification(self):
        """LLM-based unification after session ends"""
        voice_cmds, gesture_cmds = self._get_commands()
        self._create_unified_table()

        # Sort commands by timestamp
        voice_cmds.sort(key=lambda x: x["timestamp"])
        gesture_cmds.sort(key=lambda x: x["timestamp"])

        for vc in voice_cmds:
            matched_gestures = self._find_matching_gestures(vc, gesture_cmds)
            if matched_gestures:
                best_match = min(
                    matched_gestures,
                    key=lambda g: abs(
                        (g["timestamp"] - vc["timestamp"]).total_seconds()
                    ),
                )
                unified = self._llm_unify(vc, best_match)
                self._store_unified(vc, best_match, unified)
            else:
                self._store_unified(vc, None, vc["content"])

    def _get_commands(self) -> tuple:
        """Retrieve commands from database"""
        with sqlite3.connect(self.db_path) as conn:
            voice = conn.execute(
                "SELECT * FROM commands WHERE modality='voice'"
            ).fetchall()
            gestures = conn.execute(
                "SELECT * FROM commands WHERE modality='gesture'"
            ).fetchall()
        return self._format_results(voice), self._format_results(gestures)

    def _format_results(self, rows: List[tuple]) -> List[Dict[str, Any]]:
        """Format database rows into dictionaries"""
        formatted = []
        for row in rows:
            formatted.append(
                {
                    "id": row[0],
                    "session_id": row[1],
                    "timestamp": datetime.fromisoformat(row[2]),
                    "modality": row[3],
                    "command_type": row[4],
                    "command_text": row[5],
                    "natural_description": row[6],
                    "confidence": row[7],
                    "hand_label": row[8],
                    "language": row[9],
                    "content": row[10],
                }
            )
        return formatted

    def _find_matching_gestures(
        self, voice_cmd: Dict[str, Any], gesture_cmds: List[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Find gestures within the merge window of a voice command"""
        matched = []
        for gc in gesture_cmds:
            time_diff = abs((gc["timestamp"] - voice_cmd["timestamp"]).total_seconds())
            if time_diff <= MERGE_WINDOW:
                matched.append(gc)
        return matched

    def _llm_unify(self, voice_cmd: Dict[str, Any], gesture_cmd: Dict[str, Any]) -> str:
        """Use LLM to unify voice and gesture commands"""
        voice_text = voice_cmd["content"]
        gesture_text = gesture_cmd["natural_description"]
        prompt = f"Combine the following inputs into a coherent, context-aware unified command:\nVoice: {voice_text}\nGesture: {gesture_text}\nUnified Command:"
        try:
            result = subprocess.run(
                ["ollama", "run", "deepseek-r1:1.5b-qwen-distill-q4_K_M", prompt],
                capture_output=True,
                text=True,
                check=True,
            )
            if not result.stdout.strip():
                logging.error("Ollama API call returned empty output.")
                return f"Voice: {voice_text} | Gesture: {gesture_text}"
            output = json.loads(result.stdout)
            unified_command = output.get("generated_text", "").strip()
            return (
                unified_command
                if unified_command
                else f"Voice: {voice_text} | Gesture: {gesture_text}"
            )
        except subprocess.CalledProcessError as e:
            logging.error(f"Ollama API call failed: {e}")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"
        except json.JSONDecodeError as e:
            logging.error(f"JSON decoding failed: {e}")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"

    def _create_unified_table(self):
        """Create the unified_commands table if it doesn't exist"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                """CREATE TABLE IF NOT EXISTS unified_commands (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT,
                timestamp DATETIME,
                voice_command TEXT,
                gesture_command TEXT,
                unified_command TEXT
            )"""
            )
            conn.commit()

    def _store_unified(
        self,
        voice_cmd: Dict[str, Any],
        gesture_cmd: Optional[Dict[str, Any]],
        unified: str,
    ):
        """Store the unified command in the database"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                """INSERT INTO unified_commands
                          (session_id, timestamp, voice_command, gesture_command, unified_command)
                          VALUES (?, ?, ?, ?, ?)""",
                (
                    self.session_id,
                    voice_cmd["timestamp"].isoformat(),
                    voice_cmd["content"],
                    gesture_cmd["natural_description"] if gesture_cmd else "",
                    unified,
                ),
            )
            conn.commit()

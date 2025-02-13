import json
import logging
import sqlite3
import subprocess
import time
from datetime import datetime, timedelta
from typing import Dict, List
import uuid

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)

# Time window (in seconds) to consider voice and gesture commands as part of the same interaction
MERGE_WINDOW = 5


def get_voice_commands(db_path: str = "sequences.db") -> List[Dict]:
    """Retrieve all voice commands from the 'instructions' table in sequences.db."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT id, content, timestamp
        FROM instructions
        WHERE modality = 'voice'
    """
    )
    rows = cursor.fetchall()
    conn.close()
    voice_cmds = []
    for row in rows:
        try:
            ts = datetime.fromisoformat(row[2])
        except Exception as e:
            logging.error(f"Error parsing timestamp {row[2]}: {e}")
            continue
        voice_cmds.append({"id": row[0], "content": row[1], "timestamp": ts})
    return voice_cmds


def get_gesture_commands(db_path: str = "commands.db") -> List[Dict]:
    """Retrieve all gesture commands from the 'commands' table in commands.db."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT id, gesture_type, natural_description, timestamp
        FROM commands
    """
    )
    rows = cursor.fetchall()
    conn.close()
    gesture_cmds = []
    for row in rows:
        try:
            ts = datetime.fromisoformat(row[3])
        except Exception as e:
            logging.error(f"Error parsing timestamp {row[3]}: {e}")
            continue
        gesture_cmds.append(
            {
                "id": row[0],
                "gesture_type": row[1],
                "description": row[2],
                "timestamp": ts,
            }
        )
    return gesture_cmds


def create_unified_table(db_path: str = "commands.db") -> None:
    """Create the unified_commands table in commands.db if it doesn't exist."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS unified_commands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT,
            timestamp DATETIME,
            voice_command TEXT,
            gesture_command TEXT,
            unified_command TEXT
        )
    """
    )
    conn.commit()
    conn.close()
    logging.info("Unified commands table created or already exists.")


def store_unified_command(
    session_id: str,
    timestamp: datetime,
    voice_command: str,
    gesture_command: str,
    unified_command: str,
    db_path: str = "commands.db",
) -> None:
    """Store a unified command into the unified_commands table."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO unified_commands (session_id, timestamp, voice_command, gesture_command, unified_command)
        VALUES (?, ?, ?, ?, ?)
    """,
        (
            session_id,
            timestamp.isoformat(),
            voice_command,
            gesture_command,
            unified_command,
        ),
    )
    conn.commit()
    conn.close()
    logging.info(f"Stored unified command: {unified_command}")


def llm_unify(voice_text: str, gesture_text: str) -> str:
    """
    Use Ollama to call the model 'deepseek-r1:1.5b-qwen-distill-q4_K_M' and unify the voice and gesture texts.
    Replace the prompt and parameters as needed.
    """
    prompt = f"Please combine the following inputs into a coherent, context-aware unified command:\nVoice: {voice_text}\nGesture: {gesture_text}\nUnified Command:"
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


def merge_commands(voice_cmd: Dict, gesture_cmd: Dict) -> str:
    """
    Merge a voice command and a gesture command using the LLM unification function.
    """
    return llm_unify(voice_cmd["content"], gesture_cmd["description"])


def synchronize_and_merge(
    voice_db: str = "sequences.db", gesture_db: str = "commands.db"
) -> None:
    """
    Synchronize voice and gesture commands by matching entries with timestamps within a MERGE_WINDOW.
    For each voice command, find any gesture commands that occurred within ±MERGE_WINDOW seconds,
    then merge them using the LLM unification function, and store the unified command.
    """
    voice_cmds = get_voice_commands(voice_db)
    gesture_cmds = get_gesture_commands(gesture_db)
    create_unified_table(gesture_db)

    # Sort commands by timestamp
    voice_cmds.sort(key=lambda x: x["timestamp"])
    gesture_cmds.sort(key=lambda x: x["timestamp"])

    session_id = str(uuid.uuid4())
    for vc in voice_cmds:
        # Find gesture commands within ±MERGE_WINDOW seconds of the voice command timestamp
        matched_gestures = [
            gc
            for gc in gesture_cmds
            if abs((gc["timestamp"] - vc["timestamp"]).total_seconds()) <= MERGE_WINDOW
        ]
        if matched_gestures:
            # Choose the gesture command closest in time
            best_match = min(
                matched_gestures,
                key=lambda gc: abs((gc["timestamp"] - vc["timestamp"]).total_seconds()),
            )
            unified = merge_commands(vc, best_match)
            unified_timestamp = max(vc["timestamp"], best_match["timestamp"])
            store_unified_command(
                session_id,
                unified_timestamp,
                vc["content"],
                best_match["description"],
                unified,
                gesture_db,
            )
        else:
            # If no gesture command is close enough, store just the voice command
            unified = f"Voice: {vc['content']}"
            store_unified_command(
                session_id, vc["timestamp"], vc["content"], "", unified, gesture_db
            )

    logging.info("Synchronization and merging complete.")


if __name__ == "__main__":
    synchronize_and_merge()

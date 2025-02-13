import logging
import sqlite3
import time
from datetime import datetime, timedelta
import uuid

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)



# Configuration: time window for merging (in seconds)
MERGE_WINDOW = 5


def get_voice_commands(db_path: str = "instructions.db") -> list:
    """Retrieve all voice instructions from the voice database."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id, modality, language, instruction_type, content, timestamp FROM instructions"
    )
    rows = cursor.fetchall()
    conn.close()
    voice_cmds = []
    for row in rows:
        voice_cmds.append(
            {
                "id": row[0],
                "modality": row[1],
                "language": row[2],
                "instruction_type": row[3],
                "content": row[4],
                "timestamp": datetime.fromisoformat(row[5]),
            }
        )
    return voice_cmds


def get_gesture_commands(db_path: str = "commands.db") -> list:
    """Retrieve all gesture commands from the gesture database."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id, gesture_type, gesture_text, natural_description, confidence, hand_label, timestamp FROM commands"
    )
    rows = cursor.fetchall()
    conn.close()
    gesture_cmds = []
    for row in rows:
        gesture_cmds.append(
            {
                "id": row[0],
                "gesture_type": row[1],
                "gesture_text": row[2],
                "natural_description": row[3],
                "confidence": row[4],
                "hand_label": row[5],
                "timestamp": datetime.fromisoformat(row[6]),
            }
        )
    return gesture_cmds


def create_unified_table(db_path: str = "commands.db"):
    """Ensure the unified_commands table exists in the gesture database."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
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
    conn.close()
    logging.info("Unified commands table created or already exists.")


def store_unified_command(
    session_id: str,
    timestamp: datetime,
    voice_command: str,
    gesture_command: str,
    unified_command: str,
    db_path: str = "commands.db",
):
    """Store a unified command into the unified_commands table."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """INSERT INTO unified_commands (session_id, timestamp, voice_command, gesture_command, unified_command)
                      VALUES (?, ?, ?, ?, ?)""",
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


def merge_commands(voice_cmd: dict, gesture_cmd: dict) -> str:
    """
    Merge a voice command and a gesture command into a unified command string.
    Here we simply concatenate the texts, but you can use more sophisticated methods (e.g., LLM prompt chaining).
    """
    return (
        f"Voice: {voice_cmd['content']} | Gesture: {gesture_cmd['natural_description']}"
    )


def synchronize_and_merge(
    voice_db: str = "instructions.db", gesture_db: str = "commands.db"
):
    """
    Synchronize voice and gesture commands by matching those whose timestamps are within a MERGE_WINDOW.
    For each voice command, find any gesture commands that occurred within ±MERGE_WINDOW seconds,
    merge them, and store the result.
    """
    voice_cmds = get_voice_commands(voice_db)
    gesture_cmds = get_gesture_commands(gesture_db)
    create_unified_table(gesture_db)

    # Sort both lists by timestamp
    voice_cmds.sort(key=lambda x: x["timestamp"])
    gesture_cmds.sort(key=lambda x: x["timestamp"])

    # For simplicity, iterate over voice commands and try to find a gesture command within the time window.
    session_id = str(uuid.uuid4())
    for vc in voice_cmds:
        # Find gestures within ±MERGE_WINDOW seconds of the voice command timestamp
        matched_gestures = [
            gc
            for gc in gesture_cmds
            if abs((gc["timestamp"] - vc["timestamp"]).total_seconds()) <= MERGE_WINDOW
        ]
        if matched_gestures:
            # For simplicity, choose the one closest in time
            best_match = min(
                matched_gestures,
                key=lambda x: abs((x["timestamp"] - vc["timestamp"]).total_seconds()),
            )
            unified = merge_commands(vc, best_match)
            # Use the later timestamp among the two
            unified_timestamp = max(vc["timestamp"], best_match["timestamp"])
            store_unified_command(
                session_id,
                unified_timestamp,
                vc["content"],
                best_match["natural_description"],
                unified,
                gesture_db,
            )
        else:
            # If no gesture is close enough, store just the voice command
            unified = f"Voice: {vc['content']}"
            store_unified_command(
                session_id, vc["timestamp"], vc["content"], "", unified, gesture_db
            )

    logging.info("Synchronization and merging complete.")


if __name__ == "__main__":
    synchronize_and_merge()

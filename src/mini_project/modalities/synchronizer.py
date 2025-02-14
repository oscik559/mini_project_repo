import json
import logging
import sqlite3
import subprocess
import uuid
from datetime import datetime
from typing import Dict, List

from config.app_config import DB_PATH
from config.logging_config import setup_logging

# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("Synchronizer")

DELIMITER = "\n"


def get_instructions_by_session(db_path: str = DB_PATH) -> Dict[str, List[Dict]]:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT id, session_id, modality, content, timestamp
        FROM instructions
        WHERE modality IN ('voice', 'gesture')
    """
    )
    rows = cursor.fetchall()
    conn.close()
    sessions = {}
    for row in rows:
        try:
            ts = datetime.fromisoformat(row[4])
        except Exception as e:
            logger.error(f"Error parsing timestamp {row[4]}: {e}")
            continue
        record = {
            "id": row[0],
            "session_id": row[1],
            "modality": row[2],
            "content": row[3],
            "timestamp": ts,
        }
        sessions.setdefault(record["session_id"], []).append(record)
    return sessions


def create_unified_table(db_path: str = "sequences.db") -> None:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS unified_instructions (
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
    logger.info("Unified instructions table created or already exists.")


def store_unified_instruction(
    session_id: str,
    timestamp: datetime,
    voice_command: str,
    gesture_command: str,
    unified_command: str,
    db_path: str = "sequences.db",
) -> None:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO unified_instructions (session_id, timestamp, voice_command, gesture_command, unified_command)
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
    logger.info(
        f"Stored unified instruction for session {session_id}: {unified_command}"
    )


# def llm_unify(voice_text: str, gesture_text: str) -> str:
#     prompt = (
#         f"Please combine the following inputs into a coherent, context-aware unified command:\n"
#         f"Voice: {voice_text}\nGesture: {gesture_text}\nUnified Command:"
#     )
#     try:
#         result = subprocess.run(
#             ["ollama", "run", "qwen2:0.5b", prompt],
#             capture_output=True,
#             text=True,
#             check=True,
#             encoding="utf-8",
#         )
#         if not result.stdout.strip():
#             logger.error("Ollama API call returned empty output.")
#             return f"Voice: {voice_text} | Gesture: {gesture_text}"
#         try:
#             output = json.loads(result.stdout)
#             unified_command = output.get("generated_text", "").strip()
#             return (
#                 unified_command
#                 if unified_command
#                 else f"Voice: {voice_text} | Gesture: {gesture_text}"
#             )
#         except json.JSONDecodeError as e:
#             logger.error(f"JSON decoding failed: {e}")
#             return f"Voice: {voice_text} | Gesture: {gesture_text}"
#     except subprocess.CalledProcessError as e:
#         logger.error(f"Ollama API call failed: {e}")
#         return f"Voice: {voice_text} | Gesture: {gesture_text}"


def llm_unify(voice_text: str, gesture_text: str) -> str:
    prompt = (
        "You are a command unifier. Given the voice instruction and the gesture instruction below, "
        "generate a single, clear, and concise command that combines both inputs in a context-aware manner. "
        "The output should be a plain text string with no extra commentary or formatting.\n\n"
        f"Voice Instruction: {voice_text}\n"
        f"Gesture Instruction: {gesture_text}\n\n"
        "Unified Command:"
    )
    try:
        result = subprocess.run(
            ["ollama", "run", "deepseek-r1:1.5b-qwen-distill-q4_K_M", prompt],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8",
        )
        if not result.stdout.strip():
            logger.error("Ollama API call returned empty output.")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"
        try:
            output = json.loads(result.stdout)
            unified_command = output.get("generated_text", "").strip()
            return (
                unified_command
                if unified_command
                else f"Voice: {voice_text} | Gesture: {gesture_text}"
            )
        except json.JSONDecodeError as e:
            logger.error(f"JSON decoding failed: {e}")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"
    except subprocess.CalledProcessError as e:
        logger.error(f"Ollama API call failed: {e}")
        return f"Voice: {voice_text} | Gesture: {gesture_text}"


def merge_session_commands(session_commands: List[Dict]) -> Dict[str, str]:
    session_commands.sort(key=lambda x: x["timestamp"])
    voice_texts = [
        cmd["content"] for cmd in session_commands if cmd["modality"] == "voice"
    ]
    gesture_texts = [
        cmd["content"] for cmd in session_commands if cmd["modality"] == "gesture"
    ]
    merged_voice = DELIMITER.join(voice_texts).strip()
    merged_gesture = DELIMITER.join(gesture_texts).strip()
    return {"voice": merged_voice, "gesture": merged_gesture}


def synchronize_and_unify(db_path: str = "sequences.db") -> None:
    sessions = get_instructions_by_session(db_path)
    create_unified_table(db_path)
    for session_id, records in sessions.items():
        merged = merge_session_commands(records)
        voice_text = merged.get("voice", "")
        gesture_text = merged.get("gesture", "")
        session_timestamp = max(r["timestamp"] for r in records)
        unified_command = llm_unify(voice_text, gesture_text)
        store_unified_instruction(
            session_id,
            session_timestamp,
            voice_text,
            gesture_text,
            unified_command,
            db_path,
        )
    logger.info("Synchronization and unification complete.")


if __name__ == "__main__":
    synchronize_and_unify()

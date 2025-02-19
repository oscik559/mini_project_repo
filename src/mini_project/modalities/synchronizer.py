# modalities/synchronizer.py

import json
import logging
import sqlite3
import subprocess
import uuid
from datetime import datetime
from typing import Dict, List

from config.app_config import DB_PATH, setup_logging

# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("Synchronizer")
DELIMITER = "\n"


def get_instructions_by_session(db_path: str = DB_PATH) -> Dict[str, List[Dict]]:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT
            id,
            session_id,
            modality,
            CASE
                WHEN modality = 'voice' THEN transcribed_text
                WHEN modality = 'gesture' THEN gesture_text
            END AS transcribed_text,
            timestamp
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
            "transcribed_text": row[3],
            "timestamp": ts,
        }
        sessions.setdefault(record["session_id"], []).append(record)
    return sessions


def create_unified_table(db_path: str = DB_PATH) -> None:
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
    db_path: str = DB_PATH,
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


def llm_unify(voice_text: str, gesture_text: str) -> str:
    prompt = (
        "You are a command unifier. Given the voice instruction and the gesture instruction below, "
        "generate a single, clear, and concise command that COMBINES both inputs (voice Instruction and Gesture Instruction) in a context-aware manner. "
        "making sure that the intention is clear and that the output command combines the voice and gesture cue in a meaningful way.\n\n"
        "The output should be a plain text string with no prior explanation of how the final output was got and no extra commentary or formatting.\n\n"
        f"Voice Instruction: {voice_text}\n"
        f"Gesture Instruction: {gesture_text}\n\n"
        "Unified Command:(Voice Instruction + Gesture Instruction)"
    )
    try:
        result = subprocess.run(
            ["ollama", "run", "qwen2:0.5b", prompt],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8",
        )
        output_str = result.stdout.strip()
        if not output_str:
            logger.error("Ollama API call returned empty output.")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"
        try:
            # If the output appears to be JSON, try to parse it
            if output_str.startswith("{"):
                output = json.loads(output_str)
                unified_command = output.get("generated_text", "").strip()
                return (
                    unified_command or f"Voice: {voice_text} | Gesture: {gesture_text}"
                )
            else:
                # Otherwise, assume it's the unified text directly
                return output_str
        except json.JSONDecodeError as e:
            logger.error(f"JSON decoding failed: {e}")
            return f"Voice: {voice_text} | Gesture: {gesture_text}"
    except subprocess.CalledProcessError as e:
        logger.error(f"Ollama API call failed: {e}")
        return f"Voice: {voice_text} | Gesture: {gesture_text}"


def merge_session_commands(session_commands: List[Dict]) -> Dict[str, str]:
    session_commands.sort(key=lambda x: x["timestamp"])
    voice_texts = [
        cmd["transcribed_text"]
        for cmd in session_commands
        if cmd["modality"] == "voice"
    ]
    gesture_texts = [
        cmd["transcribed_text"]
        for cmd in session_commands
        if cmd["modality"] == "gesture"
    ]
    merged_voice = DELIMITER.join(voice_texts).strip()
    merged_gesture = DELIMITER.join(gesture_texts).strip()
    # Add debug logs in synchronize_and_unify()

    return {"voice": merged_voice, "gesture": merged_gesture}


def synchronize_and_unify(db_path: str = DB_PATH) -> None:
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

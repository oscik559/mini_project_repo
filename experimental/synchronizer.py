# modalities/synchronizer.py

import json
import logging
import sqlite3
import subprocess
import uuid
from datetime import datetime
from typing import Dict, List, Optional

from config.app_config import DB_PATH, setup_logging

# Initialize logging with desired level
setup_logging(level=logging.INFO)
logger = logging.getLogger("Synchronizer")
DELIMITER = "\n"


def get_instructions_by_session(db_path: str = DB_PATH) -> Dict[str, List[Dict]]:
    sessions = {}
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        # Get voice instructions, aliasing transcribed_text as instruction_text
        cursor.execute(
            """
            SELECT id, session_id, 'voice' AS modality, transcribed_text AS instruction_text, timestamp
            FROM voice_instructions
            WHERE processed = 0
            """
        )
        voice_rows = cursor.fetchall()
        # Get gesture instructions, aliasing gesture_text as instruction_text
        cursor.execute(
            """
            SELECT id, session_id, 'gesture' AS modality, gesture_text AS instruction_text, timestamp
            FROM gesture_instructions
            WHERE processed = 0
            """
        )
        gesture_rows = cursor.fetchall()

    for row in voice_rows + gesture_rows:
        try:
            ts = datetime.fromisoformat(row[4])
        except Exception as e:
            logger.error(f"Error parsing timestamp {row[4]}: {e}")
            continue
        record = {
            "id": row[0],
            "session_id": row[1],
            "modality": row[2],
            "instruction_text": row[3],
            "timestamp": ts,
        }
        sessions.setdefault(record["session_id"], []).append(record)
    return sessions


def create_unified_table(db_path: str = DB_PATH) -> None:
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS unified_instructions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id TEXT,
                timestamp DATETIME,
                liu_id TEXT,
                voice_command TEXT,
                gesture_command TEXT,
                unified_command TEXT
            )
            """
        )
        conn.commit()
    logger.info("Unified instructions table created or already exists.")


def store_unified_instruction(
    session_id: str,
    timestamp: datetime,
    voice_command: str,
    gesture_command: str,
    unified_command: str,
    liu_id: Optional[str] = None,
    db_path: str = DB_PATH,
) -> None:
    """
    Store a unified instruction into the unified_instructions table.
    If a liu_id is provided, lookup the corresponding user_id from the users table
    and include it.
    """
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO unified_instructions (session_id, timestamp, liu_id, voice_command, gesture_command, unified_command)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                session_id,
                timestamp.isoformat(),
                liu_id,
                voice_command,
                gesture_command,
                unified_command,
            ),
        )
        conn.commit()
    logger.info(
        f"Stored unified instruction for session {session_id}: {unified_command}"
    )


def mark_instructions_as_processed(session_id: str, db_path: str = DB_PATH) -> None:
    """Marks all voice and gesture instructions for the given session as processed."""
    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE voice_instructions SET processed = TRUE WHERE session_id = ? AND processed = 0",
            (session_id,),
        )
        cursor.execute(
            "UPDATE gesture_instructions SET processed = TRUE WHERE session_id = ? AND processed = 0",
            (session_id,),
        )
        conn.commit()
    logger.info(f"Marked instructions as processed for session {session_id}.")


def llm_unify(voice_text: str, gesture_text: str) -> str:
    prompt_template = (
        "Role: Command Unifier. Combine voice commands (primary) with gesture cues (supplementary).\n"
        "Rules:\n"
        "1. Preserve ALL details from the voice command.\n"
        "2. Integrate gestures ONLY if they add context (e.g., direction, emphasis).\n"
        "3. NEVER omit voice content unless the gesture explicitly contradicts it.\n"
        "4. Output format: Plain text, no markdown or JSON.\n\n"
        "Examples:\n"
        "- Voice: 'Turn right', Gesture: 'Pointing up' → 'Turn right upward'\n"
        "- Voice: 'Stop', Gesture: '' → 'Stop'\n\n"
        "Voice Instruction: {voice_text}\n"
        "Gesture Instruction: {gesture_text}\n"
        "Unified Command:"
    )
    formatted_prompt = prompt_template.format(
        voice_text=voice_text, gesture_text=gesture_text
    )
    logger.debug(f"LLM Prompt: {formatted_prompt}")
    try:
        result = subprocess.run(
            ["ollama", "run", "mistral:latest", formatted_prompt],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8",
        )
        output_str = result.stdout.strip()
        if not output_str:
            logger.error("Ollama API call returned empty output.")
            return f"Voice: {voice_text}, Gesture: {gesture_text}"
        try:
            if output_str.startswith("{"):
                output = json.loads(output_str)
                unified_command = output.get("generated_text", "").strip()
                return (
                    unified_command or f"Voice: {voice_text}, Gesture: {gesture_text}"
                )
            else:
                return output_str
        except json.JSONDecodeError as e:
            logger.error(f"JSON decoding failed: {e}")
            return f"Voice: {voice_text}, Gesture: {gesture_text}"
    except subprocess.CalledProcessError as e:
        logger.error(f"Ollama API call failed: {e}")
        return f"Voice: {voice_text}, Gesture: {gesture_text}"


def merge_session_commands(session_commands: List[Dict]) -> Dict[str, str]:
    # Partition records based on modality.
    voice_records = [cmd for cmd in session_commands if cmd["modality"] == "voice"]
    gesture_records = [cmd for cmd in session_commands if cmd["modality"] == "gesture"]

    # Sort both lists by their timestamp.
    voice_records.sort(key=lambda x: x["timestamp"])
    gesture_records.sort(key=lambda x: x["timestamp"])

    # Merge texts using the common alias "instruction_text".
    merged_voice = DELIMITER.join(
        record["instruction_text"] for record in voice_records
    ).strip()
    merged_gesture = DELIMITER.join(
        record["instruction_text"] for record in gesture_records
    ).strip()

    return {"voice": merged_voice, "gesture": merged_gesture}


def synchronize_and_unify(db_path: str = DB_PATH, liu_id: Optional[str] = None) -> None:
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
            liu_id,
            db_path,
        )
        # Mark processed instructions in both voice and gesture tables
        mark_instructions_as_processed(session_id, db_path)

    logger.info("Synchronization and unification complete.")


if __name__ == "__main__":
    synchronize_and_unify()

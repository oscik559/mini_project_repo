# modalities/synchronizer.py


import json
import logging
import sqlite3
import subprocess
import uuid
from datetime import datetime
from functools import lru_cache
from typing import Dict, List, Optional

from config.app_config import (
    DB_PATH,
    LLM_MODEL,
    BATCH_SIZE,
    LLM_MAX_RETRIES,
    UNIFY_PROMPT_TEMPLATE,
    setup_logging,
)
from config.constants import VOICE_TABLE, GESTURE_TABLE, PROCESSED_COL, UNIFIED_TABLE

# Initialize logging with desired level
setup_logging(level=logging.INFO)
logger = logging.getLogger("Synchronizer")
DELIMITER = "\n"


def get_instructions_by_session(
    conn: sqlite3.Connection, limit: int, offset: int
) -> Dict[str, List[Dict]]:
    cursor = conn.cursor()
    """
    Fetches unprocessed instructions from voice and gesture tables in batches.

    Args:
        conn: SQLite database connection object.
        limit: Maximum number of records to fetch.
        offset: Starting offset for batch processing.
    Returns:
        A dictionary mapping session IDs to lists of instruction records.
    """

    sessions = {}
    cursor = conn.cursor()
    query = f"""
        SELECT id, session_id, 'voice' AS modality, transcribed_text AS instruction_text, timestamp
        FROM {VOICE_TABLE} WHERE {PROCESSED_COL} = 0
        UNION ALL
        SELECT id, session_id, 'gesture' AS modality, gesture_text AS instruction_text, timestamp
        FROM {GESTURE_TABLE} WHERE {PROCESSED_COL} = 0
        LIMIT ? OFFSET ?
        """
    cursor.execute(query, (limit, offset))
    rows = cursor.fetchall()

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
            "instruction_text": row[3],
            "timestamp": ts,
        }
        sessions.setdefault(record["session_id"], []).append(record)
    return sessions


def create_unified_table(conn: sqlite3.Connection) -> None:
    """
    Creates the unified_instructions table if it does not exist.

    Args:
        conn: SQLite database connection object.
    """

    cursor = conn.cursor()
    cursor.execute(
        f"""
        CREATE TABLE IF NOT EXISTS {UNIFIED_TABLE} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT,
            timestamp DATETIME,
            liu_id TEXT,
            voice_command TEXT,
            gesture_command TEXT,
            unified_command TEXT,
            processed INTEGER DEFAULT 0
        )
        """
    )
    conn.commit()
    logger.info("Unified instructions table created or already exists.")


def store_unified_instruction(
    conn: sqlite3.Connection,
    session_id: str,
    timestamp: datetime,
    voice_command: str,
    gesture_command: str,
    unified_command: str,
    liu_id: Optional[str] = None,
) -> None:
    """
    Stores a unified instruction into the unified_instructions table.

    Args:
        session_id: The session identifier.
        timestamp: The timestamp of the instruction.
        voice_command: The voice instruction text.
        gesture_command: The gesture instruction text.
        unified_command: The unified command text.
        liu_id: Optional user ID.
        db_path: Path to the SQLite database.
    """
    cursor = conn.cursor()
    cursor.execute(
        f"""
        INSERT INTO {UNIFIED_TABLE} (session_id, timestamp, liu_id, voice_command, gesture_command, unified_command)
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


def mark_instructions_as_processed(conn: sqlite3.Connection, session_id: str) -> None:
    """
    Marks all voice and gesture instructions for the given session as processed.

    Args:
        conn: SQLite database connection object.
        session_id: The session identifier.
    """
    cursor = conn.cursor()
    cursor.execute(
        f"UPDATE {VOICE_TABLE} SET {PROCESSED_COL} = TRUE WHERE session_id = ? AND {PROCESSED_COL} = 0",
        (session_id,),
    )
    cursor.execute(
        f"UPDATE {GESTURE_TABLE} SET {PROCESSED_COL} = TRUE WHERE session_id = ? AND {PROCESSED_COL} = 0",
        (session_id,),
    )
    conn.commit()
    logger.info(f"Marked instructions as processed for session {session_id}.")


@lru_cache(maxsize=128)
def llm_unify(voice_text: str, gesture_text: str, max_retries=LLM_MAX_RETRIES) -> str:
    """
    Combines a voice command with a gesture cue into a unified instruction using an LLM.

    Args:
        voice_text: The primary voice instruction (e.g., "Turn right").
        gesture_text: The supplementary gesture instruction (e.g., "Pointing up").
        max_retries: Number of retry attempts for LLM calls.
    Returns:
        A unified command string, or a fallback if unification fails.
    Example:
        >>> llm_unify("Stop", "Hand raised")
        'Stop with hand raised'
    """
    formatted_prompt = UNIFY_PROMPT_TEMPLATE.format(
        voice_text=voice_text, gesture_text=gesture_text
    )
    for attempt in range(max_retries):
        try:
            result = subprocess.run(
                ["ollama", "run", LLM_MODEL, formatted_prompt],
                capture_output=True,
                text=True,
                check=True,
                encoding="utf-8",
            )
            output = result.stdout.strip()
            if output and len(output) > 3:  # Basic validation
                return output
            logger.warning(f"Attempt {attempt + 1}: Invalid output '{output}'")
        except subprocess.CalledProcessError as e:
            logger.warning(f"Attempt {attempt + 1} failed: {e}")
    logger.error("All LLM attempts failed. Using fallback.")
    return f"Voice: {voice_text}, Gesture: {gesture_text}"


def merge_session_commands(
    session_commands: List[Dict], delimiter: str = DELIMITER
) -> Dict[str, str]:
    """
    Merges instructions from a session into a single string per modality.

    Args:
        session_commands: List of instruction records for a session.
        delimiter: String used to join multiple instructions.
    Returns:
        A dictionary with merged voice and gesture instructions.
    """
    voice_records = [cmd for cmd in session_commands if cmd["modality"] == "voice"]
    gesture_records = [cmd for cmd in session_commands if cmd["modality"] == "gesture"]

    voice_records.sort(key=lambda x: x["timestamp"])
    gesture_records.sort(key=lambda x: x["timestamp"])

    merged_voice = delimiter.join(
        record["instruction_text"] for record in voice_records
    ).strip()
    merged_gesture = delimiter.join(
        record["instruction_text"] for record in gesture_records
    ).strip()

    return {"voice": merged_voice, "gesture": merged_gesture}


def synchronize_and_unify(
    db_path: str = DB_PATH, liu_id: Optional[str] = None, batch_size: int = BATCH_SIZE
) -> None:
    """
    Synchronizes and unifies voice and gesture instructions in batches.

    Args:
        db_path: Path to the SQLite database.
        liu_id: Optional user ID.
        batch_size: Number of records to process per batch.
    """
    offset = 0
    with sqlite3.connect(str(db_path)) as conn:
        while True:
            sessions = get_instructions_by_session(
                conn, limit=batch_size, offset=offset
            )
            if not sessions:
                logger.info("No more unprocessed instructions found.")
                break

            create_unified_table(conn)
            for session_id, records in sessions.items():
                merged = merge_session_commands(records)
                voice_text = merged.get("voice", "")
                gesture_text = merged.get("gesture", "")
                session_timestamp = max(r["timestamp"] for r in records)
                unified_command = llm_unify(voice_text, gesture_text)
                store_unified_instruction(
                    conn,
                    session_id,
                    session_timestamp,
                    voice_text,
                    gesture_text,
                    unified_command,
                    liu_id,
                )
                mark_instructions_as_processed(conn, session_id)
            offset += batch_size
            logger.info(f"Processed batch of {batch_size} records. Offset: {offset}")
    logger.info("Synchronization and unification complete.")


if __name__ == "__main__":
    synchronize_and_unify()

# mini_project/modalities/synchronizer.py
"""synchronizer.py
This module provides functionality to synchronize and unify multimodal instructions (voice and gesture)
from a database, merging them into unified commands using a Large Language Model (LLM). It processes
unprocessed instructions in batches, merges them per session, and stores the unified result in a dedicated table.
Main Functions:
---------------
- get_instructions_by_session(cursor, limit, offset): Fetches unprocessed voice and gesture instructions from the database, grouped by session.
- store_unified_instruction(cursor, session_id, timestamp, voice_command, gesture_command, unified_command, liu_id): Stores a unified instruction into the unified_instructions table.
- mark_instructions_as_processed(cursor, session_id): Marks all instructions for a session as processed.
- llm_unify(voice_text, gesture_text, max_retries): Uses an LLM to combine voice and gesture instructions into a unified command.
- merge_session_commands(session_commands, delimiter): Merges all instructions of a session into single strings per modality.
- synchronize_and_unify(liu_id, batch_size): Orchestrates the synchronization and unification process in batches.
Usage:
------
Run this module as a script to process and unify all unprocessed instructions in the database.
Dependencies:
-------------
- Database connection and configuration modules
- Logging
- Subprocess (for LLM calls)
- Python standard libraries (datetime, functools, typing)
"""

import json
import logging

# import sqlite3
import subprocess
import uuid
from datetime import datetime
from functools import lru_cache
from typing import Dict, List, Optional

from config.app_config import (  # DB_PATH,
    BATCH_SIZE,
    LLM_MAX_RETRIES,
    LLM_MODEL,
    UNIFY_PROMPT_TEMPLATE,
    setup_logging,
)
from config.constants import GESTURE_TABLE, PROCESSED_COL, UNIFIED_TABLE, VOICE_TABLE

from mini_project.database.connection import get_connection

# Initialize logging with desired level
setup_logging(level=logging.INFO)
logger = logging.getLogger("Synchronizer")
DELIMITER = "\n"


def get_instructions_by_session(
    cursor, limit: int, offset: int
) -> Dict[str, List[Dict]]:
    """
    Fetches unprocessed instructions from voice and gesture tables in batches.

    Args:
        conn: SQLite database connection object.
        limit: Maximum number of records to fetch.
        offset: Starting offset for batch processing.
    Returns:
        A dictionary mapping session IDs to lists of instruction records.
    """
    query = f"""
        SELECT id, session_id, 'voice' AS modality, transcribed_text AS instruction_text, timestamp
        FROM {VOICE_TABLE} WHERE {PROCESSED_COL} = FALSE
        UNION ALL
        SELECT id, session_id, 'gesture' AS modality, gesture_text AS instruction_text, timestamp
        FROM {GESTURE_TABLE} WHERE {PROCESSED_COL} = FALSE
        ORDER BY timestamp ASC
        LIMIT %s OFFSET %s
    """
    cursor.execute(query, (limit, offset))
    rows = cursor.fetchall()
    sessions = {}

    for row in rows:
        ts = row[4] if isinstance(row[4], datetime) else datetime.fromisoformat(row[4])
        record = {
            "id": row[0],
            "session_id": row[1],
            "modality": row[2],
            "instruction_text": row[3],
            "timestamp": ts,
        }
        sessions.setdefault(record["session_id"], []).append(record)
    return sessions


def store_unified_instruction(
    cursor,
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
    cursor.execute(
        f"""
        INSERT INTO {UNIFIED_TABLE} (session_id, timestamp, liu_id, voice_command, gesture_command, unified_command)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (
            session_id,
            timestamp,
            liu_id,
            voice_command,
            gesture_command,
            unified_command,
        ),
    )
    logger.info(
        f"Stored unified instruction for session {session_id}: {unified_command}"
    )


def mark_instructions_as_processed(cursor, session_id: str) -> None:
    """
    Marks all voice and gesture instructions for the given session as processed.

    Args:
        conn: SQLite database connection object.
        session_id: The session identifier.
    """
    cursor.execute(
        f"UPDATE {VOICE_TABLE} SET {PROCESSED_COL} = TRUE WHERE session_id = %s AND {PROCESSED_COL} = FALSE",
        (session_id,),
    )
    cursor.execute(
        f"UPDATE {GESTURE_TABLE} SET {PROCESSED_COL} = TRUE WHERE session_id = %s AND {PROCESSED_COL} = FALSE",
        (session_id,),
    )
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
            if output and len(output) > 3:
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
    liu_id: Optional[str] = None, batch_size: int = BATCH_SIZE
) -> None:
    """
    Synchronizes and unifies voice and gesture instructions in batches.

    Args:
        db_path: Path to the SQLite database.
        liu_id: Optional user ID.
        batch_size: Number of records to process per batch.
    """
    offset = 0
    try:
        conn = get_connection()
    except Exception as e:
        logger.error(f"❌ Failed to connect to PostgreSQL: {e}")
        raise
    with conn:
        cursor = conn.cursor()
        while True:
            sessions = get_instructions_by_session(
                cursor, limit=batch_size, offset=offset
            )
            if not sessions:
                logger.info("No more unprocessed instructions found.")
                break

            for session_id, records in sessions.items():
                merged = merge_session_commands(records)
                voice_text = merged.get("voice", "")
                gesture_text = merged.get("gesture", "")
                session_timestamp = max(r["timestamp"] for r in records)
                unified_command = llm_unify(voice_text, gesture_text)
                store_unified_instruction(
                    cursor,
                    session_id,
                    session_timestamp,
                    voice_text,
                    gesture_text,
                    unified_command,
                    liu_id,
                )
                mark_instructions_as_processed(cursor, session_id)
            offset += batch_size
            logger.info(f"Processed batch of {batch_size} records. Offset: {offset}")
    conn.commit()
    logger.info("Synchronization and unification complete.")


if __name__ == "__main__":
    synchronize_and_unify()

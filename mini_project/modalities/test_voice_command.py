# voice_command_runner.py

import logging
import time
from datetime import datetime
from typing import Dict, List

from mini_project.database.connection import get_connection
from mini_project.modalities.command_processor_pgSQL import CommandProcessor
from mini_project.modalities.voice_processor_pgSQL import (
    SpeechSynthesizer,
    VoiceProcessor,
)

logger = logging.getLogger("VoiceCommandRunner")


def insert_unified_instruction(
    text: str, liu_id="oscik559", session_id="session_voice_001"
) -> int:
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        INSERT INTO unified_instructions (
            session_id, timestamp, liu_id,
            voice_command, gesture_command, unified_command,
            confidence, processed
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING id;
        """,
        (
            session_id,
            datetime.now(),
            liu_id,
            text,
            "",
            text,
            0.95,
            False,
        ),
    )
    inserted_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return inserted_id


def main():
    tts = SpeechSynthesizer()
    tts.speak("Good morning!. Can you give me a second to load up?")

    vp = VoiceProcessor()
    vp.capture_voice()

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT transcribed_text FROM voice_instructions ORDER BY id DESC LIMIT 1"
    )
    row = cursor.fetchone()
    if not row:
        tts.speak("Sorry, I didn't hear anything.")
        return
    command_text = row[0]
    if is_scene_query(command_text):
        from mini_project.modalities.llm_scene_query import query_scene

        answer = query_scene(command_text)
        tts.speak(f"Based on the scene, {answer}")
        return

    logger.info(f"Transcribed voice command: {command_text}")

    # Insert into unified_instructions
    command_id = insert_unified_instruction(command_text)
    logger.info(f"Inserted command ID: {command_id}")

    # Clear previous operation_sequence entries
    cursor.execute("DELETE FROM operation_sequence")
    conn.commit()
    cursor.close()
    conn.close()

    # Process using LLM
    processor = CommandProcessor()
    success, _ = processor.process_command(
        {"id": command_id, "unified_command": command_text}
    )
    if success:
        tts.speak("The task has been planned and added successfully.")
    else:
        tts.speak("Sorry, I couldn't understand the task.")
    processor.close()


def is_scene_query(command_text: str) -> bool:
    lowered = command_text.lower()
    return any(
        lowered.startswith(w) for w in ["what", "where", "which", "who", "how many"]
    )


if __name__ == "__main__":
    from config.app_config import setup_logging

    setup_logging()
    main()

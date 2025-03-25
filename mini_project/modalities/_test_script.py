# [2025-03-24 18:19:07] INFO - VoiceProcessor - 🚀 Starting voice capture process...
# [2025-03-24 18:19:07] INFO - VoiceProcessor - 🔈 Calibrating ambient noise...
# [2025-03-24 18:19:09] INFO - VoiceProcessor - ✅ Ambient noise calibration complete. Noise floor: 7.41
# [2025-03-24 18:19:09] INFO - VoiceProcessor - 🎚️ Amplitude threshold set to: 107.41 (Noise floor: 7.41 + Margin: 100)
# [2025-03-24 18:19:11] INFO - VoiceProcessor - 🗣️ Voice recording: Please speak now...
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 🎤 Recording completed. Duration: 6.37 seconds
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 💾 Audio saved to C:\Users\oscik559\Projects\mini_project_repo\assets\temp_audio\voice_recording.wav
# [2025-03-24 18:19:19] INFO - VoiceProcessor - 📥 Audio recording completed. Starting transcription...
# [2025-03-24 18:19:19] INFO - faster_whisper - 🧠 Processing audio with duration 00:06.330
# [2025-03-24 18:19:19] INFO - faster_whisper - 🌐 Detected language 'en' with probability 0.56
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 📝 Transcription completed. Detected language: English
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 🗃️ Storing voice instruction in the database...
# [2025-03-24 18:19:20] INFO - VoiceProcessor - ✅ Voice instruction stored successfully in voice_instructions table.
# [2025-03-24 18:19:20] INFO - VoiceProcessor - 🎉 Voice instruction captured and stored successfully!


import os
import psycopg2
from dotenv import load_dotenv
from datetime import datetime

# Load environment variables
load_dotenv()

# Connect using your .env DATABASE_URL
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise EnvironmentError("DATABASE_URL not set in .env")

conn = psycopg2.connect(DATABASE_URL)
cursor = conn.cursor()

# Sample command
liu_id = "oscik559"  # this must match a user in your users table
session_id = "session_test_001"
timestamp = datetime.now()
voice_command = "Sort the slides in order of pink, green and then orange. Now, redo the sorting of the slides in reverse order."
gesture_command = ""
unified_command = voice_command
confidence = 0.95
processed = False

insert_query = """
INSERT INTO unified_instructions (
    session_id, timestamp, liu_id,
    voice_command, gesture_command, unified_command,
    confidence, processed
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
"""

cursor.execute(
    insert_query,
    (
        session_id,
        timestamp,
        liu_id,
        voice_command,
        gesture_command,
        unified_command,
        confidence,
        processed,
    ),
)

conn.commit()
print("✅ Unified command inserted for processing.")
cursor.close()
conn.close()

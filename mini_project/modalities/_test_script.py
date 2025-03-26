import os
from datetime import datetime

import psycopg2
from dotenv import load_dotenv

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
voice_command = "Sort the slides in order of pink, green and then orange."
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

# Align timestamps of gestures and voice commands.


# Synchronization & Database
# database.py
import sqlite3
from datetime import datetime

class CommandDatabase:
    def __init__(self, db_path):
        self.conn = sqlite3.connect(db_path)
        self._create_table()

    def _create_table(self):
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS commands (
                id INTEGER PRIMARY KEY,
                timestamp DATETIME,
                speech_text TEXT,
                gesture_text TEXT,
                merged_command TEXT,
                structured_command JSON
            )
        """)

    def log_command(self, speech_text, gesture_text):
        timestamp = datetime.now().isoformat()
        self.conn.execute("""
            INSERT INTO commands (timestamp, speech_text, gesture_text)
            VALUES (?, ?, ?)
        """, (timestamp, speech_text, gesture_text))
        self.conn.commit()




#  LLM Unification Module
        # llm_processor.py
from transformers import pipeline
import json

class CommandUnifier:
    def __init__(self, model_name="mistralai/Mistral-7B-v0.1"):
        self.pipe = pipeline("text-generation", model=model_name)

    def unify_commands(self, speech_text, gesture_text) -> dict:
        prompt = f"""
        Merge the verbal command "{speech_text}" and gesture "{gesture_text}" into a robot command JSON.
        Output format: {{"action": "", "params": {{}}}}
        """
        response = self.pipe(prompt, max_length=200)[0]["generated_text"]
        return json.loads(response)
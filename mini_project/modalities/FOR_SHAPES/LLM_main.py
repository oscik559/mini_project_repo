import datetime
import logging
import os
import random
import tempfile
import time
import uuid
from datetime import datetime

# from prompt_utils import PromptBuilder
import ollama
import pyttsx3
from gtts import gTTS
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnableLambda, RunnableSequence
from langchain_ollama import ChatOllama

from config.app_config import setup_logging
from mini_project.database.connection import get_connection
from mini_project.modalities.FOR_SHAPES.command_processor_pgSQL import CommandProcessor
from mini_project.modalities.FOR_SHAPES.voice_processor_pgSQL import (
    SpeechSynthesizer,
    VoiceProcessor,
)
from mini_project.modalities.prompt_utils import PromptBuilder

# === Logging Config ===
logging.getLogger("comtypes").setLevel(logging.WARNING)
logger = logging.getLogger("LLMSceneHybrid")

# === Configuration ===
# OLLAMA_MODEL = "mistral:latest"
OLLAMA_MODEL = "llama3.2:latest"
voice_speed = 165
use_gtts = True

# === LangChain Setup ===
llm = ChatOllama(model=OLLAMA_MODEL)
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")

SCENE_PROMPT_TEMPLATE = """
You are an intelligent robotic assistant, with the camera as your eye. Based on the objects in the scene, listed in a camera_vision database table, respond concisely and clearly to the user question. One line answers are acceptable.
if there are any, the objects here are sitting on a table. Do not assume objects unless they are listed.
---
Each object has the following fields:
# - object_name: the name of the object in the scene. It could be a slide, a holder, or a tray, a 3D shape etc. slides object_name are usually Slide 1, Slide 2, etc. and have a usd_name of slide.usd
# - object_color: the color of the object in the scene
# - pos_x, pos_y, pos_z: the 3D position of the object in the scene relative to table (0,0). You can use the object position to imagine the relative distances of the objects from each other
# - rot_x, rot_y, rot_z: the orientation of the object in the scene

---
if the object is a slide, it will have a usd_name of slide.usd, and the holder object will have a usd_name of holder.usd
any objects with object_name that does not start with \"slide...\" are not slides
---

dont use non-words like rot_x, pos_y, etc. in your answer. use the full words like position x, rotation y, etc.
do not output positions or orientation values unless specifically asked for that
---
Previous conversation:
{chat_history}

User question: {question}
Objects in scene:
{data}
---
Answer:
"""

prompt = PromptTemplate.from_template(SCENE_PROMPT_TEMPLATE)
# chain = LLMChain(llm=llm, prompt=prompt, memory=memory)
chain = LLMChain(llm=llm, prompt=prompt, memory=memory)


# === Fetch and Format Camera Data ===
def fetch_camera_objects() -> list:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT object_name, object_color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, last_detected, usd_name
        FROM camera_vision
        """
    )
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


def format_camera_data(objects: list) -> str:
    return "\n".join(
        f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f}) last seen at {timestamp}, usd_name: {usd}"
        for name, color, x, y, z, r, p, w, timestamp, usd in objects
    )


# === Scene Query ===
def query_scene(question: str) -> str:
    try:
        objects = fetch_camera_objects()
        if not objects:
            return "The scene appears to be empty. No objects are currently visible."
        formatted_data = format_camera_data(objects)
        response = chain.invoke({"question": question, "data": formatted_data})
        return response.get("text", str(response))
    except Exception as e:
        logging.error(f"Scene query failed: {e}")
        return "[Scene query failed.]"


# === Task Processing ===
def process_task(command_text: str) -> str:
    try:
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
                "session_voice_001",
                datetime.now(),
                "oscik559",
                command_text,
                "",
                command_text,
                0.95,
                False,
            ),
        )
        command_id = cursor.fetchone()[0]
        conn.commit()
        cursor.execute("DELETE FROM operation_sequence")
        conn.commit()
        cursor.close()
        conn.close()

        processor = CommandProcessor()
        success, _ = processor.process_command(
            {"id": command_id, "unified_command": command_text}
        )
        processor.close()

        return (
            "The task has been planned and added successfully."
            if success
            else "Sorry, I couldn't understand the task."
        )
    except Exception as e:
        logging.error(f"Task processing failed: {e}")
        return "[Task execution failed.]"


def is_scene_query(command_text: str) -> bool:
    try:
        classification_prompt = """
        Classify the following user command as either:
        - 'scene' if it is a question about the current camera scene (e.g., object positions, colors, etc.)
        - 'task' if it is a command to take action (e.g., sort, move, place, etc.)
        Just return one word: either 'scene' or 'task'.

        Command: {command}
        Answer:
        """
        classification_chain = LLMChain(
            llm=llm, prompt=PromptTemplate.from_template(classification_prompt)
        )
        result = classification_chain.invoke({"command": command_text})
        classification = result.get("text", "").strip().lower()
        logger.info(
            f"LLM classified input as: '{classification}' for command: '{command_text}'"
        )
        return classification == "scene"
    except Exception as e:
        logging.warning(f"LLM classification fallback to rule-based: {e}")
        lowered = command_text.lower()
        return any(
            lowered.startswith(w) for w in ["what", "where", "which", "who", "how many"]
        )


# === Simple LLM Greeting ===
def generate_llm_greeting() -> str:

    now = datetime.datetime.now()
    weekday = now.strftime("%A")
    month = now.strftime("%B")
    hour = now.hour

    if hour < 12:
        time_of_day = "morning"
    elif hour < 18:
        time_of_day = "afternoon"
    else:
        time_of_day = "evening"

    base_greetings = [
        f"Good {time_of_day}! Happy {weekday}.",
        f"Hope you're having a great {weekday}!",
        f"Hello and welcome this fine {time_of_day}.",
        f"It's {month} already! Let's get started.",
        f"Hi! What’s the first thing you'd like me to do this {time_of_day}?",
    ]

    try:
        seasonal_greeting = random.choice(base_greetings)
        prompt = f"""
        You're a friendly assistant robot, Yumi.

        It's {time_of_day} on a {weekday} in {month}.

        Say a very short, warm, and creative greeting (just 1 sentence), suitable for voice.
        Use this seed greeting: '{seasonal_greeting}'
        Just one sentence, please. Avoid long phrases or explanations. Dont add quote
        """

        response = ollama.chat(
            model=OLLAMA_MODEL,
            messages=[
                PromptBuilder.greeting_system_msg(),
                {"role": "user", "content": prompt},
            ],
        )
        print(response)
        return response["message"]["content"].strip().strip('"“”')
    except Exception as e:
        logger.error(f"Greeting failed: {e}")
        seed = random.choice(base_greetings)
        return fallback_llm_greeting(seed)


# Fallback LLM greeting
def fallback_llm_greeting(seed_greeting: str) -> str:
    try:
        response = ollama.chat(
            model=OLLAMA_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": "You are a friendly assistant that creates warm spoken greetings.",
                },
                {
                    "role": "user",
                    "content": f"Improve this fallback greeting for voice use: '{seed_greeting}'",
                },
            ],
        )
        return response["message"]["content"].strip().strip('"“”')
    except Exception:
        return seed_greeting


# === Voice Interaction ===
def voice_to_scene_response(
    vp: VoiceProcessor, tts: SpeechSynthesizer, conversational: bool = True
):
    print("🟠 Speak your request (scene question or task)...")

    result = vp.capture_voice(conversational=conversational)
    if result is None:
        print("⚠️ No speech detected. Try again.")
        return

    question, lang = result
    print(f"You said: {question}")

    # conn = get_connection()
    # cursor = conn.cursor()
    # cursor.execute(
    #     "SELECT transcribed_text FROM voice_instructions ORDER BY id DESC LIMIT 1"
    # )
    # row = cursor.fetchone()
    # cursor.close()
    # conn.close()

    # if not row:
    #     print("⚠️ No speech detected. Try again.")
    #     return

    # vp.recorder.record_audio()

    # if not vp.recorder.speech_detected:
    #     print("⚠️ No speech detected. Try again.")
    #     return

    # print("🧠 Transcribing...")
    # question, lang = vp.transcriber.transcribe_audio(vp.recorder.temp_audio_path)

    # question = row[0].strip()
    # print(f"You said: {question}")

    if question.lower() in {"exit", "quit", "goodbye", "stop"}:
        tts.speak("Okay, goodbye!")
        exit(0)
    if question.lower() in {"reset memory", "clear memory"}:
        memory.clear()
        tts.speak("Memory has been reset.")
        return

    print("🤖 Thinking...")

    if is_scene_query(question):
        answer = query_scene(question)
        print("🤖 (Scene Response):", answer)
    else:
        # Only now store it in the database
        vp.storage.store_instruction(vp.session_id, lang, question)

        answer = process_task(question)
        print("🤖 (Task Response):", answer)

    print("🔊 Speaking response...")
    tts.speak(answer)
    tts.play_ding()


# === CLI Entry Point ===
if __name__ == "__main__":
    setup_logging()
    vp = VoiceProcessor()
    # vp.capture_voice()
    tts = SpeechSynthesizer()

    if not hasattr(voice_to_scene_response, "greeted"):
        greeting = generate_llm_greeting()
        tts.speak(greeting)
        voice_to_scene_response.greeted = True

    first_turn = True

    while True:
        voice_to_scene_response(vp, tts, conversational=not first_turn)
        first_turn = False
        print("🟡 Listening again in a few seconds... (Ctrl+C to stop)")
        time.sleep(2)

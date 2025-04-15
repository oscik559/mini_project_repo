import logging
import os
import random
import re
import string
import time
import uuid
import warnings
from datetime import datetime
from typing import Literal
from langchain.schema import messages_from_dict, messages_to_dict
import json
import ollama
import pyttsx3
import requests
from gtts import gTTS
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain_core._api.deprecation import LangChainDeprecationWarning
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnableLambda, RunnableSequence
from langchain_ollama import ChatOllama

from config.app_config import setup_logging, BASE_DIR
from mini_project.database.connection import get_connection
from mini_project.modalities.FOR_SHAPES.command_processor_pgSQL import CommandProcessor
from mini_project.modalities.FOR_SHAPES.voice_processor_pgSQL import (
    SpeechSynthesizer,
    VoiceProcessor,
)
from mini_project.modalities.prompt_utils import PromptBuilder
import json
from pathlib import Path

import pvporcupine
import sounddevice as sd
import struct
import threading


# ========== Wake Word Setup ==========
ACCESS_KEY = "E0O2AD01eT6cJ83n1yYf5bekfdIOEGUky9q6APkwdx9enDaMLZQtLw=="
WAKEWORD = (
    r"C:\Users\oscik559\Projects\mini_project_repo\assets\robot_wakewords\hey_yummy.ppn"
)
WAKE_RESPONSES = [
    "Yes?",
    "I'm listening...",
    "What's up?",
    "Go ahead.",
    "At your service.",
    "Hello?" "what do you need?",
    "Ready for your command",
    "I'm here!",
    "Yes, how can I help?",
    "You called?",
    "Yes, I'm here.",
    "Yes, what do you need?",
    "Yes, I'm listening.",
    "Yes, how can I assist you?",
    "Yes, how can I help?",
    "Yes, what can I do for you?",
    "Yes, what do you want?",
    "Yes, what can I do for you?",
    "Yes, what do you need?",
]
# Use built-in or custom model path
porcupine = pvporcupine.create(
    access_key=ACCESS_KEY,
    keywords=[
        "computer",  # Built-in wake word
    ],
    keyword_paths=[WAKEWORD],
)
wake_word_triggered = threading.Event()

import random


# =====================================


CHAT_MEMORY_PATH = Path("chat_memory.json")
# CHAT_MEMORY_PATH = BASE_DIR / "assets" / "chat_memory" / "chat_memory.json"

warnings.filterwarnings("ignore", category=LangChainDeprecationWarning)


# === Logging Config ===
logging.getLogger("comtypes").setLevel(logging.WARNING)
logging.getLogger("faster_whisper").setLevel(logging.WARNING)
logger = logging.getLogger("VoiceAssistant")

# === Configuration ===
OLLAMA_MODEL = "llama3.2:latest"
voice_speed = 180  # 165

TASK_VERBS = {
    "sort",
    "move",
    "place",
    "assemble",
    "pick",
    "drop",
    "grab",
    "stack",
    "push",
    "pull",
}
QUESTION_WORDS = {
    "what",
    "where",
    "which",
    "who",
    "how many",
    "is there",
    "are there",
}
CONFIRM_WORDS = {
    "yes",
    "sure",
    "okay",
    "go ahead",
    "absolutely",
    "yep",
    "definitely",
    "please do",
}
CANCEL_WORDS = {"no", "cancel", "not now", "stop", "never mind", "don't"}
# ==========================ADD MORE

SCENE_PROMPT_TEMPLATE = """
You are an intelligent robotic assistant, with the camera as your eye. Based on the objects in the scene, listed in a camera_vision database table, respond concisely and clearly to the user question. One line answers are acceptable.
if there are any, the objects here are sitting on a table. Do not assume objects unless they are listed.
---
Each object has the following fields:
# - object_name: the name of the object in the scene.
# - object_color: the color of the object in the scene
# - pos_x, pos_y, pos_z: the 3D position of the object in the scene relative to table (0,0). You can use the object position to imagine the relative distances of the objects from each other
# - rot_x, rot_y, rot_z: the orientation of the object in the scene

---
if the object is a slide, it will have a usd_name of slide.usd, and the holder object will have a usd_name of holder.usd
any objects with object_name that does not start with \"slide...\" are not slides
---

Avoid technical terms like rot_x or pos_y. Instead, describe in natural language (e.g., "position x", "rotation y").
Assume the pos_x, pos_y, pos_z are coordinates of the objects on the table with respect to a 0,0,0 3D cordinate which is thereference ( the far right edge of the table top rectangle). the values are tenth of an mm unit.
---
Previous conversation:
{chat_history}

User question: {question}
Objects in scene:
{data}
---
Answer:
"""


# === LangChain Setup ===
llm = ChatOllama(model=OLLAMA_MODEL)
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")
prompt = PromptTemplate.from_template(SCENE_PROMPT_TEMPLATE)


# Helper to load chat history into the prompt input
def load_memory(inputs: dict) -> dict:
    chat_history = memory.load_memory_variables({})["chat_history"]
    return {**inputs, "chat_history": chat_history}


# Save original input for memory context
def build_chain_with_input(input_data):
    return (
        RunnableLambda(load_memory)
        | prompt
        | llm
        | RunnableLambda(lambda output: save_memory_with_input(input_data, output))
    )


# Save memory context
def save_memory_with_input(original_input, output):
    memory.save_context(
        {"question": original_input["question"]},
        {"answer": output.content},
    )

    return output


chain = (
    {
        # "input": RunnableLambda(load_memory),
        "original_input": lambda x: x,  # pass-through original input
    }
    | RunnableLambda(lambda d: d["input"])  # continue with prompt | llm
    | prompt
    | llm
    | RunnableLambda(
        lambda output, inputs: {"input": inputs["original_input"], "output": output}
    )
    | RunnableLambda(save_memory_with_input)
)


# === Command Classification ===
def classify_command(command_text: str, llm) -> Literal["scene", "task"]:
    lowered = command_text.lower().strip()

    # # === Try LLM-based classification ===
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
        if classification in {"scene", "task"}:
            return classification
    except Exception as e:
        print(f"[⚠️] LLM failed, using rule-based fallback: {e}")

    # === Rule-based fallback ===
    if any(lowered.startswith(q) for q in QUESTION_WORDS):
        return "scene"

    if re.search(r"\b(is|are|how many|what|which|where|who)\b", lowered):
        return "scene"

    if any(verb in lowered for verb in TASK_VERBS):
        return "task"

    return "task"


# === Persistent Chat Memory ===
def save_chat_history():
    try:
        serialized = messages_to_dict(memory.chat_memory.messages)
        with open(CHAT_MEMORY_PATH, "w", encoding="utf-8") as f:
            json.dump(serialized, f, indent=2)
        logger.info("💾 Chat history saved.")
    except Exception as e:
        logger.error(f"Failed to save chat memory: {e}")


def load_chat_history():
    if CHAT_MEMORY_PATH.exists():
        try:
            with open(CHAT_MEMORY_PATH, "r", encoding="utf-8") as f:
                raw_messages = json.load(f)
            memory.chat_memory.messages = messages_from_dict(raw_messages)
            logger.info("🧠 Loaded past chat history.")
        except Exception as e:
            logger.warning(f"Could not load chat memory: {e}")


# === Scene Description ===
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
            return "I can only see the camera. No other objects are currently visible."
        formatted_data = format_camera_data(objects)
        input_data = {"question": question, "data": formatted_data}
        response = build_chain_with_input(input_data).invoke(input_data)

        return response.content
    except Exception as e:
        logger.error("Scene query failed", exc_info=True)
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


# === Simple LLM Greeting ===
def get_weather_description(latitude=58.41, longitude=15.62) -> str:
    try:
        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        data = response.json()
        weather = data["current_weather"]
        temperature = round(weather["temperature"])
        description = f"{temperature}°C, wind {weather['windspeed']} km/h"
        return description
    except Exception as e:
        print(f"Weather fetch failed: {e}")
        return "mysterious skies"


# ========== Wake Word Listener ==========
def listen_for_wake_word(vp, tts):
    def callback(indata, frames, time, status):
        try:
            pcm = struct.unpack_from("h" * porcupine.frame_length, bytes(indata))
            keyword_index = porcupine.process(pcm)
            if keyword_index >= 0:
                logger.info("🟢 Wake word detected!")
                wake_word_triggered.set()  # ✅ Set flag
        except Exception as e:
            logger.warning(f"Wake word callback error: {e}")

    with sd.RawInputStream(
        samplerate=porcupine.sample_rate,
        blocksize=porcupine.frame_length,
        dtype="int16",
        channels=1,
        callback=callback,
    ):
        logger.info("🎙️  Passive listening for wake word...")
        while not wake_word_triggered.is_set():
            sd.sleep(100)  # non-blocking wait


# === Greeting ===
def generate_llm_greeting():
    now = datetime.now()
    weekday = now.strftime("%A")
    month = now.strftime("%B")
    hour = now.hour
    time_of_day = "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"

    base_greetings = [
        f"Good {time_of_day}! Happy {weekday}.",
        f"Hope you're having a great {weekday}!",
        f"Hello and welcome this fine {time_of_day}.",
        f"It's {month} already! Let's get started.",
        f"Hi! What’s the first thing you'd like me to do this {time_of_day}?",
    ]
    seed = random.choice(base_greetings)

    try:
        prompt = f"""
        You're Yumi, a clever and friendly assistant robot in a research lab at the Product Realization division of Linköping University.
        It's {time_of_day} on a {weekday} in {month}.
        Say one short and creative sentence (under 20 words) suitable for voice use —
        a fun robotics fact, quirky comment, or a science-themed greeting.
        Inspiration: '{seed}' — but do not repeat it.
        """
        response = llm.invoke(
            [
                PromptBuilder.greeting_system_msg(),
                {"role": "user", "content": prompt},
            ]
        )
        logger.info(f"📢 {response.content}")
        return response.content.strip().strip('"“”') or seed
    except Exception as e:
        logger.error(f"Greeting failed: {e}")
        return fallback_llm_greeting(seed)


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
    # logger.info(f"🟠 Speak your request (scene question or task)...")

    result = vp.capture_voice(conversational=conversational)
    if result is None:
        logger.info(f"🟡 No speech detected. Try again.")
        tts.speak("I didn't catch that. Could you please repeat?")
        return

    request, lang = result
    logger.info(f"🎯 You said: {request}")

    cmd_type = classify_command(request, llm)
    logger.info(f"🧠 Command classified as: {cmd_type}")

    if request.lower() in {"exit", "quit", "goodbye", "stop"}:
        tts.speak("Okay, goodbye!")
        exit(0)
    if request.lower() in {"reset memory", "clear memory"}:
        memory.clear()
        CHAT_MEMORY_PATH.unlink(missing_ok=True)

        tts.speak("Memory has been reset.")
        return

    logger.info(f"🤖 Thinking...")

    if cmd_type == "scene":
        answer = query_scene(request)
        logger.info(f"🤖 (Scene Response): {answer}")
    else:
        # Confirm before executing
        tts.speak("Should I plan this task?")
        confirm_result = vp.capture_voice()
        if confirm_result is None:
            tts.speak("No confirmation heard. Skipping the task.")
            return

        confirmation, _ = confirm_result
        # Clean and normalize response
        cleaned = confirmation.lower().translate(
            str.maketrans("", "", string.punctuation)
        )
        # Match negative intent first
        if any(word in cleaned for word in CANCEL_WORDS):
            tts.speak("Okay, discarding the task.")
            return

        # Match positive intent
        if any(word in cleaned for word in CONFIRM_WORDS):
            tts.speak("Okay, planning task...")

            # Only now store it in the database
            vp.storage.store_instruction(vp.session_id, lang, request)
            answer = process_task(request)
            print("🤖 (Task Response):", answer)
        else:
            tts.speak(
                "I wasn't sure what you meant. Could you please repeat your confirmation?"
            )
            retry_result = vp.capture_voice()
            if retry_result is None:
                tts.speak("Still couldn't hear you. Skipping the task.")
                return

            confirmation_retry, _ = retry_result
            cleaned_retry = confirmation_retry.lower().translate(
                str.maketrans("", "", string.punctuation)
            )

            if any(word in cleaned_retry for word in CONFIRM_WORDS):
                tts.speak("Okay, planning task...")
                vp.storage.store_instruction(vp.session_id, lang, request)
                answer = process_task(request)
                print("🤖 (Task Response):", answer)
            else:
                tts.speak("No confirmation. Skipping the task.")
    tts.speak(answer)





# === CLI Entry Point ===
if __name__ == "__main__":

    setup_logging()
    vp = VoiceProcessor()
    tts = SpeechSynthesizer()
    load_chat_history()

    if not hasattr(voice_to_scene_response, "greeted"):
        greeting = generate_llm_greeting()
        tts.speak(greeting)
        voice_to_scene_response.greeted = True

    first_turn = True

    try:
        # while True:
        #     voice_to_scene_response(vp, tts, conversational=not first_turn)
        #     save_chat_history()
        #     first_turn = False
        #     logger.info(f"🟡 Listening again in a few seconds... (Ctrl+C to stop)")

        while True:
            wake_word_triggered.clear()  # reset flag
            listen_for_wake_word(vp, tts)  # blocks until flag is set
            tts.speak(random.choice(WAKE_RESPONSES))
            voice_to_scene_response(vp, tts, conversational=True)
            save_chat_history()
            first_turn = False

            logger.info(f"🟡 Listening again in a few seconds...")

    except KeyboardInterrupt:
        logger.info("👋 Exiting session by user (Ctrl+C).")

    finally:
        if CHAT_MEMORY_PATH.exists():
            CHAT_MEMORY_PATH.unlink()
            logger.info("🧹 Deleted chat memory on exit.")

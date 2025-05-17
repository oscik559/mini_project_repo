# mini_project/modalities/voice_assistant.py
"""VoiceAssistant: A class for managing a multimodal voice assistant with LLM integration, wake-word detection, session management, and task execution.
Main Features:
- Wake-word detection using Porcupine.
- Voice command capture, classification, and processing.
- Integration with Ollama/LLM models for conversation, scene queries, and command classification.
- Persistent chat memory per authenticated user.
- Handles general queries, scene queries (camera object database), remote vision task triggering, and task execution.
- Provides greeting generation, environment context, and random wake responses.
- Logging and session management utilities.
Attributes:
    vp (VoiceProcessor): Handles voice input capture and processing.
    tts (SpeechSynthesizer): Handles text-to-speech output.
    session (SessionManager): Manages user authentication and session state.
    selected_model (str): Currently selected LLM model.
    model_name (str): Default LLM model name.
    memory (ConversationBufferMemory): Stores conversation history for context-aware responses.
    prompt_builder (PromptBuilder): Utility for constructing prompts for LLMs.
    porcupine (pvporcupine.Porcupine): Wake-word detector instance.
    wake_event (threading.Event): Event flag for wake-word detection.
    chat_memory_path (Path): Path to the user's chat memory file.
    authenticated_user (dict): Information about the currently authenticated user.
Methods:
    get_llm(): Returns the current LLM instance.
    set_llm_model(model): Switches the LLM model.
    _build_chain_with_input(input_data): Builds a context-aware LLM chain for scene queries.
    start_session(): Authenticates user and loads chat history.
    load_chat_history(): Loads chat memory from file.
    save_chat_history(): Saves chat memory to file.
    get_greeting(): Returns a random time-of-day greeting.
    handle_wake_word(callback): Starts wake-word detection and triggers callback on detection.
    classify_command(command_text): Classifies a command as 'general', 'scene', 'task', or 'trigger'.
    handle_general_query(command_text): Handles general conversational queries using LLM and context.
    get_environment_context(): Returns current weather, part of day, and formatted datetime.
    process_voice_command(): Captures and processes a voice command.
    generate_llm_greeting(): Generates a greeting using LLM, with fallback.
    fallback_llm_greeting(seed_greeting): Fallback greeting generation using Ollama.
    fetch_camera_objects(): Retrieves camera-detected objects from the database.
    format_camera_data(objects): Formats camera object data for LLM input.
    query_scene(question): Answers scene-related questions using LLM and camera data.
    trigger_remote_vision_task(command_text): Triggers a remote vision task based on command.
    process_task(command_text): Processes and executes a task command.
    process_input_command(command_text, lang): Classifies and routes a command to the appropriate handler.
    reset_memory(): Clears chat memory and deletes memory file.
    get_random_wake_response(): Returns a random wake response.
    log_status(msg, level): Logs a message at the specified level.
    shutdown(): Cleans up session and saves chat history.
"""

import json
import logging
import os
import random
import re
import string
import struct
import threading
import warnings
from datetime import datetime
from pathlib import Path
from typing import Literal, Optional, TypedDict

import ollama
import pvporcupine
import requests
import sounddevice as sd
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain.schema import messages_from_dict, messages_to_dict
from langchain_core._api.deprecation import LangChainDeprecationWarning
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnableLambda, RunnableSequence
from langchain_ollama import ChatOllama

from mini_project.config.app_config import (
    CHAT_MEMORY_FOLDER,
    WAKEWORD_PATH,
    setup_logging,
)
from mini_project.config.constants import (
    CANCEL_WORDS,
    CONFIRM_WORDS,
    GENERAL_TRIGGERS,
    QUESTION_WORDS,
    TASK_VERBS,
    TRIGGER_WORDS,
    WAKE_RESPONSES,
)
from mini_project.database.connection import get_connection
from mini_project.modalities.command_processor import CommandProcessor
from mini_project.modalities.prompt_utils import PromptBuilder
from mini_project.modalities.session_manager import SessionManager
from mini_project.modalities.voice_processor import (
    SpeechSynthesizer,
    VoiceProcessor,
)

# === Logging Config ==========
logging.getLogger("comtypes").setLevel(logging.WARNING)
logging.getLogger("faster_whisper").setLevel(logging.WARNING)

trigger_logger = logging.getLogger("LLMTrigger")
warnings.filterwarnings("ignore", category=LangChainDeprecationWarning)

# === Configuration ==========
OLLAMA_MODEL = "phi4:latest"
ACCESS_KEY = os.getenv("PICOVOICE_ACCESS_KEY")
voice_speed = 180  # 165


class VoiceAssistant:
    def __init__(self, model_name: str = OLLAMA_MODEL):
        setup_logging()
        self.logger = logging.getLogger("VoiceAssistant")

        # Core components
        self.vp = VoiceProcessor()
        self.tts = SpeechSynthesizer()
        self.session = SessionManager()

        # LLM, memory, prompt
        self.selected_model = "phi4:latest"
        # self.llm = ChatOllama(model=model_name)
        self.model_name = model_name
        self.memory = ConversationBufferMemory(
            memory_key="chat_history", input_key="question"
        )
        self.prompt_builder = PromptBuilder()
        # self.prompt = PromptBuilder.scene_prompt_template()

        # Wake-word detector
        self.porcupine = pvporcupine.create(
            access_key=ACCESS_KEY,
            keyword_paths=[WAKEWORD_PATH],
        )
        self.wake_event = threading.Event()

        self.chat_memory_path = None
        self.authenticated_user = None

    def get_llm(self):
        # model = self.session.get("llm_model", self.model_name)
        model = self.selected_model or self.model_name

        self.logger.info(f"Using LLM model: {model}")
        return ChatOllama(model=model)

    def set_llm_model(self, model: str):
        self.selected_model = model
        self.logger.info(f"🔁 LLM model switched to: {model}")

    def _build_chain_with_input(self, input_data: dict):
        """
        Builds a chain that incorporates memory, prompts, LLM, and postprocessing.
        Ideal for scene queries or any context-aware reasoning tasks.
        """
        from langchain_core.runnables import RunnableLambda, RunnableSequence

        prompt = self.prompt_builder.scene_prompt_template()

        def load_memory(_: dict) -> dict:
            chat_history = self.memory.load_memory_variables({})["chat_history"]
            return {**input_data, "chat_history": chat_history}

        def save_memory(output):
            self.memory.save_context(
                {"question": input_data["question"]},
                {"answer": output.content},
            )
            return output

        return (
            RunnableLambda(load_memory)
            | prompt
            | self.get_llm()
            | RunnableLambda(save_memory)
        )

    def start_session(self):
        self.authenticated_user = self.session.authenticate_user()
        if not self.authenticated_user:
            return False, "Authentication failed."

        liu_id = self.authenticated_user["liu_id"]
        self.chat_memory_path = CHAT_MEMORY_FOLDER / f"chat_memory_{liu_id}.json"
        self.load_chat_history()
        return True, f"Authenticated: {self.authenticated_user['first_name']}"

    def load_chat_history(self):
        if self.chat_memory_path and self.chat_memory_path.exists():
            with open(self.chat_memory_path, "r", encoding="utf-8") as f:
                raw = json.load(f)
            self.memory.chat_memory.messages = messages_from_dict(raw)

    def save_chat_history(self):
        if self.chat_memory_path:
            serialized = messages_to_dict(self.memory.chat_memory.messages)
            with open(self.chat_memory_path, "w", encoding="utf-8") as f:
                json.dump(serialized, f, indent=2)

    def get_greeting(self):
        now = datetime.now()
        hour = now.hour
        part_of_day = (
            "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"
        )
        base_greetings = [
            f"Good {part_of_day}! Ready for action?",
            f"Hope your {part_of_day} is going well!",
            f"Hi there! It's a great {part_of_day} to get things done.",
        ]
        return random.choice(base_greetings)

    def handle_wake_word(self, callback):
        def audio_callback(indata, frames, time, status):
            try:
                pcm = struct.unpack_from(
                    "h" * self.porcupine.frame_length, bytes(indata)
                )
                keyword_index = self.porcupine.process(pcm)
                if keyword_index >= 0:
                    self.logger.info("Wake word detected!")
                    self.wake_event.set()
                    callback()
            except Exception as e:
                self.logger.warning(f"Wake word error: {e}")

        threading.Thread(
            target=lambda: sd.RawInputStream(
                samplerate=self.porcupine.sample_rate,
                blocksize=self.porcupine.frame_length,
                dtype="int16",
                channels=1,
                callback=audio_callback,
            ).start(),
            daemon=True,
        ).start()

    def classify_command(
        self, command_text: str
    ) -> Literal["general", "scene", "task", "trigger"]:
        lowered = command_text.lower().strip()

        if any(trigger in lowered for trigger in TRIGGER_WORDS):
            return "trigger"
        if any(word in lowered for word in GENERAL_TRIGGERS):
            return "general"

        try:
            llm = self.get_llm()
            chain = LLMChain(
                llm=llm, prompt=self.prompt_builder.classify_command_prompt()
            )
            result = chain.invoke({"command": command_text})
            classification = result.get("text", "").strip().lower()
            if classification in {"general", "scene", "task", "trigger"}:
                return classification
        except Exception as e:
            self.logger.warning(f"LLM failed, falling back to rules: {e}")

        if any(lowered.startswith(q) for q in QUESTION_WORDS):
            return "scene"
        if re.search(r"\b(is|are|how many|what|which|where|who)\b", lowered):
            return "scene"
        if any(trigger in lowered for trigger in TRIGGER_WORDS):
            return "trigger"
        if any(verb in lowered for verb in TASK_VERBS):
            return "task"
        return "task"

    # def handle_general_query(self, command_text: str) -> str:
    #     user = self.authenticated_user
    #     first_name = user["first_name"]
    #     liu_id = user["liu_id"]
    #     role = user.get("role", "guest")

    #     conn = get_connection()
    #     cursor = conn.cursor()
    #     cursor.execute("SELECT first_name FROM users WHERE role = 'team'")
    #     team_names = [row[0] for row in cursor.fetchall()]
    #     cursor.close()
    #     conn.close()

    #     env = self.get_environment_context()
    #     chat_history = self.memory.load_memory_variables({})["chat_history"]

    #     prompt = self.prompt_builder.general_conversation_prompt(
    #         first_name=first_name,
    #         liu_id=liu_id,
    #         role=role,
    #         team_names=team_names,
    #         weather=env["weather"],
    #         part_of_day=env["part_of_day"],
    #         full_time=env["datetime"],
    #         chat_history=chat_history,
    #     )

    #     llm = self.get_llm()
    #     chain = LLMChain(llm=llm, prompt=prompt)
    #     result = chain.invoke({"command": command_text})
    #     return result["text"].strip().strip('"“”')

    def handle_general_query(self, command_text: str) -> str:
        user = self.authenticated_user
        if user is not None:
            first_name = user.get("first_name")
            liu_id = user.get("liu_id")
            role = user.get("role", "guest")
        else:
            first_name = None
            liu_id = None
            role = "guest"

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT first_name FROM users WHERE role = 'team'")
        team_names = [row[0] for row in cursor.fetchall()]
        cursor.close()
        conn.close()

        env = self.get_environment_context()
        chat_history = self.memory.load_memory_variables({})["chat_history"]

        prompt = self.prompt_builder.general_conversation_prompt(
            first_name=first_name,
            liu_id=liu_id,
            role=role,
            team_names=team_names,
            weather=env["weather"],
            part_of_day=env["part_of_day"],
            full_time=env["datetime"],
            chat_history=chat_history,
        )

        llm = self.get_llm()
        chain = LLMChain(llm=llm, prompt=prompt)
        result = chain.invoke({"command": command_text})
        return result["text"].strip().strip('"“”')

    def get_environment_context(self):
        try:
            import requests

            url = "https://api.open-meteo.com/v1/forecast?latitude=58.41&longitude=15.62&current_weather=true"
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            data = response.json()
            weather = data["current_weather"]
            temperature = round(weather["temperature"])
            description = f"{temperature}°C, wind {weather['windspeed']} km/h"
        except Exception:
            description = "mysterious skies"

        now = datetime.now()
        hour = now.hour
        if 5 <= hour < 12:
            part_of_day = "morning"
        elif 12 <= hour < 17:
            part_of_day = "afternoon"
        elif 17 <= hour < 21:
            part_of_day = "evening"
        else:
            part_of_day = "night"

        return {
            "weather": description,
            "part_of_day": part_of_day,
            "datetime": now.strftime("%A, %B %d at %I:%M %p"),
        }

    def process_voice_command(self):
        result = self.vp.capture_voice()
        if not result:
            return "I didn't catch that. Try again."

        command_text, lang = result
        return self.process_input_command(command_text, lang)

    # ========== Greeting Generation ==========
    def generate_llm_greeting(self) -> str:
        now = datetime.now()
        weekday = now.strftime("%A")
        month = now.strftime("%B")
        hour = now.hour
        time_of_day = (
            "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"
        )

        base_greetings = [
            f"Good {time_of_day}! Happy {weekday}.",
            f"Hope you're having a great {weekday}!",
            f"Hello and welcome this fine {time_of_day}.",
            f"It's {month} already! Let's get started.",
            f"Hi! What’s the first thing you'd like me to do this {time_of_day}?",
        ]
        seed = random.choice(base_greetings)

        try:
            user_prompt = self.prompt_builder.greeting_prompt(
                time_of_day, weekday, month, seed
            )
            response = self.get_llm().invoke(
                [
                    self.prompt_builder.greeting_system_msg(),
                    {"role": "user", "content": user_prompt},
                ]
            )
            return response.content.strip().strip('"“”') or seed
        except Exception as e:
            self.logger.error(f"Greeting failed: {e}")
            return self.fallback_llm_greeting(seed)

    def fallback_llm_greeting(self, seed_greeting: str) -> str:
        try:
            import ollama

            response = ollama.chat(
                model="llama3.2:latest",
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

    # ========== Scene Querying ==========
    def fetch_camera_objects(self):
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

    def format_camera_data(self, objects: list) -> str:
        return "\n".join(
            f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f}) last seen at {timestamp}, usd_name: {usd}"
            for name, color, x, y, z, r, p, w, timestamp, usd in objects
        )

    def query_scene(self, question: str) -> str:
        try:
            objects = self.fetch_camera_objects()
            if not objects:
                return (
                    "I can only see the camera. No other objects are currently visible."
                )
            formatted_data = self.format_camera_data(objects)
            input_data = {"question": question, "data": formatted_data}
            chain = self._build_chain_with_input(input_data)
            response = chain.invoke(input_data)
            return response.content.strip().strip('"“”')
        except Exception as e:
            self.logger.error("Scene query failed", exc_info=True)
            return "[Scene query failed.]"

    def trigger_remote_vision_task(self, command_text: str) -> str:
        conn = get_connection()
        cursor = conn.cursor()

        try:
            cursor.execute(
                """
                SELECT operation_name, description, trigger_keywords, trigger
                FROM operation_library
                WHERE is_triggerable = TRUE
                """
            )
            rows = cursor.fetchall()
            if not rows:
                return "No triggerable operations are available."

            options_text = "\n".join(
                f"{op_name}: {desc or '[no description]'}" for op_name, desc, *_ in rows
            )

            llm_chain = LLMChain(
                llm=self.llm, prompt=self.prompt_builder.match_operation_prompt()
            )
            result = llm_chain.invoke(
                {"command": command_text, "options": options_text}
            )
            matched_operation = result["text"].strip()

            row_map = {
                op_name: {"trigger": trig, "keywords": kws}
                for op_name, _, kws, trig in rows
            }

            if matched_operation not in row_map:
                matched_operation = None

            if not matched_operation:
                lowered = command_text.lower()
                for op_name, _, keywords, is_triggered in rows:
                    if keywords and any(k in lowered for k in keywords):
                        matched_operation = op_name
                        break

            if not matched_operation:
                return "Sorry, I couldn't match any known vision task to your request."

            is_already_triggered = row_map[matched_operation]["trigger"]
            if is_already_triggered:
                return f"The script '{matched_operation}' is already running."

            with conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        UPDATE operation_library
                        SET trigger = FALSE, state = 'idle'
                        WHERE trigger = TRUE OR state = 'triggered'
                    """
                    )
                    cur.execute(
                        """
                        UPDATE operation_library
                        SET trigger = TRUE, state = 'triggered', last_triggered = %s
                        WHERE operation_name = %s
                        """,
                        (datetime.now(), matched_operation),
                    )

            conn.commit()
            return f"Now running the detection script remotely."

        except Exception as e:
            self.logger.error("Triggering vision task failed", exc_info=True)
            return "An error occurred while trying to trigger the remote task."

        finally:
            cursor.close()
            conn.close()

    # ========== Task Processing ==========
    def process_task(self, command_text: str) -> str:
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
                    self.authenticated_user["liu_id"],
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
                "Yes! Task has successfully been planned."
                if success
                else "Sorry, I couldn't understand you."
            )
        except Exception as e:
            self.logger.error(f"Task processing failed: {e}", exc_info=True)
            return "[Task execution failed.]"

    def process_input_command(self, command_text: str, lang: str = "en"):
        cmd_type = self.classify_command(command_text)
        if cmd_type == "general":
            return self.handle_general_query(command_text)
        elif cmd_type == "scene":
            return self.query_scene(command_text)
        elif cmd_type == "trigger":
            return self.trigger_remote_vision_task(command_text)
        elif cmd_type == "task":
            return self.process_task(command_text)
        return f"You said: {command_text}. (Detected: {cmd_type})"

    def reset_memory(self):
        """
        Clears chat memory and deletes the associated memory file if it exists.
        Useful for fresh starts or user-initiated resets from the GUI.
        """
        self.memory.clear()
        if self.chat_memory_path and self.chat_memory_path.exists():
            self.chat_memory_path.unlink(missing_ok=True)
        self.logger.info("🧠 Chat memory reset by user.")

    def get_random_wake_response(self) -> str:
        return random.choice(WAKE_RESPONSES)

    def log_status(self, msg: str, level: str = "info"):
        """
        Allows GUI to hook into logging. Use levels: 'info', 'warning', 'error'.
        """
        if level == "info":
            self.logger.info(msg)
        elif level == "warning":
            self.logger.warning(msg)
        elif level == "error":
            self.logger.error(msg)
        else:
            self.logger.debug(msg)

    # ========== Shut down ==========
    def shutdown(self):
        if self.chat_memory_path and self.chat_memory_path.exists():
            self.chat_memory_path.unlink(missing_ok=True)
        self.save_chat_history()
        self.logger.info("Session ended.")

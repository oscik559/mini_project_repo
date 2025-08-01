# mini_project/modalities/llm_main_chain.py
"""This script implements a voice assistant system for a research lab environment. It integrates
various functionalities such as wake word detection, voice command processing, scene querying,
task execution, and conversational interactions using an LLM (Language Learning Model). The
assistant is designed to interact with users through voice input and provide responses or
execute tasks based on the commands received.

Modules and Functionalities:
- **Wake Word Detection**: Uses Porcupine to detect predefined wake words and trigger the assistant.
- **Voice Command Processing**: Captures voice input, classifies commands, and performs actions
    such as querying a scene, handling general queries, or executing tasks.
- **LLM Integration**: Utilizes LangChain and ChatOllama for natural language understanding,
    reasoning, and generating responses.
- **Scene Querying**: Fetches and formats data from a camera vision database to answer questions
    about the current scene.
- **Task Execution**: Processes task-related commands, stores them in a database, and invokes
    a command processor to handle the task.
- **Persistent Chat Memory**: Maintains a conversation history for context-aware interactions
    and saves it to disk for persistence across sessions.
- **Environment Context**: Provides dynamic context such as weather, time of day, and user roles
    to enhance interactions.
- **Voice Interaction**: Handles conversational interactions, including confirmation for task
    execution and memory reset requests.
- **Greeting Generation**: Dynamically generates personalized greetings based on the time of day
    and user information.

Key Components:
- `VoiceProcessor`: Captures and processes voice input.
- `SpeechSynthesizer`: Converts text responses into speech.
- `SessionManager`: Manages user authentication and session data.
- `CommandProcessor`: Handles task-related commands and processes them.
- `PromptBuilder`: Constructs prompts for LLM-based reasoning and responses.
- `ConversationBufferMemory`: Maintains chat history for context-aware interactions.

Database Integration:
- Fetches user roles, team names, and camera vision data from a database.
- Stores unified instructions and operation sequences for task execution.
- Updates operation triggers in the database for remote vision tasks.

CLI Entry Point:
- Authenticates the user and initializes the assistant.
- Listens for wake words and processes voice commands in a loop.
- Saves chat history and cleans up resources on exit.

Usage:
- Run the script to start the voice assistant.
- Interact with the assistant using voice commands after the wake word is detected.
- Use commands like "reset memory" or "exit" for specific actions.

Note:
- Ensure the required dependencies and database configurations are set up before running the script.
- The script is designed for a specific research lab environment and may require customization
    for other use cases.
"""

# ========== Standard Library Imports ==========
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

# ========== Third-Party Library Imports ==========
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

# ========== Local Project Imports ==========

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

# ========== Wake Word Setup ==========
# Get Picovoice API key from environment variables
ACCESS_KEY = os.getenv("PICOVOICE_ACCESS_KEY")

# Initialize Porcupine wake word engine with custom and built-in keywords
porcupine = pvporcupine.create(
    access_key=ACCESS_KEY,
    keywords=[
        "jarvis",  # Custom wake word
        "computer",  # Built-in wake word
    ],
    keyword_paths=[WAKEWORD_PATH],  # Path to custom wake word model
)

# Threading event to signal when wake word is detected
wake_word_triggered = threading.Event()

# Ensure chat memory directory exists
CHAT_MEMORY_FOLDER.mkdir(parents=True, exist_ok=True)

# Suppress deprecation warnings from LangChain to keep logs clean
warnings.filterwarnings("ignore", category=LangChainDeprecationWarning)

# === Logging Config ==========
# Reduce log noise from verbose third-party libraries
logging.getLogger("comtypes").setLevel(logging.WARNING)
logging.getLogger("faster_whisper").setLevel(logging.WARNING)

# Create specialized loggers for different components
logger = logging.getLogger("VoiceAssistant")
trigger_logger = logging.getLogger("LLMTrigger")

# === Configuration ==========
# Primary LLM model for conversations and reasoning
OLLAMA_MODEL = "llama3.2:latest"
# OLLAMA_MODEL ="phi4:latest"  # Alternative model option

# Speech synthesis speed (words per minute)
voice_speed = 180  # Previously: 165


# === LangChain Setup ==========
# Initialize the main language model for processing commands
llm = ChatOllama(model=OLLAMA_MODEL)

# Create conversation memory to maintain context across interactions
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")

# Get the default scene analysis prompt template
prompt = PromptBuilder.scene_prompt_template()


# Helper function to load chat history into the prompt input
def load_memory(inputs: dict) -> dict:
    """Load conversation history and merge it with current inputs."""
    chat_history = memory.load_memory_variables({})["chat_history"]
    return {**inputs, "chat_history": chat_history}


# Function to build a processing chain with memory context
def build_chain_with_input(input_data):
    """Create a runnable chain that processes input through LLM and saves to memory."""
    return (
        RunnableLambda(load_memory)  # Load chat history
        | prompt  # Apply prompt template
        | llm  # Process through LLM
        | RunnableLambda(
            lambda output: save_memory_with_input(input_data, output)
        )  # Save result
    )


# Function to save interaction to memory
def save_memory_with_input(original_input, output):
    """Save the current question-answer pair to conversation memory."""
    memory.save_context(
        {"question": original_input["question"]},
        {"answer": output.content},
    )
    return output


# Alternative chain structure (currently unused but kept for reference)
chain = (
    {
        # "input": RunnableLambda(load_memory),  # Commented out alternative approach
        "original_input": lambda x: x,  # Pass-through original input for context
    }
    | RunnableLambda(lambda d: d["input"])  # Continue with prompt processing
    | prompt
    | llm
    | RunnableLambda(
        lambda output, inputs: {"input": inputs["original_input"], "output": output}
    )
    | RunnableLambda(save_memory_with_input)
)


# === Command Classification ===
def classify_command(
    command_text: str, llm
) -> Literal["general", "scene", "task", "trigger"]:
    """
    Classify user commands into one of four categories using rule-based and LLM approaches.

    Args:
        command_text: The user's spoken command
        llm: Language model instance for classification

    Returns:
        Command type: "general", "scene", "task", or "trigger"
    """
    lowered = command_text.lower().strip()

    # === Rule-based classification (high priority checks) ===

    # Check for trigger words first (highest priority)
    if any(trigger in lowered for trigger in TRIGGER_WORDS):
        return "trigger"

    # Check for general conversation triggers
    if any(word in command_text.lower() for word in GENERAL_TRIGGERS):
        return "general"

    # === LLM-based classification (fallback to AI reasoning) ===
    try:
        classification_chain = LLMChain(
            llm=llm, prompt=PromptBuilder.classify_command_prompt()
        )
        result = classification_chain.invoke({"command": command_text})
        classification = result.get("text", "").strip().lower()

        # Validate LLM response is one of our expected categories
        if classification in {"general", "scene", "task", "trigger"}:
            return classification
    except Exception as e:
        logger.warning(f"[⚠️] LLM classification failed, using rule-based fallback: {e}")

    # === Rule-based fallback (when LLM fails) ===

    # Questions starting with typical question words are likely scene queries
    if any(lowered.startswith(q) for q in QUESTION_WORDS):
        return "scene"

    # Pattern matching for interrogative words indicates scene queries
    if re.search(r"\b(is|are|how many|what|which|where|who)\b", lowered):
        return "scene"

    # Double-check for trigger words (safety net)
    if any(trigger in lowered for trigger in TRIGGER_WORDS):
        return "trigger"

    # Commands with action verbs are likely tasks
    if any(verb in lowered for verb in TASK_VERBS):
        return "task"

    # Default classification when no clear indicators are found
    return "task"


# === Persistent Chat Memory ===
def save_chat_history():
    """Save current conversation memory to disk for persistence across sessions."""
    try:
        # Convert LangChain messages to serializable format
        serialized = messages_to_dict(memory.chat_memory.messages)

        # Write to user-specific chat memory file
        with open(CHAT_MEMORY_PATH, "w", encoding="utf-8") as f:
            json.dump(serialized, f, indent=2)
        logger.info("💾 Chat history saved.")
    except Exception as e:
        logger.error(f"Failed to save chat memory: {e}")


def load_chat_history():
    """Load previous conversation history from disk if available."""
    if CHAT_MEMORY_PATH.exists():
        try:
            # Read serialized messages from file
            with open(CHAT_MEMORY_PATH, "r", encoding="utf-8") as f:
                raw_messages = json.load(f)

            # Convert back to LangChain message format and restore to memory
            memory.chat_memory.messages = messages_from_dict(raw_messages)
            logger.info("🧠 Loaded past chat history.")
        except Exception as e:
            logger.warning(f"Could not load chat memory: {e}")


def get_user_roles():
    """Fetch all users and their roles from the database."""
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        SELECT first_name, role
        FROM users
    """
    )
    result = cursor.fetchall()
    conn.close()

    # Return as dictionary mapping names to roles
    return {name: role for name, role in result}


def get_team_names():
    """Retrieve names of all users with 'team' role from the database."""
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT first_name FROM users WHERE role = 'team'")
    names = [row[0] for row in cursor.fetchall()]
    conn.close()

    return names


def handle_general_query(command_text: str, llm, user: Optional[dict] = None) -> str:
    if user is None:
        session = SessionManager()
        user = session.authenticated_user
    first_name = user["first_name"]
    liu_id = user["liu_id"]
    role = user.get("role", "guest")

    team_names = get_team_names()
    env = get_environment_context()

    chat_history = memory.load_memory_variables({})["chat_history"]

    prompt = PromptBuilder.general_conversation_prompt(
        first_name=first_name,
        liu_id=liu_id,
        role=role,
        team_names=team_names,
        weather=env["weather"],
        part_of_day=env["part_of_day"],
        full_time=env["datetime"],
        chat_history=chat_history,
    )

    chain = LLMChain(llm=llm, prompt=prompt)
    result = chain.invoke({"command": command_text})
    # return result["text"].strip()
    cleaned = result["text"].strip().strip('"').strip("“”").strip("'")
    return cleaned


def handle_general_query(command_text: str, llm, user: Optional[dict] = None) -> str:
    """
    Process general conversation queries using user context and environment information.

    Args:
        command_text: The user's query text
        llm: Language model instance
        user: User information dictionary (optional, will fetch from session if None)

    Returns:
        Cleaned response string from the LLM
    """
    # Get user information if not provided
    if user is None:
        session = SessionManager()
        user = session.authenticated_user

    # Extract user details for personalization
    first_name = user["first_name"]
    liu_id = user["liu_id"]
    role = user.get("role", "guest")

    # Gather contextual information
    team_names = get_team_names()
    env = get_environment_context()

    # Load conversation history for context
    chat_history = memory.load_memory_variables({})["chat_history"]

    # Build personalized prompt with all context
    prompt = PromptBuilder.general_conversation_prompt(
        first_name=first_name,
        liu_id=liu_id,
        role=role,
        team_names=team_names,
        weather=env["weather"],
        part_of_day=env["part_of_day"],
        full_time=env["datetime"],
        chat_history=chat_history,
    )

    # Execute the conversation chain
    chain = LLMChain(llm=llm, prompt=prompt)
    result = chain.invoke({"command": command_text})

    # Clean up response by removing quotes and extra formatting
    # return result["text"].strip()  # Original approach
    cleaned = result["text"].strip().strip('"').strip('"""').strip("'")
    return cleaned


# === Trigger Remote Vision Task ==========
def trigger_remote_vision_task(command_text: str) -> str:
    """
    Uses LLM-based reasoning to match the user's command to a known operation,
    and triggers that operation by updating the DB. Falls back to trigger_keywords.
    """
    conn = get_connection()
    cursor = conn.cursor()

    logger.info("🔍 Using LLM to match command: '%s'", command_text)

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

        # === Step 1: Try LLM-based matching using descriptions ===
        options_text = "\n".join(
            f"{op_name}: {desc or '[no description]'}" for op_name, desc, *_ in rows
        )

        llm_chain = LLMChain(llm=llm, prompt=PromptBuilder.match_operation_prompt())
        result = llm_chain.invoke({"command": command_text, "options": options_text})
        matched_operation = result["text"].strip()

        # === Step 2: Check LLM result validity ===
        row_map = {
            op_name: {"trigger": trig, "keywords": kws}
            for op_name, _, kws, trig in rows
        }

        if matched_operation not in row_map:
            logger.warning("❌ LLM returned unknown operation: %s", matched_operation)
            matched_operation = None  # fallback to keyword

        # === Step 3: Fallback to keyword match if LLM fails ===
        if not matched_operation:
            lowered = command_text.lower()
            # Search through all operations for keyword matches
            for op_name, _, keywords, is_triggered in rows:
                if keywords and any(k in lowered for k in keywords):
                    matched_operation = op_name
                    break

        # Return error if no operation matches the command
        if not matched_operation:
            logger.info("❌ No matching operation found (LLM + keyword).")
            return "Sorry, I couldn't match any known vision task to your request."

        # Check if the matched operation is already running
        is_already_triggered = row_map[matched_operation]["trigger"]
        if is_already_triggered:
            logger.info(
                "⚠️ Operation '%s' already triggered. Skipping.", matched_operation
            )
            # return f"The task '{matched_operation}' is already triggered."  # Original message
            return f"the script '{matched_operation}' is already running."

        # === Step 4: Exclusively trigger this operation ===
        with conn:
            with conn.cursor() as cursor:
                # First, disable all currently running operations
                cursor.execute(
                    """
                    UPDATE operation_library
                    SET trigger = FALSE,
                        state = 'idle'
                    WHERE trigger = TRUE OR state = 'triggered'
                    """
                )
                # Then enable only the requested operation
                cursor.execute(
                    """
                    UPDATE operation_library
                    SET trigger = TRUE,
                        state = 'triggered',
                        last_triggered = %s
                    WHERE operation_name = %s
                    """,
                    (datetime.now(), matched_operation),
                )

        conn.commit()
        logger.info("✅ Remote task triggered exclusively: %s", matched_operation)
        # return f" Now running the script '{matched_operation}' remotely."  # Original message
        return f" Now running the detection script remotely."

    except Exception as e:
        logger.error("❌ Triggering vision task failed: %s", str(e), exc_info=True)
        return "An error occurred while trying to trigger the remote task."

    finally:
        cursor.close()
        conn.close()


# ========== Scene Description ==========
def fetch_camera_objects() -> list:
    """Retrieve all detected objects from the camera vision database."""
    conn = get_connection()
    cursor = conn.cursor()

    # Query all object data including position, orientation, and metadata
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
    """Format camera object data into a human-readable string for LLM processing."""
    return "\n".join(
        f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f}) last seen at {timestamp}, usd_name: {usd}"
        for name, color, x, y, z, r, p, w, timestamp, usd in objects
    )


# ========== Scene Query ==========
def query_scene(question: str) -> str:
    """
    Queries the current scene based on the provided question and returns a response.
    This function fetches objects visible to the camera, formats the data, and uses
    a chain to process the input and generate a response. If no objects are visible,
    it returns a default message. In case of an error, it logs the error and returns
    a failure message.
    Args:
        question (str): The question to ask about the current scene.
    Returns:
        str: The response to the question, or an error message if the query fails.
    """
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


# ========== Task Processing ==========
def process_task(command_text: str) -> str:
    """Processes a given command text by storing it in a database, clearing any
    existing operation sequences, and invoking a command processor to handle
    the task.
    Args:
        command_text (str): The command text to be processed.
    Returns:
        str: A message indicating whether the task was successfully planned
        and added or if the task could not be understood.
    Raises:
        Exception: Logs an error and returns a failure message if any
        exception occurs during the process.
    Database Operations:
        - Inserts the command into the `unified_instructions` table with
          relevant metadata.
        - Clears the `operation_sequence` table.
    Notes:
        - Assumes the existence of a `get_connection` function to establish
          a database connection.
        - Assumes a `CommandProcessor` class is available for processing
          commands.
        - Logs errors using the `logging` module.
    """

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
                session.authenticated_user["liu_id"],
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
            "Yes! task has successfully been planned."
            if success
            else "Sorry, I couldn't understand you."
        )
    except Exception as e:
        logging.error(f"Task processing failed: {e}")
        return "[Task execution failed.]"


def get_weather_description(latitude=58.41, longitude=15.62) -> str:
    """
    Fetch current weather information from Open-Meteo API.

    Args:
        latitude: Geographical latitude (default: Linköping, Sweden)
        longitude: Geographical longitude (default: Linköping, Sweden)

    Returns:
        Weather description string or fallback message if API fails
    """
    try:
        # Query Open-Meteo free weather API
        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
        response = requests.get(url, timeout=5)
        response.raise_for_status()

        # Parse weather data and format for voice output
        data = response.json()
        weather = data["current_weather"]
        temperature = round(weather["temperature"])
        description = f"{temperature}°C, wind {weather['windspeed']} km/h"
        return description
    except Exception as e:
        print(f"Weather fetch failed: {e}")
        return "mysterious skies"  # Fallback for API failures


def get_environment_context():
    """
    Gather environmental context including weather and time information.

    Returns:
        Dictionary containing weather, part_of_day, and formatted datetime
    """
    # Get current weather information
    weather = get_weather_description()  # Returns formatted weather string
    now = datetime.now()
    hour = now.hour

    # Determine part of day based on current hour
    if 5 <= hour < 12:
        part_of_day = "morning"
    elif 12 <= hour < 17:
        part_of_day = "afternoon"
    elif 17 <= hour < 21:
        part_of_day = "evening"
    else:
        part_of_day = "night"

    return {
        "weather": weather,
        "part_of_day": part_of_day,
        "datetime": now.strftime(
            "%A, %B %d at %I:%M %p"
        ),  # e.g., "Tuesday, April 18 at 10:30 AM"
    }


# ========== Wake Word Listener ==========
def listen_for_wake_word(vp, tts):
    """
    Listen continuously for wake words using Porcupine wake word detection.

    Args:
        vp: VoiceProcessor instance (unused but kept for interface consistency)
        tts: SpeechSynthesizer instance (unused but kept for interface consistency)
    """

    def callback(indata, frames, time, status):
        """Audio callback function that processes incoming audio for wake words."""
        try:
            # Convert audio data to PCM format for Porcupine processing
            pcm = struct.unpack_from("h" * porcupine.frame_length, bytes(indata))

            # Process audio frame through Porcupine wake word engine
            keyword_index = porcupine.process(pcm)

            # If a wake word is detected (index >= 0), signal the main thread
            if keyword_index >= 0:
                logger.info("✅ Wake word detected!")
                wake_word_triggered.set()  # Signal main thread to proceed
        except Exception as e:
            logger.warning(f"Wake word callback error: {e}")

    # Start audio input stream with Porcupine-compatible parameters
    with sd.RawInputStream(
        samplerate=porcupine.sample_rate,  # Must match Porcupine's expected sample rate
        blocksize=porcupine.frame_length,  # Process audio in Porcupine frame sizes
        dtype="int16",  # 16-bit PCM audio format
        channels=1,  # Mono audio input
        callback=callback,  # Function to process each audio frame
    ):
        logger.info("🎙️  🟢🟢🟢 LISTENING FOR WAKE WORD 🟢🟢🟢")

        # Keep listening until wake word is detected
        while not wake_word_triggered.is_set():
            sd.sleep(100)  # Non-blocking wait (100ms intervals)


# ========== Greeting ==========
def generate_llm_greeting():
    """
    Generates a dynamic greeting message using a language model (LLM).
    The function constructs a greeting based on the current time of day, day of the week,
    and month. It uses a predefined set of base greetings as inspiration and prompts the
    LLM to generate a creative, short, and voice-friendly message. If the LLM invocation
    fails, a fallback greeting is returned.
    Returns:
        str: A greeting message, either generated by the LLM or a fallback message.
    """
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


# ========== Voice Interaction ==========
def voice_to_scene_response(
    vp: VoiceProcessor, tts: SpeechSynthesizer, conversational: bool = True
):
    """
    Processes voice input to generate a response, either by querying a scene or planning a task.
    This function captures voice input, classifies the command, and performs actions based on the
    command type. It supports conversational interactions, handles memory reset requests, and
    confirms task execution before proceeding.
    Args:
        vp (VoiceProcessor): The voice processor instance used to capture and process voice input.
        tts (SpeechSynthesizer): The text-to-speech synthesizer instance used to provide audio feedback.
        conversational (bool, optional): Indicates whether the voice capture should be conversational.
                                          Defaults to True.
    Behavior:
        - Captures voice input and processes it.
        - Handles specific commands like "exit", "reset memory", or "clear memory".
        - Classifies the command type (e.g., "scene" or "task").
        - Queries a scene or plans a task based on the command type.
        - Confirms task execution with the user before proceeding.
        - Provides audio feedback for all interactions.
    Returns:
        None
    """
    # Capture and process voice input
    result = vp.capture_voice(conversational=conversational)
    if result is None:
        logger.info(f"🟡 No speech detected. Try again.")
        tts.speak("I didn't catch that. Could you please repeat?")
        return

    # Extract command text and language from voice input
    request, lang = result
    logger.info(f"🎯 You said: {request}")

    # Classify the command to determine appropriate response strategy
    cmd_type = classify_command(request, llm)
    logger.info(f"🧠 Command classified as: {cmd_type}")

    # ========== Handle Special Commands ==========
    # Check for session termination commands
    if request.lower() in {"exit", "quit", "goodbye", "stop"}:
        tts.speak("Okay, goodbye!")
        exit(0)

    # Check for memory management commands
    if request.lower() in {"reset memory", "clear memory"}:
        memory.clear()  # Clear conversation memory
        CHAT_MEMORY_PATH.unlink(missing_ok=True)  # Delete memory file
        tts.speak("Memory has been reset.")
        return

    logger.info(f"🤖 Thinking...")

    # ========== Process Command by Type ==========
    if cmd_type == "trigger":
        # Execute remote vision tasks
        answer = trigger_remote_vision_task(request)
        logger.info(f"🧠 Trigger Result: {answer}")
        tts.speak(answer)
        return

    elif cmd_type == "scene":
        # Query current scene/environment
        answer = query_scene(request)
        logger.info(f"🤖 (Scene Response): {answer}")

    elif cmd_type == "general":
        # Handle general conversation
        answer = handle_general_query(request, llm, user)
        logger.info(f"🤖 (General Response): {answer}")

    else:  # task
        # ========== Task Confirmation Process ==========
        # Ask user to confirm task execution
        tts.speak("Should I go ahead with a task plan?")
        confirm_result = vp.capture_voice()
        if confirm_result is None:
            tts.speak("No confirmation heard. Skipping the task.")
            return

        confirmation, _ = confirm_result
        # Clean and normalize confirmation response for processing
        cleaned = confirmation.lower().translate(
            str.maketrans("", "", string.punctuation)
        )

        # Check for negative responses first (no, cancel, stop, etc.)
        if any(word in cleaned for word in CANCEL_WORDS):
            tts.speak("Okay, discarding the task.")
            return

        # Check for positive confirmation (yes, okay, proceed, etc.)
        if any(word in cleaned for word in CONFIRM_WORDS):
            tts.speak("Okay, hold on...")

            # Store the instruction in database and process the task
            vp.storage.store_instruction(vp.session_id, lang, request)
            answer = process_task(request)
            print("🤖 (Task Response):", answer)
        else:
            # Handle unclear confirmation - ask user to repeat
            tts.speak(
                "I wasn't sure what you meant. Could you please repeat your confirmation?"
            )
            retry_result = vp.capture_voice()
            if retry_result is None:
                tts.speak("Still couldn't hear you. Skipping the task.")
                return

            # Process retry attempt
            confirmation_retry, _ = retry_result
            cleaned_retry = confirmation_retry.lower().translate(
                str.maketrans("", "", string.punctuation)
            )

            # Check retry confirmation
            if any(word in cleaned_retry for word in CONFIRM_WORDS):
                tts.speak("Okay, planning task...")
                vp.storage.store_instruction(vp.session_id, lang, request)
                answer = process_task(request)
                print("🤖 (Task Response):", answer)
            else:
                tts.speak("No confirmation. Skipping the task.")

    # Provide final response to user (except for trigger commands which return early)
    tts.speak(answer)


# ========== CLI Entry Point ==========
if __name__ == "__main__":
    # Initialize logging system and core voice components
    setup_logging()
    vp = VoiceProcessor()  # Handles voice input and speech recognition
    tts = SpeechSynthesizer()  # Handles text-to-speech output

    # ========== User Authentication ==========
    session = SessionManager()
    user = session.authenticate_user()  # Authenticate via face/voice recognition

    # Exit gracefully if authentication fails
    if not user:
        logger.info(f"🔴 Authentication failed.")
        tts.speak("Authentication was aborted or failed. Goodbye..")
        exit()

    # Extract user information for personalization
    liu_id = user["liu_id"]
    first_name = user["first_name"]
    last_name = user["last_name"]

    # ========== Load Personalized Memory ==========
    # Create user-specific memory file path
    CHAT_MEMORY_PATH = CHAT_MEMORY_FOLDER / f"chat_memory_{liu_id}.json"
    load_chat_history()  # Restore previous conversation context

    # ========== Greet User ==========
    # Generate greeting only once per session using function attribute
    if not hasattr(voice_to_scene_response, "greeted"):
        # Generate creative, context-aware greeting
        greeting = generate_llm_greeting()
        tts.speak(greeting)

        # Follow with personalized welcome message
        greeting = f"Hello {first_name}. How can I assist you today?"
        tts.speak(greeting)

        # Mark that user has been greeted to avoid repetition
        voice_to_scene_response.greeted = True

    # Track whether this is the user's first interaction
    first_turn = True

    try:
        # ========== Main Event Loop ==========
        while True:
            # Reset wake word detection flag for next iteration
            wake_word_triggered.clear()

            # Listen for wake word (blocks until detected)
            listen_for_wake_word(vp, tts)

            # Acknowledge wake word detection with random response
            tts.speak(random.choice(WAKE_RESPONSES))

            # Process the user's voice command and respond
            voice_to_scene_response(vp, tts, conversational=True)

            # Save conversation history after each interaction
            save_chat_history()

            # Update state for subsequent turns
            first_turn = False
            logger.info(f"🟡 Listening again in a few seconds...")

    except KeyboardInterrupt:
        # Handle graceful shutdown when user presses Ctrl+C
        logger.info("👋 Exiting session by user (Ctrl+C).")

    finally:
        # Clean up resources on exit
        if CHAT_MEMORY_PATH.exists():
            CHAT_MEMORY_PATH.unlink()  # Delete temporary chat memory file
            logger.info("🧹 Deleted chat memory on exit.")

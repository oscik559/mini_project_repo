import json
import logging
import os
import random
import re
import string
import struct
import sys
import threading
import time
import uuid
import warnings
from datetime import datetime
from typing import Literal, Optional, TypedDict

import ollama
import pvporcupine
import requests
import sounddevice as sd
from mini_project.config.app_config import (
    WAKEWORD_PATH,
    CHAT_MEMORY_FOLDER,
    setup_logging,
)
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from langchain.schema import messages_from_dict, messages_to_dict
from langchain_core.runnables import RunnableLambda
from langchain_ollama import ChatOllama
from langgraph.graph import END, StateGraph

from mini_project.database.connection import get_connection
from mini_project.modalities.prompt_utils import PromptBuilder
from mini_project.modalities.session_manager import SessionManager
from mini_project.modalities.voice_processor import SpeechSynthesizer

sys.setrecursionlimit(1000)

from mini_project.config.constants import (
    CANCEL_WORDS,
    CONFIRM_WORDS,
    GENERAL_TRIGGERS,
    QUESTION_WORDS,
    TASK_VERBS,
    TRIGGER_WORDS,
    WAKE_RESPONSES,
)
from intent_subgraphs.general_query_subgraph import get_general_query_subgraph
from intent_subgraphs.scene_query_subgraph import get_scene_query_subgraph
from intent_subgraphs.task_planner_subgraph import get_task_planner_subgraph
from intent_subgraphs.trigger_task_subgraph import get_trigger_task_subgraph

from mini_project.modalities.langraph_implementation.voice_processor_subgraph import (
    get_voice_subgraph,
)

# === Configuration ===
OLLAMA_MODEL = "llama3.2:latest"
voice_speed = 180  # 165

# === LangChain Setup ===
llm = ChatOllama(model=OLLAMA_MODEL)
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")
# prompt = PromptTemplate.from_template(SCENE_PROMPT_TEMPLATE)
prompt = PromptBuilder.scene_prompt_template()

# === Setup Wake Word Detection ===
PICOVOICE_ACCESS_KEY = "E0O2AD01eT6cJ83n1yYf5bekfdIOEGUky9q6APkwdx9enDaMLZQtLw=="

# WAKEWORD = os.path.abspath("assets/robot_wakewords/hey_yummy.ppn")
# Use built-in or custom model path
porcupine = pvporcupine.create(
    access_key=PICOVOICE_ACCESS_KEY,
    keywords=[
        "jarvis",
        "computer",
    ],
    keyword_paths=[WAKEWORD_PATH],
)

# === Logging Setup ===
logging.getLogger("comtypes").setLevel(logging.WARNING)
logging.getLogger("faster_whisper").setLevel(logging.WARNING)

logger = logging.getLogger("LangChainGraph")

# === LangChain Memory ===
CHAT_MEMORY_FOLDER = "assets/chat_memory"
os.makedirs(CHAT_MEMORY_FOLDER, exist_ok=True)
llm = ChatOllama(model="llama3.2:latest")
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")

# === Shared Modules ===
tts = SpeechSynthesizer()
session = SessionManager()


# === Chat Memory ===
def load_chat_history(liu_id):
    path = os.path.join(CHAT_MEMORY_FOLDER, f"chat_memory_{liu_id}.json")
    if os.path.exists(path):
        with open(path, "r") as f:
            messages = json.load(f)
            memory.chat_memory.messages = messages_from_dict(messages)


# Helper to load chat history into the prompt input
def load_memory(inputs: dict) -> dict:
    memory_vars = memory.load_memory_variables({})
    chat_history = memory_vars.get("history", "")  # Works with FAISS too

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


def save_chat_history(liu_id):
    path = os.path.join(CHAT_MEMORY_FOLDER, f"chat_memory_{liu_id}.json")
    with open(path, "w") as f:
        json.dump(messages_to_dict(memory.chat_memory.messages), f, indent=2)


# === State Schema ===
class MyState(TypedDict, total=False):
    user: dict
    transcribed_text: str
    lang: str
    command_type: str
    reply: str
    confirmed: bool
    session_id: str


# === LangGraph Nodes ===


def wait_for_wake_word_node(state):
    logger.info(f"📢 Waiting for wake word... (say Hey Yumi)")
    triggered = False

    def callback(indata, frames, time, status):
        nonlocal triggered
        try:
            pcm = struct.unpack_from("h" * porcupine.frame_length, bytes(indata))
            keyword_index = porcupine.process(pcm)
            if keyword_index >= 0:
                logger.info(f"🟢 Wake word detected!")
                triggered = True
        except Exception as e:
            logger.info(f"[WakeWord Error] {e}")

    with sd.RawInputStream(
        samplerate=porcupine.sample_rate,
        blocksize=porcupine.frame_length,
        dtype="int16",
        channels=1,
        callback=callback,
    ):
        while not triggered:
            sd.sleep(100)

    safe_speak(random.choice(WAKE_RESPONSES))
    return state


# === Greeting ===
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


def safe_speak(text):
    try:
        tts.speak(text)
    except Exception:
        logger.warning("[TTS-Fallback] TTS failed. logger.infoing instead.")
        logger.info(f"🗣️ {text}")


def authenticate_user_node(state):
    logger.info("🔐 Running authentication...")
    user = session.authenticate_user()
    if not user:
        safe_speak("Authentication failed. Goodbye.")
        exit()

    # Embed user info into graph state
    state["user"] = user
    state["liu_id"] = user["liu_id"]
    state["session_id"] = session.create_session()

    load_chat_history(user["liu_id"])
    greeting = generate_llm_greeting()
    safe_speak(greeting)
    safe_speak(f"Hello {user['first_name']}. How can I assist you today?")
    return state


def get_session_context(state):
    return state.get("liu_id"), state.get("session_id")


# === Command Classification ===
def classify_command(
    command_text: str, llm
) -> Literal["general", "scene", "task", "trigger"]:
    lowered = command_text.lower().strip()

    # === Rule-based classification ===
    # === Rule-based check for "trigger" ===
    if any(trigger in lowered for trigger in TRIGGER_WORDS):
        return "trigger"

    # === Rule-based check for "general" ===
    if any(word in command_text.lower() for word in GENERAL_TRIGGERS):
        return "general"

    if any(
        term in lowered
        for term in ["see", "visible", "on the table", "object", "shapes"]
    ):
        return "scene"

    #  === Try LLM-based classification ===
    try:
        classification_chain = PromptBuilder.classify_command_prompt() | llm
        result = classification_chain.invoke({"command": command_text})
        # logger.info(f"[LLM Classification Raw] {result}")
        classification = str(result.content).strip().lower()
        logger.info(f"[LLM Classification Raw] {result.content}")
        if classification in {"general", "scene", "task", "trigger"}:
            return classification
    except Exception as e:
        logger.warning(f"[⚠️] LLM failed, using rule-based fallback: {e}")

    # === Rule-based fallback ===
    if any(lowered.startswith(q) for q in QUESTION_WORDS):
        return "scene"

    if re.search(r"\b(is|are|how many|what|which|where|who)\b", lowered):
        return "scene"

    if any(trigger in lowered for trigger in TRIGGER_WORDS):
        return "trigger"

    if any(verb in lowered for verb in TASK_VERBS):
        return "task"

    return "task"


def classify_node(state):
    cmd = state.get("transcribed_text")
    if not cmd:
        logger.info(f"⚠️ Warning: No transcribed text found. Skipping classification.")
        return state

    if cmd.lower() in {"reset memory", "clear memory"}:
        state["command_type"] = "reset_memory"
    else:
        state["command_type"] = classify_command(cmd, llm)
    logger.info(f"[Classify] Command type: {state['command_type']}")
    return state


def convert_expressions_to_phonetics(text: str) -> str:
    replacements = {
        "(laughs)": "hahaha!",
        "(chuckles)": "hehe.",
        "(giggles)": "teehee!",
        "(sighs)": "hmm...",
        "(gasps)": "oh!",
        "(whispers)": "psst...",
        "(groans)": "ugh...",
        "(yawns)": "yaaawn...",
        "(clears throat)": "ahem.",
        "(sings)": "la la laaa 🎶",
    }
    for cue, phonetic in replacements.items():
        text = text.replace(cue, phonetic)
    return text


def respond_node(state):
    if state.get("reply"):
        logger.info(f"[Respond] Reply: {state['reply']}")
        safe_speak(state["reply"])
    return state


def save_and_repeat(state):
    save_chat_history(state["user"]["liu_id"])
    return state


def should_continue_node(state):
    text = state.get("transcribed_text", "").lower()
    if text in {"exit", "quit", "goodbye", "stop"}:
        safe_speak("👋 Okay, ending the session.")
        return {"__state__": state, "__next__": "end"}
    return {"__state__": state, "__next__": "continue"}


def reset_memory_node(state):
    text = state.get("transcribed_text", "").lower()
    if text in {"reset memory", "clear memory"}:
        memory.clear()
        liu_id = state["user"]["liu_id"]
        path = os.path.join(CHAT_MEMORY_FOLDER, f"chat_memory_{liu_id}.json")
        if os.path.exists(path):
            os.remove(path)
        safe_speak("🧠 Memory has been reset.")
        state["reply"] = "Memory cleared."
    return state


def confirm_voice_node(state):
    def ask_and_check():
        voice_state = get_voice_subgraph().invoke(
            {"session_id": state.get("session_id")}
        )

        confirmation_text = (
            voice_state.get("transcribed_text", "")
            .lower()
            .translate(str.maketrans("", "", string.punctuation))
        )

        # ✅ Handle negative intent first
        if any(word in confirmation_text for word in CANCEL_WORDS):
            safe_speak("Okay, discarding the task.")
            state["confirmed"] = False
            return state, True

        if any(word in confirmation_text for word in CONFIRM_WORDS):
            state["confirmed"] = True
            return state, True

        return state, False  # Unclear response

    safe_speak("Should I go ahead with a task plan?")
    state, understood = ask_and_check()

    if not understood:
        tts.play_ding()
        safe_speak("I wasn't sure what you meant. Could you please repeat?")
        state, understood = ask_and_check()

    if not state.get("confirmed"):
        state["reply"] = "Okay, skipping the task."
        return state
    return state


def fallback_node(state):
    state["reply"] = "Sorry, I didn't understand that command."
    return state


# === Build LangGraph ===
graph = StateGraph(state_schema=MyState)

# Nodes
graph.add_node("general_query", get_general_query_subgraph())
graph.add_node("scene_query", get_scene_query_subgraph())
graph.add_node("trigger_task", get_trigger_task_subgraph())

graph.add_node("task_planner", get_task_planner_subgraph())
graph.add_node("confirm_task", confirm_voice_node)
graph.add_node("authenticate_user", authenticate_user_node)
graph.add_node("wait_for_wake_word", wait_for_wake_word_node)
graph.add_node("voice_input", get_voice_subgraph())
graph.add_node("classify", classify_node)
graph.add_node("fallback", fallback_node)
graph.add_node("respond", respond_node)
graph.add_node("save_and_repeat", save_and_repeat)
graph.add_node("should_continue", should_continue_node)
graph.add_node("reset_memory", reset_memory_node)


# Edges
graph.set_entry_point("authenticate_user")
graph.add_edge("authenticate_user", "wait_for_wake_word")
graph.add_edge("wait_for_wake_word", "voice_input")
graph.add_edge("voice_input", "classify")


graph.add_conditional_edges(
    "classify",
    lambda s: s.get("command_type"),
    {
        "general": "general_query",
        "scene": "scene_query",
        "trigger": "trigger_task",
        "task": "confirm_task",
        "reset_memory": "reset_memory",
        "fallback": "fallback",
    },
)


graph.add_edge("confirm_task", "task_planner")
graph.add_edge("general_query", "respond")
graph.add_edge("scene_query", "respond")
graph.add_edge("trigger_task", "respond")
graph.add_edge("task_planner", "respond")
graph.add_edge("reset_memory", "respond")
graph.add_edge("fallback", "respond")
graph.add_edge("respond", "save_and_repeat")
graph.add_edge("save_and_repeat", "should_continue")

graph.add_conditional_edges(
    "should_continue",
    lambda s: (
        "end"
        if s.get("transcribed_text", "").lower() in {"exit", "quit", "goodbye", "stop"}
        else "continue"
    ),
    {"end": END, "continue": "wait_for_wake_word"},
)

graph = graph.compile()
print(graph.get_graph().draw_mermaid())


# === Main Function ===
if __name__ == "__main__":
    try:
        setup_logging()  # Only if needed; otherwise, remove
        final_state = graph.invoke({})
    except KeyboardInterrupt:
        logger.info("\n🛑 Session interrupted by user. Exiting gracefully.")
        sys.exit(0)

    # ✅ Add a clean user summary
    logger.info("\n✅ Session Summary")
    logger.info("-----------------")
    user = final_state.get("user", {})
    logger.info(
        f"👤 User: {user.get('first_name', 'N/A')} ({user.get('liu_id', 'N/A')})"
    )
    logger.info(f"🗣️  Last command: {final_state.get('transcribed_text', 'None')}")
    logger.info(f"🧠 Memory updated: {final_state.get('reply', 'No reply')}")
    logger.info(f"📁 Chat history saved.")

    liu_id = final_state.get("user", {}).get("liu_id")
    if liu_id:
        memory_path = os.path.join(CHAT_MEMORY_FOLDER, f"chat_memory_{liu_id}.json")
        if os.path.exists(memory_path):
            os.remove(memory_path)
            logger.info("🧹 Memory file deleted after session.")

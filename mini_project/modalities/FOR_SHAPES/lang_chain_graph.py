import json
import os
import random
import string
import struct
import sys
from typing import TypedDict

import pvporcupine
import sounddevice as sd
from langchain.memory import ConversationBufferMemory
from langchain.schema import messages_from_dict, messages_to_dict
from langchain_community.chat_models import ChatOllama
from langchain_core.runnables import RunnableLambda
from langgraph.graph import END, StateGraph

from config.app_config import setup_logging
from mini_project.modalities.FOR_SHAPES.command_processor import CommandProcessor
from mini_project.modalities.FOR_SHAPES.llm_main_langchain import (
    classify_command,
    generate_llm_greeting,
    handle_general_query,
    process_task,
    query_scene,
    trigger_remote_vision_task,
)
from mini_project.modalities.FOR_SHAPES.prompt_utils import PromptBuilder
from mini_project.modalities.FOR_SHAPES.voice_processor import (
    SpeechSynthesizer,
    VoiceProcessor,
)
from mini_project.workflow.session_manager import SessionManager

import sys

sys.setrecursionlimit(1000)

# === Setup Wake Word Detection ===
PICOVOICE_ACCESS_KEY = "E0O2AD01eT6cJ83n1yYf5bekfdIOEGUky9q6APkwdx9enDaMLZQtLw=="
# WAKEWORD = (
#     r"C:\Users\oscik559\Projects\mini_project_repo\assets\robot_wakewords\hey_yummy.ppn"
# )
WAKEWORD = os.path.abspath("assets/robot_wakewords/hey_yummy.ppn")

WAKE_RESPONSES = [
    "yes?",
    "I'm listening",
    "what's up?",
    "go ahead.",
    "at your service.",
    "hello?",
    "I'm here!",
    "you called?",
    "what do you want?",
    "I'm listening.",
    "hi?",
    "what is it?",
]
# Use built-in or custom model path
porcupine = pvporcupine.create(
    access_key=PICOVOICE_ACCESS_KEY,
    keywords=[
        "jarvis",
        "computer",
    ],
    keyword_paths=[WAKEWORD],
)
import logging

logger = logging.getLogger("LangChainGraph")

# === LangChain Memory ===
CHAT_MEMORY_FOLDER = "assets/chat_memory"
os.makedirs(CHAT_MEMORY_FOLDER, exist_ok=True)
llm = ChatOllama(model="llama3.2:latest")
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")

# === Shared Modules ===
session = SessionManager()
vp = VoiceProcessor()
tts = SpeechSynthesizer()


# === Chat Memory ===
def load_chat_history(liu_id):
    path = os.path.join(CHAT_MEMORY_FOLDER, f"chat_memory_{liu_id}.json")
    if os.path.exists(path):
        with open(path, "r") as f:
            messages = json.load(f)
            memory.chat_memory.messages = messages_from_dict(messages)


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

    tts.speak(random.choice(WAKE_RESPONSES))
    return state


def authenticate_user_node(state):
    logger.info("🔐 Running authentication...")
    user = session.authenticate_user()
    if not user:
        tts.speak("Authentication failed. Goodbye.")
        exit()
    state["user"] = user
    load_chat_history(user["liu_id"])
    greeting = generate_llm_greeting()
    tts.speak(greeting)
    tts.speak(f"Hello {user['first_name']}. How can I assist you today?")
    return state


def voice_input_node(state):
    result = vp.capture_voice()
    if not result:
        tts.speak("Sorry, I didn’t catch that. Please try again.")
        return state  # stay in current state

    text, lang = result

    if text.lower() in {"exit", "quit", "goodbye", "stop"}:
        tts.speak("Okay, goodbye!")
        exit(0)
    elif "reset memory" in text.lower():
        memory.clear()
        try:
            os.remove(
                os.path.join(
                    CHAT_MEMORY_FOLDER,
                    f"chat_memory_{state['user']['liu_id']}.json",
                )
            )
        except:
            pass
        tts.speak("Memory reset complete.")
        return state
    state["transcribed_text"] = text
    state["lang"] = lang
    logger.info(f"🎤 You said: {text}")
    return state


def classify_node(state):
    cmd = state.get("transcribed_text")
    if not cmd:
        logger.info(f"⚠️ Warning: No transcribed text found. Skipping classification.")
        return state

    state["command_type"] = classify_command(cmd, llm)
    return state


def general_node(state):
    user = state.get("user")
    command = state.get("transcribed_text")
    if not user or not command:
        logger.info("⚠️ Skipping general query: Missing user or command.")
        return state

    # Updated call with 2 args (compatible with the function definition)
    state["reply"] = handle_general_query(command, llm, user)
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
        "(sings)": "la la laaa 🎶"
    }
    for cue, phonetic in replacements.items():
        text = text.replace(cue, phonetic)
    return text


def scene_node(state):

    state["reply"] = query_scene(state["transcribed_text"])
    return state


def trigger_node(state):
    state["reply"] = trigger_remote_vision_task(state["transcribed_text"])
    return state


def task_confirm_node(state):
    tts.speak("Should I go ahead with a task plan?")
    result = vp.capture_voice()
    if result:
        confirmation = (
            result[0].lower().translate(str.maketrans("", "", string.punctuation))
        )
        if any(word in confirmation for word in ["yes", "sure", "okay", "go ahead"]):
            state["confirmed"] = True
        else:
            state["confirmed"] = False
    else:
        state["confirmed"] = False
    return state


def task_plan_node(state):
    if not state.get("confirmed"):
        tts.speak("Okay, discarding the task.")
        return state
    vp.storage.store_instruction(
        vp.session_id, state["lang"], state["transcribed_text"]
    )
    state["reply"] = process_task(state["transcribed_text"])
    return state


def respond_node(state):
    if state.get("reply"):
        tts.speak(state["reply"])
    return state


def save_and_repeat(state):
    save_chat_history(state["user"]["liu_id"])
    return state


def should_continue_node(state):
    text = state.get("transcribed_text", "").lower()
    if text in {"exit", "quit", "goodbye", "stop"}:
        tts.speak("👋 Okay, ending the session.")
        return {"__state__": state, "__next__": "end"}
    return {"__state__": state, "__next__": "continue"}


# === Build LangGraph ===
graph = StateGraph(state_schema=MyState)

graph.add_node("authenticate_user", authenticate_user_node)
graph.add_node("wait_for_wake_word", wait_for_wake_word_node)
graph.add_node("voice_input", voice_input_node)
graph.add_node("classify", classify_node)
graph.add_node("general_query", general_node)
graph.add_node("scene_query", scene_node)
graph.add_node("trigger_task", trigger_node)
graph.add_node("confirm_task", task_confirm_node)
graph.add_node("plan_task", task_plan_node)
graph.add_node("respond", respond_node)
graph.add_node("save_and_repeat", save_and_repeat)
graph.add_node("should_continue", should_continue_node)


# Edges
graph.set_entry_point("authenticate_user")
graph.add_edge("authenticate_user", "wait_for_wake_word")
graph.add_edge("wait_for_wake_word", "voice_input")
graph.add_edge("voice_input", "classify")
graph.add_conditional_edges(
    "classify",
    lambda x: x["command_type"],
    {
        "general": "general_query",
        "scene": "scene_query",
        "trigger": "trigger_task",
        "task": "confirm_task",
    },
)
graph.add_edge("general_query", "respond")
graph.add_edge("scene_query", "respond")
graph.add_edge("trigger_task", "respond")
graph.add_edge("confirm_task", "plan_task")
graph.add_edge("plan_task", "respond")
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
    setup_logging()
    graph.invoke(
        {
            "user": None,
            "transcribed_text": None,
            "lang": None,
            "command_type": None,
            "reply": None,
            "confirmed": None,
        }
    )

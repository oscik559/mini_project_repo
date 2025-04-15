# langgraph_llm_main.py

from langgraph.graph import StateGraph, END
from typing import TypedDict
from typing import Annotated

from langchain_core.runnables import RunnableLambda
from langchain.memory import ConversationBufferMemory
from langchain_ollama import ChatOllama
from langchain_core.prompts import PromptTemplate
from config.app_config import setup_logging

from mini_project.database.connection import get_connection
from mini_project.modalities.FOR_SHAPES.command_processor_pgSQL import CommandProcessor
from mini_project.modalities.FOR_SHAPES.voice_processor_pgSQL import (
    VoiceProcessor,
    SpeechSynthesizer,
)
from mini_project.modalities.FOR_SHAPES.prompt_utils import PromptBuilder
from datetime import datetime
import logging, os, re, string, random, requests, time
from datetime import datetime, timedelta

# === Setup ===
logging.getLogger("comtypes").setLevel(logging.WARNING)
logger = logging.getLogger("LangGraphYumi")

# === LLM Setup ===
OLLAMA_MODEL = "llama3.2:latest"
llm = ChatOllama(model=OLLAMA_MODEL)

# === Memory + TTS Singletons ===
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")
tts = SpeechSynthesizer()


# === Known Keywords ===
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
QUESTION_WORDS = {"what", "where", "which", "who", "how many", "is there", "are there"}
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

# === Scene Prompt Template ===
SCENE_PROMPT_TEMPLATE = PromptBuilder.scene_prompt_template()


# === State Type ===
class AssistantState(TypedDict, total=False):
    vp: VoiceProcessor
    request: Annotated[str, "output"]
    lang: Annotated[str, "output"]
    cmd_type: Annotated[str, "output"]
    confirmed: Annotated[bool, "output"]
    end: Annotated[bool, "output"]
    greeted: bool


def greet_user(state: AssistantState, tts: SpeechSynthesizer):
    if not state.get("greeted"):
        greeting = generate_llm_greeting()
        tts.speak(greeting)
        logger.info("[Greet] Setting greeted = True")

        return {**state, "greeted": True, "end": False}
    return {"greeted": True, **state}


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
        print(response)
        return response.content.strip().strip('"“”') or seed
    except Exception as e:
        logger.error(f"Greeting failed: {e}")
        return fallback_llm_greeting(seed)


def fallback_llm_greeting(seed_greeting):
    try:
        response = llm.invoke(
            [
                {
                    "role": "system",
                    "content": "You are a friendly assistant that creates warm spoken greetings.",
                },
                {
                    "role": "user",
                    "content": f"Improve this fallback greeting for voice use: '{seed_greeting}'",
                },
            ]
        )
        return response.content.strip().strip('"“”')
    except Exception:
        return seed_greeting


# === State Functions ===
def capture_voice(state: AssistantState, vp: VoiceProcessor, tts: SpeechSynthesizer):
    result = vp.capture_voice(conversational=True)

    if result is None:
        logger.info("🟡 No speech detected. Could you try again.")
        return {
            "retry": True,
        }

    logger.info(f"📢 You said: {result[0]}")
    # tts.speak(f"You said: {result[0]}")
    return {
        "request": result[0],
        "lang": result[1],
        "retry": False,  # explicitly say we're not retrying now
    }


def classify_request(state: AssistantState, tts: SpeechSynthesizer):

    request = state["request"].lower().strip()

    # End session?
    if any(q in request for q in {"exit", "quit", "goodbye", "stop"}):
        tts.speak("Okay, goodbye!")
        return {"end": True}

    # Reset memory?
    if request in {"reset memory", "clear memory"}:
        memory.clear()
        tts.speak("Memory has been reset.")
        return {"end": False}

    # Use an LLM to classify as "scene" or "task"
    try:
        result = llm.invoke(
            [
                {
                    "role": "system",
                    "content": "Classify the user request as either 'scene' or 'task'.",
                },
                {"role": "user", "content": request},
            ]
        )
        label = result.content.strip().lower()
        if label in {"scene", "task"}:
            return {"cmd_type": label, **state}
    except:
        pass

    # Fallback keyword detection
    if any(request.startswith(q) for q in QUESTION_WORDS):
        return {"cmd_type": "scene", **state}
    if any(v in request for v in TASK_VERBS):
        return {"cmd_type": "task", **state}
    return {"cmd_type": "task", **state}


def query_scene(state: AssistantState, tts: SpeechSynthesizer):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """SELECT object_name, object_color, pos_x, pos_y, pos_z,
                  rot_x, rot_y, rot_z, last_detected, usd_name
           FROM camera_vision"""
    )
    objects = cursor.fetchall()
    cursor.close()
    conn.close()

    if not objects:
        answer = "I can only see the camera. No other objects are currently visible."
    else:
        formatted = "\n".join(
            f"- {n} ({c}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f})"
            for n, c, x, y, z, r, p, w, *_ in objects
        )
        input_data = {
            "question": state["request"],
            "data": formatted,
            "chat_history": memory.load_memory_variables({})["chat_history"],
        }
        prompt_msg = SCENE_PROMPT_TEMPLATE.format_prompt(**input_data)
        result = llm.invoke(prompt_msg.to_string())
        memory.save_context(
            {"question": input_data["question"]}, {"answer": result.content}
        )
        answer = result.content
    tts.speak(answer)
    return {"end": False, **state}


def confirm_task(state: AssistantState, tts: SpeechSynthesizer):
    tts.speak("Should I go ahead and plan this task?")
    result = state["vp"].capture_voice()

    if not result:
        tts.speak("No confirmation heard. Skipping the task.")
        return {
            "vp": state["vp"],
            "tts": tts,
            "end": False,
            "retry": False,
        }

    cleaned = result[0].lower().translate(str.maketrans("", "", string.punctuation))
    if any(w in cleaned for w in CANCEL_WORDS):
        tts.speak("Okay, I won't execute the task.")
        return {
            "vp": state["vp"],
            "tts": tts,
            "end": False,
            "retry": False,
        }

    if any(w in cleaned for w in CONFIRM_WORDS):
        state["vp"].storage.store_instruction(
            state["vp"].session_id, state["lang"], state["request"]
        )
        return {
            "vp": state["vp"],
            "tts": tts,
            "confirmed": True,
            "request": state["request"],
            "lang": state["lang"],
            "end": False,
        }

    tts.speak("I wasn't sure what you meant. Skipping the task.")
    return {
        "vp": state["vp"],
        "tts": tts,
        "end": False,
        "retry": False,
    }


def process_task(state: AssistantState, tts: SpeechSynthesizer):
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
            state["request"],
            "",
            state["request"],
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
        {"id": command_id, "unified_command": state["request"]}
    )
    processor.close()
    answer = (
        "The task has been planned and added successfully."
        if success
        else "Sorry, I couldn't understand the task."
    )
    tts.speak(answer)
    return {"end": False, **state}


# === Build Graph ===
graph = StateGraph(state_schema=AssistantState)

graph.add_node("Greet", RunnableLambda(lambda state: greet_user(state, tts)))
graph.add_node("Capture", RunnableLambda(lambda state: capture_voice(state, vp, tts)))
graph.add_node("Classify", RunnableLambda(lambda state: classify_request(state, tts)))
graph.add_node("Scene", RunnableLambda(lambda state: query_scene(state, tts)))
graph.add_node("Confirm", RunnableLambda(lambda state: confirm_task(state, vp, tts)))
graph.add_node("Execute", RunnableLambda(lambda state: process_task(state, tts)))

graph.set_entry_point("Greet")

graph.add_edge("Greet", "Capture")  # Go directly from Greet ➝ Capture
graph.add_edge("Capture", "Classify")
graph.add_conditional_edges(
    "Classify", lambda x: x.get("cmd_type"), {"scene": "Scene", "task": "Confirm"}
)
graph.add_edge("Scene", END)
graph.add_conditional_edges(
    "Confirm",
    lambda st: "Execute" if st.get("confirmed") else END,
    {"Execute": "Execute"},
)
graph.add_edge("Execute", END)
graph.add_conditional_edges(
    "Capture",
    lambda st: "Capture" if st.get("retry") else "Classify",
    {
        "Capture": "Capture",
        "Classify": "Classify",
    },
)


app = graph.compile()
print(app.get_graph().draw_mermaid())


if __name__ == "__main__":
    setup_logging()
    vp = VoiceProcessor()
    tts = SpeechSynthesizer()

    # Initialize
    state = {
        "greeted": False,
    }
    greeted_once = False

    entry_point = "Greet"
    while True:
        try:
            result = app.invoke(state, config={"entry_point": entry_point})
            updated_state = result.get("__end__", result)

            # 🔸 Switch entry point AFTER first greet
            if entry_point == "Greet" and updated_state.get("greeted"):
                entry_point = "Capture"

            # Update greeting flag
            state["greeted"] = updated_state.get("greeted", False)

            # Handle end
            if updated_state.get("end"):
                print("👋 Ending session.")
                break

            state = updated_state

        except Exception as e:
            print(f"[❌] Error during graph execution: {e}")
            break

        print("🟡 Listening again in a few seconds... (Ctrl+C to stop)")
        time.sleep(1)

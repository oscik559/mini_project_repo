import asyncio
import logging
from typing import AsyncGenerator, Literal, Optional, TypedDict

from langgraph.graph import END, StateGraph

from mini_project.modalities.FOR_SHAPES.command_processor import CommandProcessor
from mini_project.modalities.FOR_SHAPES.llm_main_langchain import (
    classify_command,
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

logger = logging.getLogger("LangGraph")
session = SessionManager()
tts = SpeechSynthesizer()
vp = VoiceProcessor()


class GraphState(TypedDict):
    user: Optional[dict]
    transcribed_text: Optional[str]
    lang: Optional[str]
    command_type: Optional[Literal["task", "scene", "general", "trigger"]]
    reply: Optional[str]


async def authenticate_user_node(state: GraphState) -> GraphState:
    user = session.authenticate_user()
    if not user:
        tts.speak("Authentication failed. Goodbye.")
        exit(0)
    session.create_session()
    tts.speak(f"Hello {user['first_name']}. How can I assist you today?")
    return {"user": user}


async def voice_input_node(state: GraphState) -> GraphState:
    import struct

    import pvporcupine
    import sounddevice as sd

    # Wake word detection setup
    porcupine = pvporcupine.create(
        keywords=["jarvis"]
    )  # Replace with your custom keyword
    stream = sd.RawInputStream(
        samplerate=porcupine.sample_rate,
        blocksize=porcupine.frame_length,
        dtype="int16",
        channels=1,
    )

    print("🔊 Listening for wake word...")
    with stream:
        while True:
            audio = stream.read(porcupine.frame_length)[0]
            pcm = struct.unpack_from("h" * porcupine.frame_length, audio)
            if porcupine.process(pcm) >= 0:
                print("🎤 Wake word detected!")
                break

    result = vp.capture_voice(conversational=True)
    if result is None:
        tts.speak("I didn't catch that. Could you please repeat?")
        return {"transcribed_text": None, "lang": None}
    request, lang = result
    logger.info(f"🎤 You said: {request}")
    return {"transcribed_text": request, "lang": lang}
    result = vp.capture_voice(conversational=True)
    if result is None:
        tts.speak("I didn't catch that. Could you please repeat?")
        return {"transcribed_text": None, "lang": None}
    request, lang = result
    logger.info(f"🎤 You said: {request}")
    return {"transcribed_text": request, "lang": lang}


async def classify_node(state: GraphState) -> GraphState:
    command_type = classify_command(state["transcribed_text"], session.llm)
    return {"command_type": command_type}


async def general_query_node(state: GraphState) -> GraphState:
    from langchain_core.runnables import Runnable

    # Assuming handle_general_query uses a Runnable LLM chain
    chain: Runnable = handle_general_query(state["transcribed_text"], session.llm)
    streamed_response = ""
    async for chunk in chain.astream({"command": state["transcribed_text"]}):
        if chunk:
            print(chunk, end="", flush=True)
            streamed_response += chunk
            tts.speak(chunk)  # Optional: make this real-time with non-blocking TTS
    return {"reply": streamed_response}
    response = handle_general_query(state["transcribed_text"], session.llm)
    return {"reply": response}


async def trigger_task_node(state: GraphState) -> GraphState:
    response = trigger_remote_vision_task(state["transcribed_text"])
    return {"reply": response}


async def scene_query_node(state: GraphState) -> GraphState:
    response = query_scene(state["transcribed_text"])
    return {"reply": response}


async def task_plan_node(state: GraphState) -> GraphState:
    tts.speak("Should I plan this task?")
    confirm = vp.capture_voice()
    if not confirm:
        return {"reply": "Task confirmation not received. Skipping."}
    confirm_text = confirm[0].lower()
    if any(word in confirm_text for word in {"no", "cancel", "not now"}):
        return {"reply": "Okay, discarding the task."}
    if any(word in confirm_text for word in {"yes", "sure", "okay"}):
        tts.speak("Okay, planning task...")
        vp.storage.store_instruction(
            vp.session_id, state["lang"], state["transcribed_text"]
        )
        result = process_task(state["transcribed_text"])
        return {"reply": result}
    return {"reply": "Confirmation unclear. Task not executed."}


async def respond_node(state: GraphState) -> GraphState:
    tts.speak(state["reply"] or "I have nothing to say.")
    return state


async def loop_or_exit_node(state: GraphState) -> Literal["voice_input", "__end__"]:
    tts.speak("Would you like to continue?")
    confirm = vp.capture_voice()
    if confirm:
        text = confirm[0].lower()
        if any(x in text for x in {"no", "stop", "exit", "quit"}):
            return "__end__"
    return "voice_input"


# Define the graph with async nodes
graph = StateGraph(GraphState)

graph.add_node("authenticate_user", authenticate_user_node)
graph.add_node("voice_input", voice_input_node)
graph.add_node("classify", classify_node)
graph.add_node("general_query", general_query_node)
graph.add_node("scene_query", scene_query_node)
graph.add_node("trigger_task", trigger_task_node)
graph.add_node("task_plan", task_plan_node)
graph.add_node("respond", respond_node)
graph.add_node("loop_or_exit", loop_or_exit_node)

graph.set_entry_point("authenticate_user")
graph.add_edge("authenticate_user", "voice_input")
graph.add_edge("voice_input", "classify")

graph.add_conditional_edges(
    "classify",
    lambda state: state["command_type"],
    {
        "general": "general_query",
        "scene": "scene_query",
        "trigger": "trigger_task",
        "task": "task_plan",
    },
)

graph.add_edge("general_query", "respond")
graph.add_edge("scene_query", "respond")
graph.add_edge("trigger_task", "respond")
graph.add_edge("task_plan", "respond")
graph.add_edge("respond", "loop_or_exit")
graph.add_conditional_edges(
    "loop_or_exit",
    loop_or_exit_node,
    {"voice_input": "voice_input", "__end__": END},
)

langgraph_app = graph.compile()


# Example async runner
async def run_async_graph():
    state = {}
    async for step in langgraph_app.astream(state):
        result = step.get("reply") or step.get("transcribed_text") or str(step)
        if result:
            print("🔁 Step result:", result)
        await asyncio.sleep(0.1)
    state = {}
    async for step in langgraph_app.astream(state):
        print("\n🔁 Step result:", step)


# To run: asyncio.run(run_async_graph())
if __name__ == "__main__":
    asyncio.run(run_async_graph())

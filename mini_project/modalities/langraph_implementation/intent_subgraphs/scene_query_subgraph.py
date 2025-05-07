# intent_subgraphs/scene_query_subgraph.py
from langchain_core.runnables import RunnableLambda
from langchain_ollama import ChatOllama
from langgraph.graph import StateGraph

from mini_project.database.connection import get_connection
from mini_project.modalities.prompt_utils import PromptBuilder

llm = ChatOllama(model="llama3.2:latest")


class SceneState(dict):
    transcribed_text: str
    reply: str


def fetch_camera_objects():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute(
            """
            SELECT object_name, object_color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, last_detected, usd_name
            FROM camera_vision
            """
        )
        return cursor.fetchall()


def format_camera_data(objects: list) -> str:
    return "\n".join(
        f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) with orientation ({r:.1f}, {p:.1f}, {w:.1f}), last seen: {t}, usd: {usd}"
        for name, color, x, y, z, r, p, w, t, usd in objects
    )


def build_chain_with_input(input_data):
    return (
        PromptBuilder.scene_prompt_template()
        | llm
        | RunnableLambda(lambda o: {"reply": o.content})
    )


def scene_query_node(state):
    question = state.get("transcribed_text")
    try:
        objects = fetch_camera_objects()
        if not objects:
            state["reply"] = (
                "I can only see the camera. No other objects are currently visible."
            )
            return state
        formatted = format_camera_data(objects)
        input_data = {"question": question, "data": formatted}
        result = build_chain_with_input(input_data).invoke(input_data)
        state.update(result)
    except Exception as e:
        state["reply"] = f"Scene query failed: {str(e)}"
    return state


def get_scene_query_subgraph():
    sg = StateGraph(SceneState)
    sg.add_node("scene_query", scene_query_node)
    sg.set_entry_point("scene_query")
    sg.set_finish_point("scene_query")
    return sg.compile()

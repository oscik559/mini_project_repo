# intent_subgraphs/general_query_subgraph.py
from langchain.memory import ConversationBufferMemory
from langchain_ollama import ChatOllama
from langgraph.graph import StateGraph

from mini_project.database.connection import get_connection
from mini_project.modalities.prompt_utils import PromptBuilder

llm = ChatOllama(model="llama3.2:latest")
memory = ConversationBufferMemory(memory_key="chat_history", input_key="question")


class GeneralState(dict):
    user: dict
    transcribed_text: str
    reply: str


def get_team_names():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT first_name FROM users WHERE role = 'team'")
        return [row[0] for row in cursor.fetchall()]


def get_environment_context():
    from datetime import datetime

    import requests

    now = datetime.now()
    hour = now.hour
    part_of_day = "morning" if hour < 12 else "afternoon" if hour < 18 else "evening"
    try:
        data = requests.get(
            "https://api.open-meteo.com/v1/forecast?latitude=58.41&longitude=15.62&current_weather=true"
        ).json()
        weather = data["current_weather"]
        return (
            f"{round(weather['temperature'])}C, wind {weather['windspeed']} km/h",
            part_of_day,
        )
    except:
        return "unknown weather", part_of_day


def general_node(state):
    user = state.get("user")
    command = state.get("transcribed_text")
    if not user or not command:
        state["reply"] = "Missing user or command"
        return state

    weather, part_of_day = get_environment_context()
    prompt = PromptBuilder.general_conversation_prompt(
        first_name=user["first_name"],
        liu_id=user["liu_id"],
        role=user.get("role", "guest"),
        team_names=get_team_names(),
        weather=weather,
        part_of_day=part_of_day,
        full_time="N/A",
        chat_history=memory.load_memory_variables({})["chat_history"],
    )

    result = (prompt | llm).invoke({"command": command})
    state["reply"] = str(result.content).strip()
    return state


def get_general_query_subgraph():
    sg = StateGraph(GeneralState)
    sg.add_node("general", general_node)
    sg.set_entry_point("general")
    sg.set_finish_point("general")
    return sg.compile()

# intent_subgraphs/trigger_task_subgraph.py
from datetime import datetime

from langgraph.graph import StateGraph

from mini_project.database.connection import get_connection


class TriggerState(dict):
    transcribed_text: str
    reply: str


def trigger_node(state):
    cmd = state.get("transcribed_text", "").lower()
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute(
            "SELECT operation_name, trigger_keywords, trigger FROM operation_library WHERE is_triggerable = TRUE"
        )
        ops = cursor.fetchall()

        matched = None
        for op_name, keywords, is_triggered in ops:
            if keywords and any(k in cmd for k in keywords):
                matched = (op_name, is_triggered)
                break

        if matched:
            op_name, is_triggered = matched
            if is_triggered:
                state["reply"] = f"The script '{op_name}' is already running."
            else:
                cursor.execute(
                    "UPDATE operation_library SET trigger = FALSE WHERE trigger = TRUE"
                )
                cursor.execute(
                    """
                    UPDATE operation_library SET trigger = TRUE, state = 'triggered', last_triggered = %s
                    WHERE operation_name = %s
                    """,
                    (datetime.now(), op_name),
                )
                conn.commit()
                state["reply"] = f"Now running the detection script for '{op_name}'."
        else:
            state["reply"] = "Sorry, I couldn't match any vision task to your request."
    return state


def get_trigger_task_subgraph():
    sg = StateGraph(TriggerState)
    sg.add_node("trigger", trigger_node)
    sg.set_entry_point("trigger")
    sg.set_finish_point("trigger")
    return sg.compile()

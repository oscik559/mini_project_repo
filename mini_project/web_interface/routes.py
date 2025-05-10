# mini_project/web_interface/routes.py

from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from mini_project.database.connection import get_connection

from mini_project.modalities.voice_assistant import VoiceAssistant

router = APIRouter()
templates = Jinja2Templates(directory="mini_project/web_interface/templates")

# Initialize assistant
assistant = VoiceAssistant()


@router.get("/", response_class=HTMLResponse)
async def homepage(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


# @router.post("/start-session")
# async def start_session():
#     success, msg = assistant.start_session()
#     return {"success": success, "message": msg}
@router.post("/start-session")
async def start_session():
    success, msg = assistant.start_session()
    return {
        "success": success,
        "message": msg,
        "username": assistant.authenticated_user.get("first_name") if assistant.authenticated_user else None,
        "model": assistant.selected_model
    }


@router.post("/send-command")
async def send_command(command: str = Form(...)):
    response = assistant.process_input_command(command)
    return {"response": response}


@router.post("/reset-memory")
async def reset_memory():
    assistant.reset_memory()
    return {"message": "Memory reset successfully."}


@router.get("/view-db/{table_name}")
def view_db(table_name: str):
    allowed_tables = [
        "camera_vision",
        "users",
        "operation_sequence",
        "unified_instructions",
        "sort_order",
        "sequence_library",
    ]
    if table_name not in allowed_tables:
        return {"error": "Table not allowed."}

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name} LIMIT 50")
    rows = cursor.fetchall()
    columns = [desc[0] for desc in cursor.description]

    # Ensure every row is a list of stringifiable items
    serialized_rows = [
        [str(cell) if not isinstance(cell, (int, float)) else cell for cell in row]
        for row in rows
    ]

    return {"columns": columns, "rows": serialized_rows, "count": len(serialized_rows)}


@router.post("/set-model")
async def set_model(request: Request):
    payload = await request.json()
    model = payload.get("model")
    if not model:
        return {"error": "No model specified"}

    assistant.set_llm_model(model)
    return {"message": f"✅ Model set to {model}"}


# @router.get("/session-info")
# def session_info():
#     return {
#         "status": "active",
#         "username": assistant.session.get("username"),
#         "liu_id": assistant.session.get("liu_id"),
#         "role": assistant.session.get("role"),
#         "memory_file": assistant.chat_memory_path.name if assistant.chat_memory_path else None
#     }

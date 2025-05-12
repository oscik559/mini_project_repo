# mini_project/web_interface/routes.py
from fastapi import UploadFile, File
from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from mini_project.database.connection import get_connection
from mini_project.authentication._face_auth import FaceAuthSystem
from mini_project.authentication._voice_auth import VoiceAuth

from mini_project.modalities.voice_assistant import VoiceAssistant

router = APIRouter()
templates = Jinja2Templates(directory="mini_project/web_interface/templates")

# Initialize assistant
assistant = VoiceAssistant()


@router.get("/", response_class=HTMLResponse)
async def homepage(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})



@router.post("/start-session")
async def start_session():
    success, msg = assistant.start_session()
    return {
        "success": success,   # <-- FIXED: use actual result
        "message": msg,
        "username": (
            assistant.authenticated_user.get("first_name")
            if assistant.authenticated_user
            else None
        ),
        "model": assistant.selected_model,
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

from fastapi import UploadFile, File, Form

@router.post("/register-user")
async def register_user(
    first_name: str = Form(...),
    last_name: str = Form(...),
    liu_id: str = Form(...),
    email: str = Form(...),
    face: UploadFile = File(...),
    voice: UploadFile = File(...)
):
    # Save uploaded files
    face_path = f"temp_images/{liu_id}_face.png"
    voice_path = f"temp_audio/{liu_id}_voice.webm"
    with open(face_path, "wb") as f:
        f.write(await face.read())
    with open(voice_path, "wb") as f:
        f.write(await voice.read())

    # Process face registration
    try:
        face_auth = FaceAuthSystem()
        # You need to implement a method that takes an image path and user info
        face_success = face_auth.register_user_from_image(
            face_path, first_name, last_name, liu_id, email
        )
        # Process voice registration
        voice_auth = VoiceAuth()
        voice_success = voice_auth.register_voice_for_user_from_file(
            first_name, last_name, liu_id, voice_path
        )
        if face_success and voice_success:
            return {"message": f"✅ User {first_name} registered (face/voice captured)."}
        else:
            return {"message": f"❌ Registration failed (face or voice not captured)."}
    except Exception as e:
        return {"message": f"❌ Registration failed: {str(e)}"}

# @router.post("/process-voice")
# async def process_voice():
#     result = assistant.vp.capture_voice()
#     if not result:
#         return {"transcription": ""}
#     command_text, lang = result
#     return {"transcription": command_text, "lang": lang}



@router.post("/process-voice")
async def process_voice(audio: UploadFile = File(None)):
    if audio:
        audio_path = f"temp_audio/{audio.filename}"
        with open(audio_path, "wb") as f:
            f.write(await audio.read())
        command_text, lang = assistant.vp.transcribe_audio(audio_path)
        return {"transcription": command_text, "lang": lang}
    else:
        result = assistant.vp.capture_voice()
        if not result:
            return {"transcription": ""}
        command_text, lang = result
        return {"transcription": command_text, "lang": lang}

@router.post("/llm-response")
async def llm_response(request: Request):
    data = await request.json()
    command_text = data.get("command_text")
    lang = data.get("lang", "en")
    response = assistant.process_input_command(command_text, lang)
    return {"response": response}

# @router.get("/session-info")
# def session_info():
#     return {
#         "status": "active",
#         "username": assistant.session.get("username"),
#         "liu_id": assistant.session.get("liu_id"),
#         "role": assistant.session.get("role"),
#         "memory_file": assistant.chat_memory_path.name if assistant.chat_memory_path else None
#     }

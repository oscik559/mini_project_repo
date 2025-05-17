# mini_project/web_interface/routes.py
"""
This module defines the API routes for the web interface of the mini_project application using FastAPI.
Routes:
    - GET /: Render the homepage using Jinja2 templates.
    - POST /start-session: Start a new authentication session with the voice assistant.
    - POST /send-command: Send a text command to the voice assistant and receive a response.
    - POST /reset-memory: Reset the assistant's memory.
    - GET /view-db/{table_name}: View up to 50 rows from an allowed database table.
    - POST /set-model: Set the language model used by the assistant.
    - POST /register-user: Register a new user with face and voice data.
    - POST /process-voice: Process uploaded or captured voice audio and return transcription.
    - POST /llm-response: Get a response from the assistant's language model for a given command.
Dependencies:
    - FastAPI for API routing and request handling.
    - Jinja2 for HTML templating.
    - Custom modules for database connection, face and voice authentication, and the voice assistant logic.
Note:
    - File uploads for face and voice are saved temporarily for processing.
    - Only specific database tables are allowed to be viewed via the API.
    - Error handling is included for user registration and voice processing.
"""


from fastapi import UploadFile, File
from fastapi import APIRouter, Request, Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
from mini_project.database.connection import get_connection
from mini_project.authentication._face_auth import FaceAuthSystem
from mini_project.authentication._voice_auth import VoiceAuth
from mini_project.modalities.voice_assistant import VoiceAssistant

from mini_project.config.app_config import TEMP_AUDIO_PATH, TEMP_IMAGE_PATH

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
        "authenticated": success,  # <-- FIXED: use actual result
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
    voice: UploadFile = File(...),
):
    # Save uploaded files
    temp_image_dir = TEMP_IMAGE_PATH
    temp_image_dir.mkdir(parents=True, exist_ok=True)
    temp_audio_dir = TEMP_AUDIO_PATH
    temp_audio_dir.mkdir(parents=True, exist_ok=True)

    face_path = temp_image_dir / f"{liu_id}_face.png"
    voice_path = temp_audio_dir / f"{liu_id}_voice.webm"
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
            return {
                "message": f"✅ User {first_name} registered (face/voice captured)."
            }
        else:
            return {"message": f"❌ Registration failed (face or voice not captured)."}
    except Exception as e:
        return {"message": f"❌ Registration failed: {str(e)}"}


#########################################################################################
# @router.post("/process-voice")
# async def process_voice(audio: UploadFile = File(None)):
#     if audio:
#         audio_path = f"temp_audio/{audio.filename}"
#         with open(audio_path, "wb") as f:
#             f.write(await audio.read())
#         command_text, lang = assistant.vp.transcribe_audio(audio_path)
#         return {"transcription": command_text, "lang": lang}
#     else:
#         result = assistant.vp.capture_voice()
#         if not result:
#             return {"transcription": ""}
#         command_text, lang = result
#         return {"transcription": command_text, "lang": lang}
#########################################################################################

# ...existing code...
@router.post("/process-voice")
async def process_voice(audio: UploadFile = File(None)):
    if audio:
        temp_audio_dir = TEMP_AUDIO_PATH
        temp_audio_dir.mkdir(parents=True, exist_ok=True)
        audio_path = temp_audio_dir / audio.filename
        with open(audio_path, "wb") as f:
            f.write(await audio.read())
        # Use the correct method for transcription
        command_text, lang = assistant.vp.transcriber.transcribe_audio(str(audio_path))
        return {"transcription": command_text, "lang": lang}
    else:
        return {"transcription": ""}
# ...existing code...


@router.post("/llm-response")
async def llm_response(request: Request):
    data = await request.json()
    command_text = data.get("command_text")
    lang = data.get("lang", "en")
    response = assistant.process_input_command(command_text, lang)
    return {"response": response}




@router.post("/authenticate-user")
async def authenticate_user(face: UploadFile = File(...)):
    temp_dir = TEMP_IMAGE_PATH
    temp_dir.mkdir(parents=True, exist_ok=True)  # <-- Ensure directory exists
    temp_path = temp_dir / "auth_face.png"
    with open(temp_path, "wb") as f:
        f.write(await face.read())
    try:
        face_auth = FaceAuthSystem()
        user = face_auth.identify_user_from_image(str(temp_path))
        if user:
            return {
                "success": True,
                "first_name": user["first_name"],
                "liu_id": user["liu_id"],
                "message": f"✅ Welcome, {user['first_name']}!"
            }
        else:
            return {"success": False, "register": True, "message": "❌ Face not recognized. Please register."}
    except Exception as e:
        return {"success": False, "message": f"❌ Authentication error: {str(e)}"}
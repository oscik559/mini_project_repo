import logging

import requests

from config.app_config import setup_logging
from mini_project.database.connection import get_connection
from mini_project.modalities.voice_processor import SpeechSynthesizer, VoiceProcessor

logging.getLogger("comtypes").setLevel(logging.WARNING)

OLLAMA_MODEL = "mistral:latest"


# Minimal prompt for direct answers
SCENE_PROMPT_TEMPLATE = """
You are an intelligent robotic assistant, with the camera as your eye. Based on the objects in the scene, listed in the database from the camera_vision table, respond concisely and clearly to the user question. One line answers are acceptable.
if there are any, the objects here are sitting on a table, usually consisting of a tray containing some microscope slides in it, and a different seperate holder object. the holder is not a slide, and the slides are numbered as slide1, slide2, etc. in increments.
---
Each object has the following fields:
# - object_name: the name of the object in the scene. It could be a slide, a holder, or a tray, etc. slides object_name are usually Slide 1, Slide 2, etc. and have a usd_name of slide.usd
# - object_color: the color of the object in the scene
# - pos_x, pos_y, pos_z: the position of the object in the scene
# - rot_x, rot_y, rot_z: the orientation of the object in the scene
# - last detected: the last time the object was detected in the scene by the camera
---
User question: {question}
Objects in scene:
{data}
---
Answer:
"""


def call_llm(prompt: str) -> str:
    """Call the LLM using Ollama and return the response."""
    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": False},
            timeout=60,
        )
        if response.status_code != 200:
            logging.error(f"[LLM] Bad status: {response.status_code} | {response.text}")
            return "[LLM error: non-200 response]"

        result = response.json().get("response", "").strip()
        return result if result else "[LLM error: empty response]"

    except requests.exceptions.RequestException as e:
        logging.error(f"[LLM] Request failed: {e}")
        return "[LLM error: request failed]"
    except ValueError as e:
        logging.error(f"[LLM] JSON decode error: {e}")
        return "[LLM error: response parsing failed]"


def fetch_camera_objects() -> list:
    """Query the camera_vision table and return all objects."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT object_name, object_color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, last_detected, usd_name FROM camera_vision"
    )
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


def format_camera_data(objects: list) -> str:
    """Format object rows into a structured text for LLM input."""
    return "\n".join(
        f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f}) last detected at {time}, with usd_name as {usd_name}"
        for name, color, x, y, z, r, p, w, time, usd_name in objects
    )


def query_scene(question: str) -> str:
    setup_logging()
    objects = fetch_camera_objects()
    if not objects:
        return "The scene appears to be empty. No objects are currently visible."

    formatted_data = format_camera_data(objects)
    prompt = SCENE_PROMPT_TEMPLATE.format(question=question, data=formatted_data)
    response = call_llm(prompt)
    return response


def voice_to_scene_response():
    print("🎤 Speak your question about the scene...")

    tts = SpeechSynthesizer()
    tts.play_ping()  # 🔔 before recording

    vp = VoiceProcessor()
    vp.recorder.record_audio()

    if not vp.recorder.speech_detected:
        print("⚠️ No speech detected. Try again.")
        return

    print("🧠 Transcribing...")
    question, lang = vp.transcriber.transcribe_audio(vp.recorder.temp_audio_path)
    print(f"You asked: {question}")

    print("🤖 Thinking...")
    answer = query_scene(question)
    print("🤖:", answer)

    print("🔊 Speaking response...")
    tts.speak(answer)


# === CLI Entry Point ===
if __name__ == "__main__":
    print("🔁 Voice-controlled LLM Scene Query")
    setup_logging()

    while True:
        voice_to_scene_response()  # Will use SpeechSynthesizer inside
        again = input("Try another question? (y/n): ").strip().lower()
        if again != "y":
            break

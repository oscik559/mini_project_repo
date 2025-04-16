import logging
import os
import tempfile
import uuid

import pyttsx3
from gtts import gTTS
from langchain.chains import LLMChain
from langchain_community.chat_models import ChatOllama
from langchain_core.prompts import PromptTemplate
from playsound import playsound

from config.app_config import setup_logging
from mini_project.database.connection import get_connection
from mini_project.modalities.voice_processor_SQLite import VoiceProcessor

logging.getLogger("comtypes").setLevel(logging.WARNING)


# === CONFIGURATION ===
OLLAMA_MODEL = "mistral:latest"  # LLM model
voice_speed = 165  # TTS speed
use_gtts = False  # Set to True to use gTTS instead of pyttsx3

# === LangChain LLM Wrapper ===
llm = ChatOllama(model=OLLAMA_MODEL)

# === Prompt Template ===
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
if the object is a slide, it will have a usd_name of slide.usd, and the holder object will have a usd_name of holder.usd
any objects with object_name that does not start with "slide..." are not slides
---
dont use non-words like rot_x, pos_y, etc. in your answer. use the full words like position x, rotation y, etc.
---
User question: {question}
Objects in scene:
{data}
---
Answer:
"""

prompt = PromptTemplate.from_template(SCENE_PROMPT_TEMPLATE)
chain = LLMChain(llm=llm, prompt=prompt)


# === TTS ===
def speak(text: str):
    if use_gtts:
        try:
            temp_path = os.path.join(
                tempfile.gettempdir(), f"speech_{uuid.uuid4().hex}.mp3"
            )
            tts = gTTS(text=text)
            tts.save(temp_path)
            playsound(temp_path)
            os.remove(temp_path)
        except Exception as e:
            logging.error(f"gTTS error: {e}")
            print(f"[TTS failed] {text}")
    else:
        try:
            engine = pyttsx3.init()
            engine.setProperty("rate", voice_speed)
            engine.say(str(text))
            engine.runAndWait()
        except Exception as e:
            logging.error(f"pyttsx3 error: {e}")
            print(f"[TTS failed] {text}")


# === Fetch and Format Scene Data ===
def fetch_camera_objects() -> list:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT object_name, object_color, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, last_detected, usd_name
        FROM camera_vision
    """
    )
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


def format_camera_data(objects: list) -> str:
    return "\n".join(
        f"- {name} ({color}) at ({x:.1f}, {y:.1f}, {z:.1f}) oriented at ({r:.1f}, {p:.1f}, {w:.1f}) last seen at {time}, usd_name: {usd}"
        for name, color, x, y, z, r, p, w, time, usd in objects
    )


# === Scene Query Wrapper ===
def query_scene_with_chain(question: str) -> str:
    try:
        objects = fetch_camera_objects()
        formatted_data = format_camera_data(objects)
        response = chain.invoke({"question": question, "data": formatted_data})
        return response.get("text", str(response))
    except Exception as e:
        logging.error(f"Chain error: {e}")
        return "[Scene query failed.]"


# === Voice Interaction ===
def voice_to_scene_response():
    print("🎤 Speak your question about the scene...")
    vp = VoiceProcessor()
    vp.recorder.record_audio()

    if not vp.recorder.speech_detected:
        print("⚠️ No speech detected. Try again.")
        return

    print("🧠 Transcribing...")
    question, lang = vp.transcriber.transcribe_audio(vp.recorder.temp_audio_path)
    print(f"You asked: {question}")

    print("🤖 Thinking...")
    answer = query_scene_with_chain(question)
    print("🤖:", answer)

    print("🔊 Speaking response...")
    speak(answer)


# === CLI Entry Point ===
if __name__ == "__main__":
    engine = pyttsx3.init()
    voices = engine.getProperty("voices")
    # engine.setProperty("voice", voices[0].id) # Microsoft Hazel Desktop - English (Great Britain)
    # engine.setProperty(
    #     "voice", voices[1].id
    # )  #  Microsoft David Desktop - English (United States
    engine.setProperty(
        "voice", voices[2].id
    )  # Microsoft Zira Desktop - English (United States)

    setup_logging()
    while True:
        voice_to_scene_response()
        again = input("Try another question? (y/n): ").strip().lower()
        if again != "y":
            break

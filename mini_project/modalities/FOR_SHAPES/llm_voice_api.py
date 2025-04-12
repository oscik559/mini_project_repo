import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from mini_project.modalities.FOR_SHAPES.LLM_main_copy import (
    classify_command,
    generate_llm_greeting,
    memory,
    process_task,
    query_scene,
)

app = FastAPI(title="Yumi Voice Assistant API")


class CommandRequest(BaseModel):
    text: str


@app.get("/greet")
def get_greeting():
    greeting = generate_llm_greeting()
    return {"greeting": greeting}


@app.post("/ask")
def ask_yumi(req: CommandRequest):
    text = req.text.strip()
    cmd_type = classify_command(text, None)

    if text.lower() in {"exit", "quit", "stop"}:
        return JSONResponse(content={"message": "Goodbye!"}, status_code=200)

    if text.lower() in {"reset memory", "clear memory"}:
        memory.clear()
        return {"message": "Memory has been reset."}

    if cmd_type == "scene":
        answer = query_scene(text)
    else:
        answer = process_task(text)

    return {"type": cmd_type, "response": answer}


@app.get("/memory")
def get_memory():
    return {"chat_history": memory.load_memory_variables({})["chat_history"]}


if __name__ == "__main__":
    uvicorn.run("llm_voice_api:app", host="10.245.0.28", port=8000, reload=True)

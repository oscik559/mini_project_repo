import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "mini_project.web_interface.main:app", host="0.0.0.0", port=8000, reload=True
    )

# mini_project/web_interface/main.py

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from mini_project.web_interface.routes import router

app = FastAPI(title="Robot Assistant")

# Mount static files and templates (for HTML + JS)
app.mount("/static", StaticFiles(directory="mini_project/web_interface/static"), name="static")
templates = Jinja2Templates(directory="mini_project/web_interface/templates")

# Add route definitions
app.include_router(router)

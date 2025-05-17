# mini_project/web_interface/main.py
"""
This module initializes and configures the FastAPI application for the Robot Assistant web interface.
- Sets up the FastAPI app with a custom title.
- Mounts the static files directory for serving CSS, JS, and images.
- Configures Jinja2 templates for rendering HTML pages.
- Includes additional API and web routes from the `mini_project.web_interface.routes` module.
"""

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from mini_project.web_interface.routes import router

app = FastAPI(title="Robot Assistant")

# Mount static files and templates (for HTML + JS)
app.mount(
    "/static", StaticFiles(directory="mini_project/web_interface/static"), name="static"
)
templates = Jinja2Templates(directory="mini_project/web_interface/templates")

# Add route definitions
app.include_router(router)

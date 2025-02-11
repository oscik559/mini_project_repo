from setuptools import setup, find_packages

setup(
    name="mini_project",
    version="0.1.0",
    packages=find_packages(),  # This will include config, scripts, utils, etc.
    install_requires=[
        "opencv-python",
        "face_recognition",
        "faiss-cpu",  # or "faiss-gpu" if you use that
        "numpy",
    ],
    entry_points={
        "console_scripts": [
            "face_auth=mini_project.scripts.face_auth:main",
            "db_handler=mini_project.scripts.db_handler:main",
        ],
    },
)

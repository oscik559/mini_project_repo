
"""
Main GUI entry point for the mini_project.
Launches the application window or handles CLI fallback.
"""
import sys

from mini_project.workflow.task_manager import TaskManagerGUIApproach1


def main():
    app = TaskManagerGUIApproach1()
    app.run()

if __name__ == "__main__":
    main()
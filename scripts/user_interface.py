import tkinter as tk
from tkinter import messagebox
from db_handler import DatabaseHandler

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

from mini_project.scripts.voice_processor import VoiceProcessor
from mini_project.scripts.video_processor import VideoProcessor
from mini_project.scripts.llm_processor import InstructionProcessor

class UserInterface:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Multi_modal HRI System")
        self.root.geometry("400x500")
        self.status_label = tk.Label(self.root, text="", font=("Arial", 10))

        # Buttons
        tk.Label(self.root, text="Multi_modal HRI System", font=("Arial", 16)).pack(pady=10)

        tk.Button(self.root, text="Create Database", command=self.create_database, width=25).pack(pady=5)
        tk.Button(self.root, text="Activate Voice Processing", command=self.activate_voice_processing, width=25).pack(pady=5)
        tk.Button(self.root, text="Activate Video Processing", command=self.activate_video_processing, width=25).pack(pady=5)
        tk.Button(self.root, text="Run LLM Processing", command=self.run_llm_processing, width=25).pack(pady=5)
        tk.Button(self.root, text="Clear All Instructions", command=self.clear_instructions, width=25).pack(pady=5)

        self.status_label.pack(pady=20)

    def create_database(self):
        try:
            db_handler = DatabaseHandler()
            db_handler.populate_database()
            db_handler.close()
            self.status_label.config(text="Database created successfully!")
            messagebox.showinfo("Success", "Database created and populated successfully!")
        except Exception as e:
            self.status_label.config(text="Database creation failed!")
            messagebox.showerror("Error", f"Database creation failed: {e}")

    def activate_voice_processing(self):
        from mini_project.scripts.voice_processor import VoiceProcessor
        processor = VoiceProcessor()
        processor.capture_voice()
        self.status_label.config(text="Voice processing completed.")

    def activate_video_processing(self):
        from mini_project.scripts.video_processor import VideoProcessor
        processor = VideoProcessor(update_status_callback=lambda msg: self.status_label.config(text=msg))
        processor.process_video()
        # self.status_label.config(text="Video processing completed.")

    def run_llm_processing(self):
        from mini_project.scripts.llm_processor import InstructionProcessor
        processor = InstructionProcessor()
        processor.run_processing_cycle()
        self.status_label.config(text="LLM processing completed.")

    def clear_instructions(self):
        db_handler = DatabaseHandler()
        db_handler.cursor.execute("DELETE FROM instructions")
        db_handler.conn.commit()
        db_handler.close()
        self.status_label.config(text="All instructions cleared successfully!")
        messagebox.showinfo("Success", "All instructions cleared successfully!")

    def run(self):
        self.root.mainloop()


if __name__ == "__main__":
    ui = UserInterface()
    ui.run()

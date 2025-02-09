import tkinter as tk
from tkinter import messagebox
import sqlite3

class MainApplication:
    def __init__(self, root):
        self.root = root
        self.root.title("GUI - Robot Application")
        self.root.geometry("400x400")

        # Title
        title_label = tk.Label(root, text="Welcome Home!", font=("Garamond", 24, "bold"))
        title_label.pack(pady=40)

        # Buttons (Vertically aligned with hover effect and rounded corners)
        self.create_hover_button(root, text="Register", bg="#3498db", fg="white", command=self.open_register_window).pack(pady=20)
        self.create_hover_button(root, text="Login", bg="#2ecc71", fg="white", command=self.open_login_window).pack(pady=20)
        self.create_hover_button(root, text="Exit", bg="#e74c3c", fg="white", command=self.root.quit).pack(pady=20)

        # Footer
        footer_label = tk.Label(root, text="Linköping University", font=("Arial", 10), fg="gray")
        footer_label.pack(side=tk.BOTTOM, pady=10)

    def create_hover_button(self, parent, text, bg, fg, command):
        button = tk.Button(parent, text=text, bg=bg, fg=fg, height=2, width=20, command=command, relief="flat", bd=0)
        button.bind("<Enter>", lambda e: button.config(bg="grey"))
        button.bind("<Leave>", lambda e: button.config(bg=bg))
        button.configure(font=("Arial", 10), highlightthickness=0, padx=10, pady=5)
        button.pack_propagate(False)
        button.update_idletasks()
        button.configure(borderwidth=2, highlightbackground=bg, highlightcolor=bg, relief="ridge")
        return button

    def open_register_window(self):
        register_window = tk.Toplevel(self.root)
        register_window.title("Register User")
        register_window.geometry("300x300")

        tk.Label(register_window, text="First Name:").pack(pady=5)
        first_name_entry = tk.Entry(register_window)
        first_name_entry.pack(pady=5)

        tk.Label(register_window, text="Last Name:").pack(pady=5)
        last_name_entry = tk.Entry(register_window)
        last_name_entry.pack(pady=5)

        tk.Label(register_window, text="LIU_ID:").pack(pady=5)
        liu_id_entry = tk.Entry(register_window)
        liu_id_entry.pack(pady=5)

        tk.Label(register_window, text="Email:").pack(pady=5)
        email_entry = tk.Entry(register_window)
        email_entry.pack(pady=5)

        tk.Label(register_window, text="Password:").pack(pady=5)
        password_entry = tk.Entry(register_window, show="*")
        password_entry.pack(pady=5)

        def register_user():
            first_name = first_name_entry.get()
            last_name = last_name_entry.get()
            liu_id = liu_id_entry.get()
            email = email_entry.get()
            password = password_entry.get()

            if first_name and last_name and liu_id and email and password:
                try:
                    conn = sqlite3.connect("sequences.db")
                    cursor = conn.cursor()
                    cursor.execute("INSERT INTO users (first_name, last_name, liu_id, email, password) VALUES (?, ?, ?, ?, ?)",
                                   (first_name, last_name, liu_id, email, password))
                    conn.commit()
                    conn.close()
                    messagebox.showinfo("Register", "User registered successfully!")
                    register_window.destroy()
                except sqlite3.IntegrityError:
                    messagebox.showerror("Error", "LIU_ID already exists.")
                except sqlite3.Error as e:
                    messagebox.showerror("Database Error", str(e))
            else:
                messagebox.showwarning("Error", "Please fill in all fields.")

        tk.Button(register_window, text="Submit", bg="#2ecc71", fg="white", command=register_user).pack(pady=20)

    def open_login_window(self):
        login_window = tk.Toplevel(self.root)
        login_window.title("Login User")
        login_window.geometry("300x200")

        tk.Label(login_window, text="LIU_ID:").pack(pady=5)
        liu_id_entry = tk.Entry(login_window)
        liu_id_entry.pack(pady=5)

        tk.Label(login_window, text="Password:").pack(pady=5)
        password_entry = tk.Entry(login_window, show="*")
        password_entry.pack(pady=5)

        def login_user():
            liu_id = liu_id_entry.get()
            password = password_entry.get()

            conn = sqlite3.connect("sequences.db")
            cursor = conn.cursor()
            cursor.execute("SELECT first_name, last_name FROM users WHERE liu_id = ? AND password = ?", (liu_id, password))
            user = cursor.fetchone()
            conn.close()

            if user:
                messagebox.showinfo("Login", f"Welcome, {user[0]} {user[1]}!")
                login_window.destroy()
            else:
                messagebox.showerror("Error", "Invalid LIU_ID or password.")

        tk.Button(login_window, text="Login", bg="#3498db", fg="white", command=login_user).pack(pady=20)

if __name__ == "__main__":
    root = tk.Tk()
    app = MainApplication(root)
    root.mainloop()

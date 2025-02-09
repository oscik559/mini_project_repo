import sys
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QVBoxLayout, QHBoxLayout, QPushButton, QLabel, QLineEdit,
    QDialog, QFormLayout, QMessageBox, QWidget, QTableWidget, QTableWidgetItem
)
from PyQt6.QtGui import QFont, QIcon
from PyQt6.QtCore import Qt, QSize
from PyQt6.QtSql import QSqlDatabase, QSqlQuery, QSqlTableModel
import os


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("GUI - Robot Application")
        self.setFixedSize(QSize(400, 600))
        icon_path = os.path.join("GUI_icons", "robot.png")
        if os.path.exists(icon_path):
            self.setWindowIcon(QIcon(icon_path))
        else:
            self.setWindowIcon(QIcon())  # Set a default icon or leave it empty

        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        self.setup_ui()

        # Connect to the sequences.db database
        self.db = self.connect_to_database()

    def connect_to_database(self):
        """Connect to the sequences.db SQLite database."""
        db = QSqlDatabase.addDatabase("QSQLITE")
        db.setDatabaseName("sequences.db")
        if not db.open():
            QMessageBox.critical(self, "Database Error", "Unable to connect to the database.")
            sys.exit(1)
        return db

    def setup_ui(self):
        # Main layout
        layout = QVBoxLayout()

        # Title
        title_label = QLabel("Welcome Home!")
        title_label.setFont(QFont("Garamond", 32, QFont.Weight.Bold))
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title_label)













        # Button layout
        button_layout = QHBoxLayout()

        # Buttons
        register_button = QPushButton("Register")
        register_button.setStyleSheet("background-color: #3498db; color: white; padding: 20px;")
        register_button.clicked.connect(self.open_register_dialog)
        button_layout.addWidget(register_button)

        login_button = QPushButton("Login")
        login_button.setStyleSheet("background-color: #2ecc71; color: white; padding: 20px;")
        login_button.clicked.connect(self.open_login_dialog)
        button_layout.addWidget(login_button)

        exit_button = QPushButton("Exit")
        exit_button.setStyleSheet("background-color: #e74c3c; color: white; padding: 20px;")
        exit_button.clicked.connect(self.close)
        button_layout.addWidget(exit_button)
        layout.addLayout(button_layout)
        
        
        button_layout = QHBoxLayout()

        create_db_button = QPushButton("Create Database")
        create_db_button.setStyleSheet("background-color: #e67e22; color: white; padding: 20px;")
        create_db_button.clicked.connect(self.create_database)
        button_layout.addWidget(create_db_button)

        load_robot_button = QPushButton("Load Robot")
        load_robot_button.setStyleSheet("background-color: #9b59b6; color: white; padding: 20px;")
        load_robot_button.clicked.connect(self.load_robot)
        button_layout.addWidget(load_robot_button)

        run_camera_button = QPushButton("Run Camera Vision")
        run_camera_button.setStyleSheet("background-color: #f39c12; color: white; padding: 20px;")
        run_camera_button.clicked.connect(self.run_camera_vision)
        button_layout.addWidget(run_camera_button)
        
        layout.addLayout(button_layout)
        
        button_layout = QHBoxLayout()
        
        show_tables_button = QPushButton("Show Database Tables")
        show_tables_button.setStyleSheet("background-color: #16a085; color: white; padding: 20px;")
        show_tables_button.clicked.connect(self.show_tables_dialog)
        button_layout.addWidget(show_tables_button)
        
        layout.addLayout(button_layout)

        # Footer
        footer_label = QLabel("Linköping University")
        footer_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        footer_label.setStyleSheet("color: gray; font-size: 12px;")
        layout.addWidget(footer_label)

        self.central_widget.setLayout(layout)

    def open_register_dialog(self):
        dialog = RegisterDialog(self.db, self)
        dialog.exec()

    def open_login_dialog(self):
        dialog = LoginDialog(self.db, self)
        dialog.exec()

    def create_database(self):
        QMessageBox.information(self, "Database", "Database already initialized.")

    def load_robot(self):
        QMessageBox.information(self, "Robot", "Robot loaded into the simulation!")

    def run_camera_vision(self):
        QMessageBox.information(self, "Camera Vision", "Camera vision is now active!")

    def show_tables_dialog(self):
        dialog = ShowTablesDialog(self.db, self)
        dialog.exec()


class ShowTablesDialog(QDialog):
    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db
        self.setWindowTitle("Database Tables")
        self.setFixedSize(1000, 600)
        self.setup_ui()

    def setup_ui(self):
        layout = QVBoxLayout()

        # Header Label
        tables_label = QLabel("Tables in the Database:")
        tables_label.setFont(QFont("Arial", 14))
        tables_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(tables_label)

        # List of tables
        self.tables_list = QTableWidget()
        self.tables_list.setColumnCount(1)
        self.tables_list.setHorizontalHeaderLabels(["Table Name"])
        self.tables_list.setSelectionBehavior(QTableWidget.SelectionBehavior.SelectRows)
        self.tables_list.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        self.tables_list.cellClicked.connect(self.show_table_contents)
        layout.addWidget(self.tables_list)

        # Table content display
        self.table_content = QTableWidget()
        self.table_content.setEditTriggers(QTableWidget.EditTrigger.NoEditTriggers)
        layout.addWidget(self.table_content)

        # Close button
        close_button = QPushButton("Close")
        close_button.clicked.connect(self.close)
        layout.addWidget(close_button)

        self.setLayout(layout)
        self.load_tables()

    def load_tables(self):
        """Load the tables from the database and display their names."""
        if not self.db.isOpen():
            QMessageBox.critical(self, "Database Error", "Database connection is not open.")
            return

        query = QSqlQuery(self.db)
        query.exec("SELECT name FROM sqlite_master WHERE type='table';")

        tables = []
        while query.next():
            tables.append(query.value(0))

        self.tables_list.setRowCount(len(tables))
        for row, table_name in enumerate(tables):
            self.tables_list.setItem(row, 0, QTableWidgetItem(table_name))

    def show_table_contents(self, row, column):
        """Display the contents of the selected table."""
        table_name = self.tables_list.item(row, column).text()
        query = QSqlQuery(self.db)
        query.exec(f"SELECT * FROM {table_name}")

        # Get column names
        query.exec(f"PRAGMA table_info({table_name})")
        column_names = []
        while query.next():
            column_names.append(query.value(1))  # Column name is in the second field

        # Fetch data
        query.exec(f"SELECT * FROM {table_name}")
        data = []
        while query.next():
            row_data = [query.value(i) for i in range(len(column_names))]
            data.append(row_data)

        # Populate the table
        self.table_content.setColumnCount(len(column_names))
        self.table_content.setRowCount(len(data))
        self.table_content.setHorizontalHeaderLabels(column_names)

        for row_idx, row_data in enumerate(data):
            for col_idx, value in enumerate(row_data):
                self.table_content.setItem(row_idx, col_idx, QTableWidgetItem(str(value)))


class RegisterDialog(QDialog):
    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db
        self.setWindowTitle("Register User")
        self.setFixedSize(300, 250)
        self.setup_ui()

    def setup_ui(self):
        layout = QFormLayout()
        self.first_name_input = QLineEdit()
        self.last_name_input = QLineEdit()
        self.liu_id_input = QLineEdit()
        self.email_input = QLineEdit()
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)

        layout.addRow("First Name:", self.first_name_input)
        layout.addRow("Last Name:", self.last_name_input)
        layout.addRow("LIU_ID:", self.liu_id_input)
        layout.addRow("Email:", self.email_input)
        layout.addRow("Password:", self.password_input)

        submit_button = QPushButton("Submit")
        submit_button.setStyleSheet("background-color: #2ecc71; color: white; padding: 10px;")
        submit_button.clicked.connect(self.register_user)
        layout.addWidget(submit_button)

        self.setLayout(layout)

    def register_user(self):
        first_name = self.first_name_input.text()
        last_name = self.last_name_input.text()
        liu_id = self.liu_id_input.text()
        email = self.email_input.text()
        password = self.password_input.text()

        if first_name and last_name and liu_id and email and password:
            query = QSqlQuery(self.db)
            query.prepare("""
                INSERT INTO users (first_name, last_name, liu_id, email, password)
                VALUES (?, ?, ?, ?, ?)
            """)
            query.addBindValue(first_name)
            query.addBindValue(last_name)
            query.addBindValue(liu_id)
            query.addBindValue(email)
            query.addBindValue(password)
            if query.exec():
                QMessageBox.information(self, "Register", "User registered successfully!")
                self.close()
            else:
                QMessageBox.warning(self, "Error", f"Registration failed: {query.lastError().text()}")
        else:
            QMessageBox.warning(self, "Error", "Please fill in all fields.")


class LoginDialog(QDialog):
    def __init__(self, db, parent=None):
        super().__init__(parent)
        self.db = db
        self.setWindowTitle("Login User")
        self.setFixedSize(300, 150)
        self.setup_ui()

    def setup_ui(self):
        layout = QFormLayout()
        self.liu_id_input = QLineEdit()
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.EchoMode.Password)

        layout.addRow("LIU_ID:", self.liu_id_input)
        layout.addRow("Password:", self.password_input)

        login_button = QPushButton("Login")
        login_button.setStyleSheet("background-color: #3498db; color: white; padding: 5px;")
        login_button.clicked.connect(self.login_user)
        layout.addWidget(login_button)

        self.setLayout(layout)

    def login_user(self):
        liu_id = self.liu_id_input.text()
        password = self.password_input.text()

        query = QSqlQuery(self.db)
        query.prepare("SELECT first_name, last_name FROM users WHERE liu_id = ? AND password = ?")
        query.addBindValue(liu_id)
        query.addBindValue(password)
        if query.exec() and query.next():
            first_name, last_name = query.value(0), query.value(1)
            QMessageBox.information(self, "Login", f"Welcome, {first_name} {last_name}!")
            self.close()
        else:
            QMessageBox.warning(self, "Error", "Invalid LIU_ID or password.")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())

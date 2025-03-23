import os
import pytest
from mini_project.database.db_handler_pgSQL import DatabaseHandler

@pytest.fixture(scope="function")
def test_db(monkeypatch):
    # Use test DB (you can define this in .env or override here)
    monkeypatch.setenv("DATABASE_URL", "postgresql://oscar:oscik559@localhost:5432/sequences_test_db")

    db = DatabaseHandler()
    
    yield db
    db.drop_all_tables()
    db.close()

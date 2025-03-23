import os
import pytest
from mini_project.database.db_handler_pgSQL import DatabaseHandler

@pytest.fixture(scope="function")
def test_db(monkeypatch):
    # Point to test DB
    monkeypatch.setenv("DATABASE_URL", "postgresql://oscar:oscik559@localhost:5432/sequences_test_db")

    db = DatabaseHandler()
    db.drop_all_tables()         # Ensure clean state
    db.create_tables()           # ✅ Create tables before using them
    db.create_indexes()

    yield db                     # Test runs here

    db.drop_all_tables()         # Teardown
    db.close()

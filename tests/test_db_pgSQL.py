# tests/test_db_handler.py

import pytest
from mini_project.database.db_handler_new.db_handler_pgSQL import DatabaseHandler


@pytest.fixture(scope="module")
def db():
    db_handler = DatabaseHandler()
    yield db_handler
    db_handler.close()


def test_tables_exist(db):
    tables = [
        "users",
        "sequence_library",
        "skills",
        "instructions",
        "states",
        "operation_sequence",
        "screw_op_parameters",
        "camera_vision",
        "sort_order",
        "interaction_memory",
        "simulation_results",
        "task_preferences",
        "unified_instructions",
        "instruction_operation_sequence",
    ]
    for table in tables:
        db.cursor.execute(f"SELECT to_regclass('public.{table}');")
        exists = db.cursor.fetchone()[0]
        assert exists == table


def test_populate_database_runs(db):
    db.populate_database()
    db.cursor.execute("SELECT COUNT(*) FROM users;")
    count = db.cursor.fetchone()[0]
    assert count > 0


def test_clear_tables_resets_rows(db):
    db.clear_tables()
    db.cursor.execute("SELECT COUNT(*) FROM users;")
    assert db.cursor.fetchone()[0] == 0


def test_drop_all_tables_and_recreate(db):
    db.drop_all_tables()
    db.create_tables()
    db.cursor.execute("SELECT to_regclass('public.users');")
    assert db.cursor.fetchone()[0] == "users"

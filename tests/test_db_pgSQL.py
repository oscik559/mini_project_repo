import pytest
from mini_project.database.db_handler_pgSQL import DatabaseHandler


def test_tables_created(test_db):
    """
    Verify that all required tables were created in the database.
    """
    test_db.cursor.execute(
        """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public';
    """
    )
    existing_tables = {row[0] for row in test_db.cursor.fetchall()}

    expected_tables = {
        "users",
        "skills",
        "instructions",
        "sequence_library",
        "states",
        "operation_sequence",
        "sort_order",
        "interaction_memory",
        "simulation_results",
        "usd_data",
        "task_preferences",
    }

    assert expected_tables.issubset(
        existing_tables
    ), f"Missing tables: {expected_tables - existing_tables}"


def test_data_population(test_db):
    """
    Populate the database and verify row counts for key tables.
    """
    test_db.populate_database()

    def assert_row_count(table_name: str, min_expected: int = 1):
        test_db.cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
        count = test_db.cursor.fetchone()[0]
        assert (
            count >= min_expected
        ), f"{table_name} has {count} rows, expected at least {min_expected}"

    assert_row_count("users", 4)
    assert_row_count("skills", 2)
    assert_row_count("sequence_library", 5)
    assert_row_count("usd_data", 5)
    assert_row_count("instructions", 2)
    assert_row_count("states", 2)
    assert_row_count("operation_sequence", 20)
    assert_row_count("sort_order", 3)
    assert_row_count("task_preferences", 3)
    assert_row_count("interaction_memory", 3)
    assert_row_count("simulation_results", 2)

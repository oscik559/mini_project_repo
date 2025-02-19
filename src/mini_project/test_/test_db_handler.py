"""
Schema creation and validation: Verifying that key tables and columns exist.
Population routines: Checking that sample data is inserted as expected.
Role-based access decorator: Ensuring that access is granted only to users with allowed roles.
"""

import sqlite3
import unittest

from mini_project.core.db_handler import DatabaseHandler


# Create a dummy subclass to test the role-based access decorator.
class DummyDatabaseHandler(DatabaseHandler):
    @DatabaseHandler.require_role(("admin", "operator"))
    def restricted_method(self, user_id):
        return "Access granted"


class TestSchemaCreationAndValidation(unittest.TestCase):
    def setUp(self):
        # Use an in-memory database for testing.
        self.db_handler = DatabaseHandler(":memory:")

    def tearDown(self):
        self.db_handler.close()

    def test_users_table_schema(self):
        # Check that the 'users' table contains the renamed column.
        self.db_handler.cursor.execute("PRAGMA table_info(users)")
        columns = {row[1] for row in self.db_handler.cursor.fetchall()}
        self.assertIn(
            "user_interaction_memory",
            columns,
            "Column 'user_interaction_memory' not found in 'users' table.",
        )

    def test_instructions_table_schema(self):
        # Check that the 'instructions' table contains the 'confidence' column.
        self.db_handler.cursor.execute("PRAGMA table_info(instructions)")
        columns = {row[1] for row in self.db_handler.cursor.fetchall()}
        self.assertIn(
            "confidence",
            columns,
            "Column 'confidence' not found in 'instructions' table.",
        )

    def test_schema_validation_no_errors(self):
        # Run schema update to verify it completes without error.
        try:
            self.db_handler.update_table_schemas()
        except Exception as e:
            self.fail(f"update_table_schemas raised an exception: {e}")
        # Also check that a known column exists.
        self.db_handler.cursor.execute("PRAGMA table_info(states)")
        columns = {row[1] for row in self.db_handler.cursor.fetchall()}
        self.assertIn("task_name", columns)


class TestPopulationRoutines(unittest.TestCase):
    def setUp(self):
        self.db_handler = DatabaseHandler(":memory:")
        # Populate the database with sample data.
        self.db_handler.populate_database()

    def tearDown(self):
        self.db_handler.close()

    def test_users_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM users")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 4, "Users table should contain 4 entries.")

    def test_sequence_library_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM sequence_library")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 5, "sequence_library table should contain 5 entries.")

    def test_states_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM states")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 2, "states table should contain 2 entries.")

    def test_operation_sequence_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM operation_sequence")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(
            count, 20, "operation_sequence table should contain 20 entries."
        )

    def test_task_preferences_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM task_preferences")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 3, "task_preferences table should contain 3 entries.")

    def test_interaction_memory_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM interaction_memory")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 3, "interaction_memory table should contain 3 entries.")

    def test_skills_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM skills")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 2, "skills table should contain 2 entries.")

    def test_simulation_results_population(self):
        self.db_handler.cursor.execute("SELECT COUNT(*) FROM simulation_results")
        count = self.db_handler.cursor.fetchone()[0]
        self.assertEqual(count, 2, "simulation_results table should contain 2 entries.")


class TestRoleBasedAccessDecorator(unittest.TestCase):
    def setUp(self):
        # Use the dummy subclass with a restricted method.
        self.db_handler = DummyDatabaseHandler(":memory:")
        # Populate the users table so that we have known roles.
        self.db_handler.populate_users()

    def tearDown(self):
        self.db_handler.close()

    def test_access_granted(self):
        # Assume "Oscar" (liu_id 'oscik559') is an admin.
        self.db_handler.cursor.execute(
            "SELECT user_id FROM users WHERE liu_id = 'oscik559'"
        )
        user_id = self.db_handler.cursor.fetchone()[0]
        result = self.db_handler.restricted_method(user_id)
        self.assertEqual(result, "Access granted", "Admin user should have access.")

    def test_access_denied(self):
        # Assume "Mehdi" (liu_id 'mehta77') is a guest.
        self.db_handler.cursor.execute(
            "SELECT user_id FROM users WHERE liu_id = 'mehta77'"
        )
        user_id = self.db_handler.cursor.fetchone()[0]
        with self.assertRaises(
            PermissionError, msg="Guest user should not have access."
        ):
            self.db_handler.restricted_method(user_id)


if __name__ == "__main__":
    unittest.main()

# database/db_handler_postgreSQL.py

import argparse
import logging
import os
import subprocess
import sys
from datetime import datetime

from dotenv import load_dotenv
from psycopg2 import Error as Psycopg2Error

from config.app_config import DB_BACKUP_PATH, setup_logging
from mini_project.database import populate_db, schema_sql
from mini_project.database.connection import get_connection

# Load .env variables
load_dotenv()


# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("dbHandler")


class DatabaseHandler:
    """
    A class to handle database operations using PostgreSQL.
    """

    def __init__(self):
        try:
            self.conn = get_connection()
            self.conn.autocommit = False
            self.cursor = self.conn.cursor()
        except Psycopg2Error as e:
            logger.error(f"Error connecting to PostgreSQL database: {e}")
            raise

    def backup_database(self, backup_dir=DB_BACKUP_PATH):

        os.makedirs(backup_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%y%m%d_%H%M%S")
        backup_file = os.path.join(backup_dir, f"backup_{timestamp}.sql")

        db_url = os.getenv("DATABASE_URL")
        if not db_url:
            logger.error("DATABASE_URL not set in environment.")
            return

        try:
            logger.info(f"🗃️  Backing up database to {backup_file}...")
            subprocess.run(["pg_dump", db_url, "-f", backup_file], check=True)
            logger.info("✅ Backup completed successfully.")
        except Exception as e:
            logger.error("Database backup failed: %s", e, exc_info=True)

    def print_status(self):
        logger.info("🧪 Checking database table status...")

        self.cursor.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """
        )
        tables = [row[0] for row in self.cursor.fetchall()]

        for table in tables:
            self.cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = self.cursor.fetchone()[0]
            logger.info(f"💡 {table}: {count} rows")

    def create_tables(self):
        try:
            for create_sql in schema_sql.tables.values():
                self.cursor.execute(create_sql)
            self.conn.commit()
            logger.info("✅ All tables created successfully.")
        except Psycopg2Error as e:
            logger.error(f"Error creating tables: {e}")
            self.conn.rollback()
            raise

    def create_indexes(self):
        try:
            for index in schema_sql.indexes:
                self.cursor.execute(index)
            self.conn.commit()
        except Psycopg2Error as e:
            logger.error(f"Error creating indexes: {e}")
            self.conn.rollback()
            raise

    def update_table_schemas(self):
        """
        Schema validation and dynamic alteration is not implemented for PostgreSQL.
        Consider using a migration tool like Alembic.
        """
        logger.info(
            "Skipping schema update. Use migrations for PostgreSQL schema changes."
        )

    def clear_tables(self):
        try:
            tables = list(schema_sql.tables.keys())
            truncate_query = (
                "TRUNCATE TABLE " + ", ".join(tables) + " RESTART IDENTITY CASCADE;"
            )
            self.cursor.execute(truncate_query)
            self.conn.commit()
            logger.info("✅ All tables cleared successfully.")
        except Psycopg2Error as e:
            logger.error(f"Error clearing tables: {e}")
            self.conn.rollback()
            raise

    def drop_all_tables(self):
        try:

            self.cursor.execute(
                """
                DO $$ DECLARE
                    r RECORD;
                BEGIN
                    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
                        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
                    END LOOP;
                END $$;
            """
            )
            self.conn.commit()
            logger.info("✅ All tables dropped successfully.")
        except Psycopg2Error as e:
            logger.error(f"Error dropping tables: {e}")
            self.conn.rollback()
            raise

    def clear_camera_vision(self):
        try:
            # Delete all rows from the camera_vision table
            self.cursor.execute("DELETE FROM camera_vision;")
            self.conn.commit()
            logger.info("✅ [DB] Cleared camera_vision table.")
        except Exception as e:
            logger.error(f"Error clearing camera_vision table: {e}")
            self.conn.rollback()

    def populate_database(self):
        try:
            self.clear_tables()

            populator = populate_db.DatabasePopulator(self.cursor)

            populator.populate_usd_data()
            populator.populate_users()
            populator.populate_sequence_library()
            populator.populate_task_templates()
            populator.populate_skills()
            populator.populate_instructions()
            populator.populate_states()
            # populator.populate_operation_sequence()
            # populator.populate_sort_order()
            populator.populate_task_preferences()
            populator.populate_interaction_memory()
            populator.populate_simulation_results()

            populator.populate_manual_operations()

            self.conn.commit()
            logger.info("✅ Database populated successfully.")
        except Psycopg2Error as e:
            logger.error(f"Database population failed: {e}")
            self.conn.rollback()

    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()


def main_cli():
    parser = argparse.ArgumentParser(description="Manage PostgreSQL database.")

    parser.add_argument(
        "--clear", action="store_true", help="Truncate all tables and reset identities."
    )
    parser.add_argument("--drop", action="store_true", help="Drop all tables.")
    parser.add_argument("--create", action="store_true", help="Create all tables.")
    parser.add_argument(
        "--populate", action="store_true", help="Populate tables with sample data."
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Drop, create, and populate all tables.",
    )
    parser.add_argument(
        "--backup",
        action="store_true",
        help="Backup the database before making changes.",
    )

    parser.add_argument(
        "--status", action="store_true", help="Show table row counts and status."
    )

    args = parser.parse_args()

    # Show help if no arguments are passed
    if not any(vars(args).values()):
        parser.print_help()
        print("No arguments provided — defaulting to --reset.\n")
        args.reset = True

    try:
        db = DatabaseHandler()

        if args.reset:
            print("🧠 Resetting the database (backup, drop, create, populate)...")
            db.backup_database()
            db.drop_all_tables()
            db.create_tables()
            db.create_indexes()
            db.populate_database()
            db.print_status()
            print("✅  ALL GOOD!.")
        else:
            if args.backup:
                print("Backing up database...")
                db.backup_database()
            if args.status:
                db.print_status()
                return

            if args.drop:
                print("Dropping all tables...")
                db.drop_all_tables()
            if args.create:
                print("Creating tables...")
                db.create_tables()
                db.create_indexes()
            if args.clear:
                print("Clearing tables...")
                db.clear_tables()
            if args.populate:
                print("Populating tables...")
                db.populate_database()

        db.close()

    except Exception as e:
        logger.exception("Unexpected error during CLI execution")
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main_cli()

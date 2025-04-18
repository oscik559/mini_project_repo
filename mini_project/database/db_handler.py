# database/db_handler_postgreSQL.py
"""
DatabaseHandler Class and CLI Tool for PostgreSQL Database Management
This module provides a `DatabaseHandler` class to manage PostgreSQL database operations
such as creating tables, backing up data, restoring data, and populating the database
with sample data. It also includes a CLI tool for interacting with the database.
Classes:
--------
- DatabaseHandler:
Functions:
----------
- json_serializer(obj):
    Serializes datetime and memoryview objects for JSON compatibility.
- main_cli():
    Command-line interface for managing the PostgreSQL database.
DatabaseHandler Methods:
------------------------
- __init__():
    Initializes the database connection and cursor.
- backup_user_profiles(backup_dir=None):
    Backs up all user profiles from the 'users' table into a JSON file.
- restore_user_profiles(backup_dir=None, latest_only=True):
    Restores user profiles from the most recent backup.
- backup_database(backup_dir=DB_BACKUP_PATH):
    Creates a backup of the entire database using `pg_dump`.
- print_status():
    Logs the status of all tables in the database, including row counts.
- create_tables():
    Creates all tables defined in the schema.
- create_indexes():
    Creates all indexes defined in the schema.
- update_table_schemas():
    Placeholder for schema validation and dynamic alteration (not implemented).
- clear_tables():
    Truncates all tables and resets their identities.
- drop_all_tables():
    Drops all tables in the database.
- clear_camera_vision():
    Deletes all rows from the `camera_vision` table.
- populate_database():
    Populates the database with sample data using the `populate_db` module.
- close():
    Closes the database connection and cursor.
CLI Arguments:
--------------
- --clear:
    Truncate all tables and reset identities.
- --drop:
    Drop all tables.
- --create:
    Create all tables.
- --populate:
    Populate tables with sample data.
- --reset:
    Drop, create, and populate all tables (default action if no arguments are provided).
- --backup:
    Backup the database before making changes.
- --status:
    Show table row counts and status.
Usage:
------
Run the script with the desired CLI arguments to perform database operations.
If no arguments are provided, the script defaults to the `--reset` operation.
Example:
--------
$ python db_handler.py --reset
"""
import argparse
import binascii
import json
import logging
import os
import pickle
import subprocess
import sys
from datetime import datetime

import psycopg2
from dotenv import load_dotenv
from psycopg2 import Error as Psycopg2Error

from config.app_config import DB_BACKUP_PATH, PROFILE_BACKUP_PATH, setup_logging
from mini_project.database import populate_db, schema_sql
from mini_project.database.connection import get_connection

# Load .env variables
load_dotenv()


# Initialize logging with desired level (optional)
setup_logging(level=logging.INFO)
logger = logging.getLogger("PgDBaseHandler")


def json_serializer(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    if isinstance(obj, memoryview):
        return obj.tobytes().hex()  # Hex string for JSON-safe backup
    raise TypeError(f"Type {type(obj)} not serializable")


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

    def backup_user_profiles(self, backup_dir=None):
        """Backs up all user profiles from the 'users' table into a JSON file."""

        # ✅ Check if 'users' table exists
        self.cursor.execute(
            """
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_name = 'users'
            );
        """
        )
        exists = self.cursor.fetchone()[0]
        if not exists:
            logger.info(f"🔴 'users' table does not exist. Skipping profile backup.")
            return

        # Proceed with backup if table exists
        backup_dir = PROFILE_BACKUP_PATH
        backup_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = backup_dir / f"user_profile_backup_{timestamp}.json"

        self.cursor.execute("SELECT * FROM users")
        rows = self.cursor.fetchall()
        colnames = [desc[0] for desc in self.cursor.description]

        users = [dict(zip(colnames, row)) for row in rows]

        with open(backup_path, "w", encoding="utf-8") as f:
            json.dump(users, f, indent=2, default=json_serializer)

        logger.info(f"✅ Backed up {len(users)} users to: {backup_path}")

    def restore_user_profiles(self, backup_dir=None, latest_only=True):
        """Restores user profiles from the most recent backup."""
        backup_dir = PROFILE_BACKUP_PATH
        if not backup_dir.exists():
            logger.info(f"⚠️ No backup folder found.")
            return

        backup_files = sorted(
            backup_dir.glob("user_profile_backup_*.json"), reverse=True
        )
        if not backup_files:
            logger.info(f"⚠️ No backup files found.")
            return

        backup_path = backup_files[0] if latest_only else backup_files[-1]
        with open(backup_path, "r", encoding="utf-8") as f:
            users = json.load(f)

        restored_users = []
        for user in users:
            # 🔁 Decode binary fields
            if "face_encoding" in user and isinstance(user["face_encoding"], str):
                user["face_encoding"] = psycopg2.Binary(
                    binascii.unhexlify(user["face_encoding"])
                )

            if "voice_embedding" in user and isinstance(user["voice_embedding"], str):
                user["voice_embedding"] = psycopg2.Binary(
                    binascii.unhexlify(user["voice_embedding"])
                )

            # ❌ Drop user_id so PostgreSQL can auto-generate it
            user.pop("user_id", None)

            placeholders = ", ".join(["%s"] * len(user))
            columns = ", ".join(user.keys())
            values = list(user.values())
            # sql = f"INSERT INTO users ({columns}) VALUES ({placeholders}) ON CONFLICT (liu_id) DO NOTHING"
            sql = f"""
            INSERT INTO users ({columns}) VALUES ({placeholders})
            ON CONFLICT (liu_id) DO UPDATE SET
                face_encoding = EXCLUDED.face_encoding,
                voice_embedding = EXCLUDED.voice_embedding,
                preferences = EXCLUDED.preferences,
                profile_image_path = EXCLUDED.profile_image_path,
                interaction_memory = EXCLUDED.interaction_memory,
                last_updated = CURRENT_TIMESTAMP
            """
            self.cursor.execute(sql, values)
            restored_users.append(
                user["liu_id"]
            )  # ✅ Collect ID instead of logging every one
        self.conn.commit()
        # ✅ One neat log line:
        logger.info(
            f"✅ Restored {len(restored_users)} user profile(s): {', '.join(restored_users)}"
        )

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
            populator.populate_operation_library()
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
            logger.info(
                f"🧠 Resetting the database (backup, drop, create, populate)..."
            )
            db.backup_user_profiles()  # 🔐 Backup BEFORE dropping
            db.backup_database()
            db.drop_all_tables()
            db.create_tables()
            db.create_indexes()
            db.populate_database()
            db.restore_user_profiles()  # ♻️ Restore users after everything else
            db.print_status()
            print("\n🎉 All Done! Database is healthy and ready.\n")

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

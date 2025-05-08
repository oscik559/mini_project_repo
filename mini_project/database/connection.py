# database/connection.py


import logging
import os
from urllib.parse import urlparse

import psycopg2
from dotenv import load_dotenv
from psycopg2 import sql

from mini_project.config.app_config import setup_logging

load_dotenv()

# Logging
debug_mode = os.getenv("DEBUG", "0") in ["1", "true", "True"]
log_level = os.getenv("LOG_LEVEL", "DEBUG" if debug_mode else "INFO").upper()
setup_logging(level=getattr(logging, log_level))
logger = logging.getLogger("PgDBConnection")


def get_connection():
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        raise EnvironmentError("❌ DATABASE_URL not found in .env")

    parsed = urlparse(db_url)
    db_name = parsed.path.lstrip("/")
    user = parsed.username
    password = parsed.password
    host = parsed.hostname
    port = parsed.port or 5432

    # ✅ Ensure the database exists
    ensure_database_exists(user, password, host, port, db_name)

    # ✅ Now safe to connect to it
    try:
        conn = psycopg2.connect(db_url)
        logger.info(f"✅ Connected to database: {db_name}")
        return conn
    except Exception as e:
        logger.exception("❌ Failed to connect to target database.")
        raise


def ensure_database_exists(user, password, host, port, db_name):
    try:
        logger.info(f"🟢 Checking if database '{db_name}' exists...")
        conn = psycopg2.connect(
            dbname="postgres",
            user=user,
            password=password,
            host=host,
            port=port,
        )
        conn.autocommit = True
        cur = conn.cursor()

        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
        exists = cur.fetchone()
        if not exists:
            cur.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name)))
            logger.info(f"✅ Created missing database: {db_name}")
        else:
            logger.info(f"✅ Database '{db_name}' already exists.")

        cur.close()
        conn.close()
    except Exception as e:
        logger.error(f"❌ Could not check/create database '{db_name}': {e}")
        raise

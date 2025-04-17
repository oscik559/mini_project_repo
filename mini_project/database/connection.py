import logging
import os

import psycopg2
from dotenv import load_dotenv

from config.app_config import setup_logging

load_dotenv()

# === Logging Setup ===
debug_mode = os.getenv("DEBUG", "0") in ["1", "true", "True"]
log_level = os.getenv("LOG_LEVEL", "DEBUG" if debug_mode else "INFO").upper()
setup_logging(level=getattr(logging, log_level))
logger = logging.getLogger("PgDBConnection")


def get_connection():
    db_url = os.getenv("DATABASE_URL")

    if db_url:
        # logger.info(f"🟡 Using DB: %s", db_url)
        logger.info(f"🟢 Using DB: {db_url}")
    else:
        logger.error("❌ DATABASE_URL not found in .env")
        raise EnvironmentError("DATABASE_URL not found in .env")

    try:
        conn = psycopg2.connect(db_url)
        logger.info("✅ PostgreSQL connection established.")
        return conn
    except psycopg2.Error as e:
        logger.exception("❌ Failed to connect to PostgreSQL:")
        raise

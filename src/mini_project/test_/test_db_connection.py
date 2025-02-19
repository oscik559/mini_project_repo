import psycopg2

from config.app_config import DB_URL

try:
    conn = psycopg2.connect(DB_URL)
    print("Connected to PostgreSQL successfully!")
    conn.close()
except Exception as e:
    print("Connection failed:", e)

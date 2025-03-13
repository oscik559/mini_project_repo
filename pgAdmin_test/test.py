import psycopg2

# Update with the correct details for remote access
DB_HOST = "10.245.0.28"  # Change to the IP of the computer running PostgreSQL
DB_PORT = "5432"  # Default PostgreSQL port
DB_NAME = "sequences_db"  # Database name
DB_USER = "oscar"  # Database username
DB_PASSWORD = "oscik559"  # Database password

try:
    # Create the connection
    conn = psycopg2.connect(
        dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT
    )
    print("Connection to PostgreSQL successful!")

    # Check if database is accessible
    with conn.cursor() as cursor:
        cursor.execute("SELECT NOW();")  # Fetch current timestamp from the database
        result = cursor.fetchone()
        print("Database is accessible. Current timestamp:", result[0])

    conn.close()

except psycopg2.Error as e:
    print("Error connecting to the database:", e)

import psycopg2

# Replace with your actual database details
DB_HOST = "10.245.0.28"  # Use the IP address of the PostgreSQL server
DB_PORT = "5432"  # Default PostgreSQL port
DB_NAME = "sequences_db"  # Database name
DB_USER = "oscar"  # PostgreSQL username
DB_PASSWORD = "oscik559"  # PostgreSQL password

try:
    # Connect to the remote PostgreSQL database
    conn = psycopg2.connect(
        dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT
    )

    cursor = conn.cursor()

    # Query to fetch all records from the users table
    query = "SELECT * FROM users;"
    cursor.execute(query)

    # Fetch and print all results
    records = cursor.fetchall()
    print("\n=== Retrieved Data from users Table ===")

    # Print column headers
    column_names = [desc[0] for desc in cursor.description]
    print("\t".join(column_names))

    for row in records:
        print("\t".join(str(item) for item in row))

    # Close connection
    cursor.close()
    conn.close()
    print("\n✅ Query successful! Data retrieved.")

except psycopg2.Error as e:
    print("❌ Error querying the database:", e)

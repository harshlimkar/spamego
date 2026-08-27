import sqlite3

DB_NAME = 'server_db.sqlite'

def get_db_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS official_numbers (
        number TEXT PRIMARY KEY,
        organization TEXT
    )
    ''')

    cursor.execute('''
    CREATE TABLE IF NOT EXISTS reported_numbers (
        number TEXT PRIMARY KEY,
        scam_type TEXT,
        report_count INTEGER
    )
    ''')
    
    conn.commit()
    conn.close()

def seed_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM official_numbers")
    cursor.execute("DELETE FROM reported_numbers")

    officials = [
        ("1800123456", "Example Bank"),
        ("1930", "Cyber Crime"),
        ("1800999999", "National Govt Services")
    ]
    cursor.executemany("INSERT INTO official_numbers VALUES (?, ?)", officials)

    reported = [
        ("+919876543210", "KYC Scam", 45),
        ("+918888888888", "Lottery Scam", 12),
        ("+911122334455", "Payment Scam", 89)
    ]
    cursor.executemany("INSERT INTO reported_numbers VALUES (?, ?, ?)", reported)

    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
    seed_db()
    print("Server database initialized.")

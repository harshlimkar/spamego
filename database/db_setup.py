import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'scamego_local.db')

def _raw_conn():
    c = sqlite3.connect(DB_PATH)
    c.row_factory = sqlite3.Row
    return c

def get_db_connection():
    conn = _raw_conn()
    # Ensure tables exist
    res = conn.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='trusted_contacts'").fetchone()
    if not res:
        conn.close()
        init_db()
        seed_db()
        conn = _raw_conn()
    return conn

def init_db():
    conn = _raw_conn()
    cursor = conn.cursor()

    # Users / Profile
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        language TEXT,
        phone_number TEXT,
        protection_enabled BOOLEAN DEFAULT 1
    )
    ''')

    # Trusted Contacts
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS trusted_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone_number TEXT,
        relationship TEXT,
        priority INTEGER,
        consent BOOLEAN DEFAULT 1
    )
    ''')

    # Official Numbers
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS official_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        organization TEXT,
        category TEXT,
        source TEXT,
        verified_date TEXT,
        status TEXT
    )
    ''')

    # Reported Numbers
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS reported_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        report_type TEXT,
        category TEXT,
        report_count INTEGER,
        first_reported TEXT,
        last_reported TEXT
    )
    ''')

    # Keywords configuration
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS keywords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT,
        language TEXT,
        weight INTEGER,
        category TEXT
    )
    ''')

    # Rules configuration
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rule_id TEXT,
        description TEXT,
        conditions TEXT,
        risk_level TEXT
    )
    ''')

    # Events Log
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS events_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT, 
        sender_number TEXT,
        timestamp TEXT,
        content TEXT,
        risk_score INTEGER,
        campaign_id TEXT
    )
    ''')

    # Campaigns
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS campaigns (
        campaign_id TEXT PRIMARY KEY,
        created_at TEXT,
        last_updated TEXT,
        risk_score INTEGER,
        risk_level TEXT,
        categories TEXT,
        exposure TEXT,
        status TEXT
    )
    ''')

    conn.commit()
    conn.close()

def seed_db():
    conn = _raw_conn()
    cursor = conn.cursor()

    # Clear existing to be safe during dev/testing
    cursor.execute("DELETE FROM official_numbers")
    cursor.execute("DELETE FROM reported_numbers")
    cursor.execute("DELETE FROM campaigns")
    cursor.execute("DELETE FROM events_log")
    cursor.execute("DELETE FROM users")
    cursor.execute("DELETE FROM trusted_contacts")

    # Seed Official Numbers
    officials = [
        ("1930", "Cyber Crime", "Government", "System", "2023-01-01", "VERIFIED_OFFICIAL"),
        ("1800123456", "Example Bank", "Banking", "System", "2023-01-01", "VERIFIED_OFFICIAL")
    ]
    cursor.executemany('''
        INSERT INTO official_numbers (number, organization, category, source, verified_date, status)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', officials)

    # Seed Reported Numbers
    reported = [
        ("+919876543210", "Scam", "Bank Impersonation", 5, "2023-05-01", "2023-05-20"),
        ("+919999999999", "Scam", "OTP Theft", 12, "2023-06-01", "2023-06-15")
    ]
    cursor.executemany('''
        INSERT INTO reported_numbers (number, report_type, category, report_count, first_reported, last_reported)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', reported)

    conn.commit()
    conn.close()

if __name__ == '__main__':
    print("Initializing Database...")
    init_db()
    seed_db()
    print("Database Initialized and Seeded.")

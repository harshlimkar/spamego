import sqlite3
import os
from datetime import datetime
from pydantic import BaseModel

DB_FILE = os.path.join(os.path.dirname(__file__), "reports.db")

class ReportModel(BaseModel):
    number: str
    risk_tag: str = "suspicious"

def init_db():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS spam_reports (
            number TEXT PRIMARY KEY,
            report_count INTEGER,
            last_reported TEXT,
            risk_tag TEXT
        )
    """)
    conn.commit()
    conn.close()

def report_number(number: str, risk_tag: str = "spam") -> dict:
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("SELECT report_count FROM spam_reports WHERE number = ?", (number,))
    row = cursor.fetchone()
    now = datetime.utcnow().isoformat()
    if row:
        new_count = row[0] + 1
        cursor.execute("""
            UPDATE spam_reports 
            SET report_count = ?, last_reported = ?, risk_tag = ? 
            WHERE number = ?
        """, (new_count, now, risk_tag, number))
    else:
        new_count = 1
        cursor.execute("""
            INSERT INTO spam_reports (number, report_count, last_reported, risk_tag) 
            VALUES (?, ?, ?, ?)
        """, (number, 1, now, risk_tag))
    conn.commit()
    conn.close()
    return {"number": number, "report_count": new_count, "status": "reported"}

def check_number(number: str) -> dict:
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("SELECT report_count, risk_tag FROM spam_reports WHERE number = ?", (number,))
    row = cursor.fetchone()
    conn.close()
    
    if row:
        count, tag = row
        # Base risk score: caps at 1.0 (e.g. 1 report = 0.5, 3+ reports = 1.0)
        base_risk = min(count * 0.33, 1.0)
        return {"number": number, "report_count": count, "risk_tag": tag, "base_risk_score": base_risk}
    return {"number": number, "report_count": 0, "risk_tag": "safe", "base_risk_score": 0.0}

init_db()

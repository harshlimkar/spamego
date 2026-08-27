from server.database.db_setup import get_db_connection

class ServerNumberVerification:
    @staticmethod
    def verify_number(number):
        conn = get_db_connection()
        
        official = conn.execute("SELECT * FROM official_numbers WHERE number = ?", (number,)).fetchone()
        if official:
            conn.close()
            return {"status": "VERIFIED_OFFICIAL", "organization": official["organization"]}
            
        reported = conn.execute("SELECT * FROM reported_numbers WHERE number = ?", (number,)).fetchone()
        if reported:
            conn.close()
            return {"status": "REPORTED_SCAM", "scam_type": reported["scam_type"], "report_count": reported["report_count"]}
            
        conn.close()
        return {"status": "UNKNOWN"}

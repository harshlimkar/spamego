from database.db_setup import get_db_connection

class UserRepository:
    @staticmethod
    def get_profile():
        conn = get_db_connection()
        user = conn.execute("SELECT * FROM users LIMIT 1").fetchone()
        conn.close()
        return dict(user) if user else None

    @staticmethod
    def create_profile(name, language, phone_number):
        conn = get_db_connection()
        conn.execute("DELETE FROM users")
        conn.execute('''
            INSERT INTO users (name, language, phone_number, protection_enabled)
            VALUES (?, ?, ?, 1)
        ''', (name, language, phone_number))
        conn.commit()
        conn.close()

class TrustedContactRepository:
    @staticmethod
    def get_all():
        conn = get_db_connection()
        contacts = conn.execute("SELECT * FROM trusted_contacts").fetchall()
        conn.close()
        return [dict(c) for c in contacts]

    @staticmethod
    def add(name, phone_number, relationship, priority=1):
        conn = get_db_connection()
        conn.execute('''
            INSERT INTO trusted_contacts (name, phone_number, relationship, priority)
            VALUES (?, ?, ?, ?)
        ''', (name, phone_number, relationship, priority))
        conn.commit()
        conn.close()

class NumberRepository:
    @staticmethod
    def check_number(number):
        conn = get_db_connection()
        # Check trusted
        trusted = conn.execute("SELECT * FROM trusted_contacts WHERE phone_number = ?", (number,)).fetchone()
        if trusted:
            conn.close()
            return {"status": "TRUSTED_CONTACT", "details": dict(trusted)}
        
        # Check official
        official = conn.execute("SELECT * FROM official_numbers WHERE number = ?", (number,)).fetchone()
        if official:
            conn.close()
            return {"status": "VERIFIED_OFFICIAL", "details": dict(official)}
        
        # Check reported
        reported = conn.execute("SELECT * FROM reported_numbers WHERE number = ?", (number,)).fetchone()
        if reported:
            conn.close()
            return {"status": "REPORTED_SCAM", "details": dict(reported)}
        
        conn.close()
        return {"status": "UNKNOWN", "details": None}

    @staticmethod
    def cache_remote_result(number, status, categories):
        # Phase 12: Add local caching
        conn = get_db_connection()
        if status == "VERIFIED_OFFICIAL":
            conn.execute('''
                INSERT INTO official_numbers (number, organization, category, source, verified_date, status)
                VALUES (?, 'Remote Verified', ?, 'Remote Server', date('now'), ?)
            ''', (number, categories, status))
        elif status == "REPORTED_SCAM":
            conn.execute('''
                INSERT INTO reported_numbers (number, report_type, category, report_count, first_reported, last_reported)
                VALUES (?, 'Scam', ?, 1, date('now'), date('now'))
            ''', (number, categories))
        conn.commit()
        conn.close()

class EventRepository:
    @staticmethod
    def log_event(event_type, sender, timestamp, content, risk_score, campaign_id):
        conn = get_db_connection()
        conn.execute('''
            INSERT INTO events_log (event_type, sender_number, timestamp, content, risk_score, campaign_id)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (event_type, sender, timestamp, content, risk_score, campaign_id))
        conn.commit()
        conn.close()

class CampaignRepository:
    @staticmethod
    def get_campaign(campaign_id):
        conn = get_db_connection()
        camp = conn.execute("SELECT * FROM campaigns WHERE campaign_id = ?", (campaign_id,)).fetchone()
        conn.close()
        return dict(camp) if camp else None

    @staticmethod
    def create_or_update(campaign_id, created_at, risk_score, risk_level, categories):
        conn = get_db_connection()
        existing = conn.execute("SELECT * FROM campaigns WHERE campaign_id = ?", (campaign_id,)).fetchone()
        
        if existing:
            conn.execute('''
                UPDATE campaigns
                SET last_updated = ?, risk_score = ?, risk_level = ?, categories = ?
                WHERE campaign_id = ?
            ''', (created_at, risk_score, risk_level, categories, campaign_id))
        else:
            conn.execute('''
                INSERT INTO campaigns (campaign_id, created_at, last_updated, risk_score, risk_level, categories, status)
                VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')
            ''', (campaign_id, created_at, created_at, risk_score, risk_level, categories))
        conn.commit()
        conn.close()

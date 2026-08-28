"""
language_manager.py
═══════════════════
Manages user language preferences and multilingual warning templates.

Supported languages: English (en), Tamil (ta)
All warnings are keyed by alert code so they can be looked up instantly
at runtime without any translation API calls.
"""

import logging
import aiosqlite
from pathlib import Path
from typing import Literal

logger = logging.getLogger(__name__)

# ── Database path ─────────────────────────────────────────────────────────────
DB_PATH = Path(__file__).parent / "user_preferences.db"

# ── Warning template registry ─────────────────────────────────────────────────
#
# Keys are alert codes produced by risk_engine.py.
# Each code maps to {"en": "English text", "ta": "Tamil text"}.
# Add more languages here by extending each dict entry.
#
ALERT_TEMPLATES: dict[str, dict[str, str]] = {

    "CRITICAL_SCAM_ALERT": {
        "en": (
            "🚨 CRITICAL ALERT: This is almost certainly a scam call. "
            "DO NOT share any OTP, bank details, or personal information. "
            "Hang up immediately and call your bank's official helpline."
        ),
        "ta": (
            "🚨 அவசர எச்சரிக்கை: இது ஒரு மோசடி அழைப்பு. "
            "உங்கள் OTP, வங்கி விவரங்கள் அல்லது தனிப்பட்ட தகவல்களை பகிர வேண்டாம். "
            "உடனே அழைப்பை நிறுத்தவும் மற்றும் உங்கள் வங்கியின் அதிகாரப்பூர்வ helpline-ஐ தொடர்பு கொள்ளவும்."
        ),
    },

    "HIGH_RISK_WARNING": {
        "en": (
            "⚠️ HIGH RISK: Multiple scam indicators detected on this call. "
            "Be very cautious. Never transfer money or share OTPs under pressure."
        ),
        "ta": (
            "⚠️ அதிக ஆபத்து: இந்த அழைப்பில் பல மோசடி அறிகுறிகள் கண்டறியப்பட்டுள்ளன. "
            "மிகவும் எச்சரிக்கையாக இருங்கள். அழுத்தத்தின் கீழ் பணம் அனுப்பவோ அல்லது OTP பகிரவோ வேண்டாம்."
        ),
    },

    "OTP_REQUEST_DETECTED": {
        "en": (
            "🔴 OTP REQUEST DETECTED: The caller is asking for your One-Time Password. "
            "No legitimate bank or government official will ever ask for your OTP. "
            "This is a scam — hang up now!"
        ),
        "ta": (
            "🔴 OTP கேட்கப்படுகிறது: அழைப்பாளர் உங்கள் ஒருமுறை கடவுச்சொல்லை கேட்கிறார். "
            "எந்த உண்மையான வங்கியும் அரசு அதிகாரியும் ஒருபோதும் உங்கள் OTP கேட்க மாட்டார்கள். "
            "இது ஒரு மோசடி — இப்போதே அழைப்பை நிறுத்துங்கள்!"
        ),
    },

    "BANK_IMPERSONATION_DETECTED": {
        "en": (
            "⚠️ BANK IMPERSONATION: Someone is pretending to be from your bank. "
            "Hang up and call your bank directly using the number on the back of your card."
        ),
        "ta": (
            "⚠️ வங்கி போலி அடையாளம்: யாரோ உங்கள் வங்கியிலிருந்து வருவதாக நடிக்கிறார்கள். "
            "அழைப்பை நிறுத்தவும் மற்றும் உங்கள் card-ன் பின்புறத்தில் உள்ள எண்ணை பயன்படுத்தி "
            "நேரடியாக உங்கள் வங்கியை தொடர்பு கொள்ளவும்."
        ),
    },

    "AUTHORITY_IMPERSONATION_DETECTED": {
        "en": (
            "🚨 AUTHORITY SCAM: The caller claims to be from police/CBI/income tax. "
            "Real law enforcement NEVER demands money over the phone. This is a scam!"
        ),
        "ta": (
            "🚨 அதிகார மோசடி: அழைப்பாளர் காவல்துறை/CBI/வருமான வரி அதிகாரி என்று கூறுகிறார். "
            "உண்மையான சட்ட அமலாக்கம் ஒருபோதும் தொலைபேசியில் பணம் கேட்காது. இது ஒரு மோசடி!"
        ),
    },

    "REMOTE_ACCESS_REQUESTED": {
        "en": (
            "🚨 REMOTE ACCESS SCAM: The caller wants you to install AnyDesk or TeamViewer. "
            "This will give them FULL CONTROL of your phone. Refuse immediately and hang up!"
        ),
        "ta": (
            "🚨 தொலைநிலை அணுகல் மோசடி: அழைப்பாளர் AnyDesk அல்லது TeamViewer நிறுவ கேட்கிறார். "
            "இது அவர்களுக்கு உங்கள் தொலைபேசியின் முழு கட்டுப்பாட்டை கொடுக்கும். "
            "உடனே மறுக்கவும் மற்றும் அழைப்பை நிறுத்தவும்!"
        ),
    },

    "MONEY_TRANSFER_DEMANDED": {
        "en": (
            "🔴 MONEY DEMAND DETECTED: The caller is pressuring you to transfer money urgently. "
            "Never transfer money to strangers under pressure. Hang up now!"
        ),
        "ta": (
            "🔴 பணம் கோரப்படுகிறது: அழைப்பாளர் உங்களை அவசரமாக பணம் மாற்ற நிர்பந்திக்கிறார். "
            "அழுத்தத்தின் கீழ் அந்நியர்களுக்கு பணம் மாற்ற வேண்டாம். இப்போதே அழைப்பை நிறுத்துங்கள்!"
        ),
    },

    "SUSPICIOUS_SMS_DURING_CALL": {
        "en": (
            "⚠️ SUSPICIOUS SMS: You received a link via SMS/WhatsApp during this call. "
            "Scammers often send fake links while keeping you on the phone. Do NOT click it!"
        ),
        "ta": (
            "⚠️ சந்தேகத்திற்குரிய SMS: இந்த அழைப்பின் போது SMS/WhatsApp மூலம் link கிடைத்தது. "
            "மோசடி செய்பவர்கள் தொலைபேசியில் வைத்துக்கொண்டு போலி links அனுப்புவார்கள். "
            "அதை click செய்யாதீர்கள்!"
        ),
    },

    "FINANCIAL_APP_OPEN_DURING_CALL": {
        "en": (
            "🚨 FINANCIAL APP ALERT: You opened GPay/PhonePe or a financial app during this call. "
            "Scammers may be guiding you to transfer money. Stop and hang up immediately!"
        ),
        "ta": (
            "🚨 நிதி செயலி எச்சரிக்கை: இந்த அழைப்பின் போது GPay/PhonePe அல்லது நிதி செயலியை திறந்தீர்கள். "
            "மோசடி செய்பவர்கள் பணம் மாற்ற வழிகாட்டுவார்கள். நிறுத்தி உடனே அழைப்பை நிறுத்துங்கள்!"
        ),
    },

    "CALL_SAFE": {
        "en": "✅ Call appears safe. No scam indicators detected so far.",
        "ta": "✅ அழைப்பு பாதுகாப்பானதாக தெரிகிறது. இதுவரை மோசடி அறிகுறிகள் எதுவும் கண்டறியப்படவில்லை.",
    },
}

SUPPORTED_LANGUAGES = {"en", "ta"}
DEFAULT_LANGUAGE = "en"


# ── Database setup ────────────────────────────────────────────────────────────
async def init_db():
    """Create user_preferences table if it doesn't exist."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS user_preferences (
                user_id          TEXT PRIMARY KEY,
                preferred_language TEXT NOT NULL DEFAULT 'en',
                updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        await db.commit()
    logger.info("User preferences DB initialised.")


# ── Preference management ─────────────────────────────────────────────────────
async def set_user_language(user_id: str, language: str) -> dict:
    """
    Persist a user's preferred language.

    Args:
        user_id:  Unique identifier for the user.
        language: ISO 639-1 code ('en' or 'ta').

    Returns:
        dict with status and confirmed language.
    """
    if language not in SUPPORTED_LANGUAGES:
        return {
            "success": False,
            "error": f"Language '{language}' not supported. Choose from {SUPPORTED_LANGUAGES}",
        }

    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            """
            INSERT INTO user_preferences (user_id, preferred_language, updated_at)
            VALUES (?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(user_id) DO UPDATE SET
                preferred_language = excluded.preferred_language,
                updated_at         = CURRENT_TIMESTAMP
            """,
            (user_id, language),
        )
        await db.commit()

    logger.info(f"[LangManager] Set language for user {user_id} → {language}")
    return {"success": True, "user_id": user_id, "preferred_language": language}


async def get_user_language(user_id: str) -> str:
    """
    Retrieve a user's preferred language. Falls back to DEFAULT_LANGUAGE.
    """
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute(
            "SELECT preferred_language FROM user_preferences WHERE user_id = ?",
            (user_id,),
        ) as cursor:
            row = await cursor.fetchone()

    return row[0] if row else DEFAULT_LANGUAGE


# ── Warning resolution ─────────────────────────────────────────────────────────
def get_warning(alert_code: str, language: str = "en") -> str:
    """
    Resolve an alert code into a localised warning string.

    Args:
        alert_code: Key from ALERT_TEMPLATES (e.g. 'CRITICAL_SCAM_ALERT').
        language:   ISO 639-1 language code.

    Returns:
        Localised warning string. Falls back to English if language not found.
    """
    if language not in SUPPORTED_LANGUAGES:
        language = DEFAULT_LANGUAGE

    template = ALERT_TEMPLATES.get(alert_code)
    if template is None:
        logger.warning(f"Unknown alert code: {alert_code}")
        return ALERT_TEMPLATES["CALL_SAFE"][language]

    return template.get(language) or template.get(DEFAULT_LANGUAGE, "Warning!")


def get_all_warnings_for_codes(
    alert_codes: list[str], language: str = "en"
) -> list[dict]:
    """
    Resolve multiple alert codes into localised warning dicts.
    Used when building a full session status response.
    """
    return [
        {"code": code, "message": get_warning(code, language)}
        for code in alert_codes
    ]

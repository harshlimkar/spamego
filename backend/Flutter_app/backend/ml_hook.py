"""
ml_hook.py
──────────
Clean integration wrapper for the existing ML scam classification model.

HOW TO PLUG IN YOUR MODEL:
  Replace the body of `_run_model(transcript)` below with your actual
  model inference call. The rest of the pipeline (server.py, Flutter UI)
  only depends on the dict schema returned by `predict_scam_intent`.

Expected return schema:
  {
    "is_scam":        bool,   # True if scam detected
    "risk_score":     int,    # 0–100
    "threat_type":    str,    # e.g. "OTP_REQUEST", "BANK_IMPERSONATION", "SAFE"
    "warning_message": str    # Human-readable warning for the UI
  }
"""

import logging
import sys
import os

logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────
# Import your existing ML model here.
# Example:
#   sys.path.append(os.path.join(os.path.dirname(__file__), '../../call_scam_detection/backend/ml_model'))
#   from model import predict_risk as _ml_predict
# ──────────────────────────────────────────────
# For now, we use a robust keyword-based classifier as the default.
# Replace `_run_model` below to wire in the real model.

_SCAM_PATTERNS = {
    "OTP_REQUEST": [
        "otp", "one time password", "verification code", "don't share",
        "एक बार का पासवर्ड", "कोड बताइए", "code batao"
    ],
    "BANK_IMPERSONATION": [
        "bank", "account blocked", "kyc", "branch manager", "rbi", "reserve bank",
        "बैंक", "खाता बंद", "केवाईसी"
    ],
    "AUTHORITY_IMPERSONATION": [
        "police", "cbi", "income tax", "arrest", "warrant", "case filed",
        "पुलिस", "गिरफ्तारी", "सीबीआई"
    ],
    "MONEY_DEMAND": [
        "transfer money", "send money", "upi", "pay now", "fine", "challan",
        "पैसे भेजो", "ट्रांसफर करो"
    ],
    "REMOTE_ACCESS": [
        "anydesk", "teamviewer", "screen share", "remote access", "download app",
        "स्क्रीन शेयर"
    ],
    "URGENCY": [
        "urgent", "immediately", "right now", "last chance", "24 hours",
        "अभी", "तुरंत", "जल्दी"
    ],
}


def _run_model(transcript: str) -> dict:
    """
    ── REPLACE THIS FUNCTION BODY WITH YOUR REAL ML MODEL ──

    Input:  transcript (str) - live speech-to-text chunk
    Output: dict with keys: is_scam, risk_score, threat_type, warning_message
    """
    transcript_lower = transcript.lower()
    matched_threats = []
    hit_count = 0

    for threat_type, keywords in _SCAM_PATTERNS.items():
        hits = [kw for kw in keywords if kw in transcript_lower]
        if hits:
            matched_threats.append(threat_type)
            hit_count += len(hits)

    # Score: each unique keyword hit adds ~15 points, capped at 100
    risk_score = min(hit_count * 15, 100)
    is_scam = risk_score >= 30

    primary_threat = matched_threats[0] if matched_threats else "SAFE"

    warning_messages = {
        "OTP_REQUEST":            "⚠️ Caller is asking for OTP! Never share your OTP with anyone.",
        "BANK_IMPERSONATION":     "⚠️ Possible bank impersonation detected. Hang up and call your bank directly.",
        "AUTHORITY_IMPERSONATION":"🚨 Caller claims to be police/CBI. This is a common scam. Hang up now.",
        "MONEY_DEMAND":           "🚨 Caller is demanding money transfer. Do NOT pay.",
        "REMOTE_ACCESS":          "🚨 Caller is asking for remote access to your device. Refuse immediately.",
        "URGENCY":                "⚠️ Caller is creating artificial urgency — a classic scam tactic.",
        "SAFE":                   "✅ Call appears safe.",
    }

    return {
        "is_scam": is_scam,
        "risk_score": risk_score,
        "threat_type": primary_threat,
        "warning_message": warning_messages.get(primary_threat, "⚠️ Potential threat detected."),
    }


def predict_scam_intent(transcript: str) -> dict:
    """
    Public API used by server.py.
    Wraps _run_model with error handling.
    Always returns a valid dict matching the expected schema.
    """
    if not transcript or not transcript.strip():
        return {
            "is_scam": False,
            "risk_score": 0,
            "threat_type": "SAFE",
            "warning_message": "✅ Call appears safe.",
        }
    try:
        result = _run_model(transcript)
        logger.info(
            f"[ML] is_scam={result['is_scam']} "
            f"risk={result['risk_score']} "
            f"type={result['threat_type']}"
        )
        return result
    except Exception as e:
        logger.error(f"ML model error: {e}")
        return {
            "is_scam": False,
            "risk_score": 0,
            "threat_type": "ERROR",
            "warning_message": "Model inference failed.",
        }

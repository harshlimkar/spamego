"""
risk_engine.py
══════════════
Multimodal Risk Allocation Engine for the Scam Protection System.

The `SessionRiskCalculator` is a temporal state machine that:
  - Aggregates risk from multiple signal sources during a live session.
  - Calls the fine-tuned MuRIL model for NLP-based intent classification.
  - Fires specific alert codes that language_manager resolves into warnings.

Risk Factor Allocation:
  +15  Unknown / unverified caller number
  +10  Call duration > 2 minutes
  +40  MuRIL classifies transcript chunk as SCAM intent
  +25  SMS/WhatsApp with link received within 10 min of call start
  +45  Financial or remote-access app opened during the active call
  ─────
  Max 135 (intentionally > 100 to be additive; capped at 100 for output)

  CRITICAL_SCAM_ALERT fires when cumulative score > 85.
"""

import time
import logging
import threading
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

logger = logging.getLogger(__name__)

# ── Model configuration ───────────────────────────────────────────────────────
SAVED_MODEL_DIR = Path(__file__).parent / "saved_model"
FALLBACK_MODEL  = "google/muril-base-cased"   # used if saved_model/ is empty
MAX_TOKEN_LEN   = 256
CRITICAL_THRESHOLD = 85

# ── Risk point values ─────────────────────────────────────────────────────────
RISK_UNKNOWN_CALLER    = 15
RISK_LONG_CALL         = 10
RISK_MURIL_SCAM        = 40
RISK_SMS_LINK          = 25
RISK_FINANCIAL_APP     = 45

# Maps model output → alert code
SCAM_ALERT_CODE = "CRITICAL_SCAM_ALERT"


# ── Singleton model loader ─────────────────────────────────────────────────────
class MuRILClassifier:
    """
    Thread-safe singleton that loads the fine-tuned MuRIL model once and
    caches it in memory for the lifetime of the process.
    """
    _instance: Optional["MuRILClassifier"] = None
    _lock = threading.Lock()

    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        model_dir = (
            str(SAVED_MODEL_DIR)
            if any(SAVED_MODEL_DIR.iterdir())
            else FALLBACK_MODEL
        )
        logger.info(f"[MuRIL] Loading model from: {model_dir} on {self.device}")

        self.tokenizer = AutoTokenizer.from_pretrained(model_dir)
        self.model = AutoModelForSequenceClassification.from_pretrained(model_dir)
        self.model.to(self.device)
        self.model.eval()
        logger.info("[MuRIL] Model loaded and ready.")

    @classmethod
    def get_instance(cls) -> "MuRILClassifier":
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = cls()
        return cls._instance

    def predict(self, text: str) -> dict:
        """
        Predict scam intent for a text chunk.

        Returns:
            {
              "label":      "SCAM" | "SAFE",
              "confidence": float (0.0 – 1.0),
              "is_scam":    bool,
            }
        """
        if not text or not text.strip():
            return {"label": "SAFE", "confidence": 1.0, "is_scam": False}

        inputs = self.tokenizer(
            text,
            return_tensors="pt",
            max_length=MAX_TOKEN_LEN,
            truncation=True,
            padding=True,
        ).to(self.device)

        with torch.no_grad():
            logits = self.model(**inputs).logits

        probs     = torch.softmax(logits, dim=-1).squeeze()
        scam_prob = probs[1].item()           # index 1 = SCAM
        label     = "SCAM" if scam_prob >= 0.5 else "SAFE"

        return {
            "label":      label,
            "confidence": round(scam_prob if label == "SCAM" else 1 - scam_prob, 4),
            "is_scam":    label == "SCAM",
        }


# ── Session data model ────────────────────────────────────────────────────────
@dataclass
class SessionState:
    user_id:           str
    call_start_time:   float = field(default_factory=time.time)
    is_unknown_caller: bool  = True
    risk_score:        int   = 0
    alert_codes:       list  = field(default_factory=list)
    transcript_chunks: list  = field(default_factory=list)
    sms_link_received: bool  = False
    sms_receive_time:  Optional[float] = None
    financial_app_opened: bool = False
    long_call_risk_applied:    bool = False
    caller_risk_applied:       bool = False
    is_critical:       bool  = False

    def call_duration_seconds(self) -> float:
        return time.time() - self.call_start_time


# ── Temporal State Machine ────────────────────────────────────────────────────
class SessionRiskCalculator:
    """
    Temporal state machine that accumulates risk signals across the lifetime
    of a single phone call session.

    Usage:
        calc = SessionRiskCalculator()
        calc.start_session("user_123", is_unknown_caller=True)
        calc.ingest_event("user_123", {"type": "transcript", "text": "Share your OTP now"})
        status = calc.get_status("user_123")
    """

    def __init__(self):
        self._sessions: dict[str, SessionState] = {}
        self._lock = threading.Lock()
        # Initialise the MuRIL model eagerly (pre-warm)
        try:
            MuRILClassifier.get_instance()
        except Exception as e:
            logger.warning(f"MuRIL model pre-warm failed (will retry on first use): {e}")

    # ── Session lifecycle ─────────────────────────────────────────────────────
    def start_session(self, user_id: str, is_unknown_caller: bool = True) -> SessionState:
        """Initialise a new call session for a user."""
        with self._lock:
            session = SessionState(
                user_id=user_id,
                is_unknown_caller=is_unknown_caller,
            )
            self._sessions[user_id] = session
            logger.info(f"[Session] Started for user={user_id} unknown_caller={is_unknown_caller}")

        # Apply immediate static signals
        self._apply_caller_profile(session)
        return session

    def end_session(self, user_id: str):
        """Remove session data after the call ends."""
        with self._lock:
            self._sessions.pop(user_id, None)
        logger.info(f"[Session] Ended for user={user_id}")

    def get_session(self, user_id: str) -> Optional[SessionState]:
        return self._sessions.get(user_id)

    # ── Event ingestion ───────────────────────────────────────────────────────
    def ingest_event(self, user_id: str, event: dict) -> SessionState:
        """
        Route an incoming event to the correct risk handler.

        Supported event types:
          - "call_started"    : {"type": "call_started", "is_unknown_caller": bool}
          - "transcript"      : {"type": "transcript", "text": str}
          - "sms_received"    : {"type": "sms_received", "has_link": bool}
          - "app_opened"      : {"type": "app_opened", "app_name": str}
          - "call_duration"   : {"type": "call_duration", "seconds": float}  (periodic)
        """
        session = self._sessions.get(user_id)
        if session is None:
            is_unknown = event.get("is_unknown_caller", True)
            session = self.start_session(user_id, is_unknown_caller=is_unknown)

        event_type = event.get("type", "unknown")

        if event_type == "call_started":
            session.is_unknown_caller = event.get("is_unknown_caller", True)
            self._apply_caller_profile(session)

        elif event_type == "transcript":
            text = event.get("text", "")
            if text:
                self._apply_muril_nlp(session, text)

        elif event_type == "sms_received":
            if event.get("has_link", False):
                self._apply_sms_link_risk(session)

        elif event_type == "app_opened":
            app_name = event.get("app_name", "").lower()
            self._apply_app_usage_risk(session, app_name)

        elif event_type == "call_duration":
            seconds = event.get("seconds", session.call_duration_seconds())
            if seconds > 120:                          # > 2 minutes
                self._apply_long_call_risk(session)

        # Always re-check duration from wall clock
        if session.call_duration_seconds() > 120:
            self._apply_long_call_risk(session)

        # Check critical threshold
        self._check_critical(session)

        logger.info(
            f"[Risk] user={user_id} event={event_type} "
            f"score={session.risk_score} critical={session.is_critical}"
        )
        return session

    # ── Risk application methods ──────────────────────────────────────────────
    def _apply_caller_profile(self, session: SessionState):
        """
        Signal 1: Unknown caller.
        Applied once per session at start.
        """
        if not session.caller_risk_applied and session.is_unknown_caller:
            session.risk_score += RISK_UNKNOWN_CALLER
            session.caller_risk_applied = True
            logger.debug(f"[Risk] +{RISK_UNKNOWN_CALLER} unknown caller → {session.risk_score}")

    def _apply_long_call_risk(self, session: SessionState):
        """
        Signal 2: Call duration > 2 minutes.
        Applied once per session.
        """
        if not session.long_call_risk_applied:
            session.risk_score += RISK_LONG_CALL
            session.long_call_risk_applied = True
            logger.debug(f"[Risk] +{RISK_LONG_CALL} long call → {session.risk_score}")

    def _apply_muril_nlp(self, session: SessionState, text: str):
        """
        Signal 3: MuRIL NLP intent classification on a live transcript chunk.
        If the model predicts SCAM, add +40 and record the alert code.
        Can fire multiple times (one per transcript chunk) but risk is additive.
        """
        session.transcript_chunks.append(text)

        try:
            classifier = MuRILClassifier.get_instance()
            result = classifier.predict(text)
        except Exception as e:
            logger.error(f"MuRIL prediction error: {e}")
            return

        if result["is_scam"]:
            session.risk_score += RISK_MURIL_SCAM

            # Map to specific alert codes based on content
            alert_code = self._resolve_nlp_alert_code(text)
            if alert_code not in session.alert_codes:
                session.alert_codes.append(alert_code)

            logger.info(
                f"[MuRIL] SCAM detected (conf={result['confidence']:.2f}) "
                f"→ +{RISK_MURIL_SCAM} → score={session.risk_score}"
            )

    def _apply_sms_link_risk(self, session: SessionState):
        """
        Signal 4: SMS/WhatsApp with a link received within 10 min of call start.
        Applied once per session.
        """
        if session.sms_link_received:
            return

        elapsed = session.call_duration_seconds()
        if elapsed <= 600:                             # within 10 minutes
            session.risk_score += RISK_SMS_LINK
            session.sms_link_received = True
            session.sms_receive_time = time.time()

            if "SUSPICIOUS_SMS_DURING_CALL" not in session.alert_codes:
                session.alert_codes.append("SUSPICIOUS_SMS_DURING_CALL")

            logger.debug(f"[Risk] +{RISK_SMS_LINK} SMS link during call → {session.risk_score}")

    def _apply_app_usage_risk(self, session: SessionState, app_name: str):
        """
        Signal 5: Financial or remote-access app opened during the call.
        Applied once per session.
        """
        if session.financial_app_opened:
            return

        FINANCIAL_APPS = {"gpay", "phonepe", "paytm", "bhim", "amazon_pay", "freecharge"}
        REMOTE_ACCESS_APPS = {"anydesk", "teamviewer", "rustdesk", "airdroid", "remotepc"}

        is_financial    = any(fa in app_name for fa in FINANCIAL_APPS)
        is_remote_access = any(ra in app_name for ra in REMOTE_ACCESS_APPS)

        if is_financial or is_remote_access:
            session.risk_score += RISK_FINANCIAL_APP
            session.financial_app_opened = True

            alert_code = (
                "REMOTE_ACCESS_REQUESTED"   if is_remote_access
                else "FINANCIAL_APP_OPEN_DURING_CALL"
            )
            if alert_code not in session.alert_codes:
                session.alert_codes.append(alert_code)

            logger.info(
                f"[Risk] +{RISK_FINANCIAL_APP} app_opened='{app_name}' "
                f"→ score={session.risk_score}"
            )

    # ── Critical threshold check ──────────────────────────────────────────────
    def _check_critical(self, session: SessionState):
        """If score exceeds threshold, flag the session and ensure alert code is present."""
        # Cap displayed score at 100
        session.risk_score = min(session.risk_score, 100)

        if session.risk_score > CRITICAL_THRESHOLD and not session.is_critical:
            session.is_critical = True
            if "CRITICAL_SCAM_ALERT" not in session.alert_codes:
                session.alert_codes.insert(0, "CRITICAL_SCAM_ALERT")   # top priority
            logger.warning(
                f"🚨 CRITICAL_SCAM_ALERT fired for user={session.user_id} "
                f"score={session.risk_score}"
            )

    # ── NLP alert code resolution ─────────────────────────────────────────────
    @staticmethod
    def _resolve_nlp_alert_code(text: str) -> str:
        """
        Map transcript content to a specific alert code using lightweight keyword
        matching (supplements the MuRIL classification with a more specific label).
        """
        text_lower = text.lower()

        OTP_KEYWORDS     = ["otp", "one time", "verification code", "கடவுச்சொல்", "कोड"]
        BANK_KEYWORDS    = ["bank", "account", "kyc", "rbi", "வங்கி", "बैंक"]
        AUTHORITY_KW     = ["police", "cbi", "arrest", "warrant", "பொலிஸ்", "गिरफ्तार"]
        REMOTE_KW        = ["anydesk", "teamviewer", "screen share", "remote"]
        MONEY_KW         = ["transfer", "upi", "pay", "fine", "பணம்", "पैसे"]

        for kw in OTP_KEYWORDS:
            if kw in text_lower:
                return "OTP_REQUEST_DETECTED"
        for kw in AUTHORITY_KW:
            if kw in text_lower:
                return "AUTHORITY_IMPERSONATION_DETECTED"
        for kw in REMOTE_KW:
            if kw in text_lower:
                return "REMOTE_ACCESS_REQUESTED"
        for kw in BANK_KEYWORDS:
            if kw in text_lower:
                return "BANK_IMPERSONATION_DETECTED"
        for kw in MONEY_KW:
            if kw in text_lower:
                return "MONEY_TRANSFER_DEMANDED"

        return "HIGH_RISK_WARNING"   # generic scam fallback

    # ── Status snapshot ───────────────────────────────────────────────────────
    def get_status(self, user_id: str) -> dict:
        """
        Return the full status snapshot for a session.
        Used by GET /api/session/{user_id}/status in main.py.
        """
        session = self._sessions.get(user_id)
        if session is None:
            return {
                "user_id":     user_id,
                "active":      False,
                "risk_score":  0,
                "is_critical": False,
                "alert_codes": [],
            }

        return {
            "user_id":            session.user_id,
            "active":             True,
            "risk_score":         session.risk_score,
            "is_critical":        session.is_critical,
            "alert_codes":        session.alert_codes,
            "call_duration_secs": round(session.call_duration_seconds(), 1),
            "transcript_count":   len(session.transcript_chunks),
        }

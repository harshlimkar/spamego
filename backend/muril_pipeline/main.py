"""
main.py
═══════
FastAPI backend for the Multimodal Scam Protection System.

Endpoints:
  POST /api/user/preference           → Set user's language preference
  GET  /api/user/{user_id}/preference → Get user's language preference
  POST /api/events/ingest             → Ingest a live event for a session
  POST /api/session/{user_id}/start   → Explicitly start a session
  POST /api/session/{user_id}/end     → End a session
  GET  /api/session/{user_id}/status  → Get current risk status + localised warnings

MuRIL model is loaded into memory on server startup (lifespan event).
"""

import logging
import time
from contextlib import asynccontextmanager
from typing import Literal, Optional

from fastapi import FastAPI, HTTPException, Path
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from language_manager import (
    init_db,
    set_user_language,
    get_user_language,
    get_all_warnings_for_codes,
    get_warning,
    SUPPORTED_LANGUAGES,
)
from risk_engine import SessionRiskCalculator, MuRILClassifier

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

# ── Global engine (singleton for the process) ─────────────────────────────────
risk_calculator = SessionRiskCalculator()


# ── Lifespan: startup / shutdown ──────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Pre-warm the MuRIL model and initialise DB before serving traffic."""
    logger.info("🚀 Starting up Scam Protection API …")

    # 1. Init SQLite preferences DB
    await init_db()

    # 2. Pre-load MuRIL model into memory (takes 10–30 seconds)
    try:
        MuRILClassifier.get_instance()
        logger.info("✅ MuRIL model loaded and ready.")
    except Exception as e:
        logger.error(f"❌ Failed to load MuRIL model: {e}")
        logger.warning("   API will still serve but NLP scoring will be skipped.")

    yield    # ← Server is live and serving requests

    logger.info("🛑 Shutting down …")


# ── FastAPI app ───────────────────────────────────────────────────────────────
app = FastAPI(
    title="Scam Protection System — MuRIL API",
    description=(
        "Real-time multimodal scam detection for Indian senior citizens.\n"
        "Uses fine-tuned google/muril-base-cased for multilingual NLP analysis."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Pydantic request/response models ──────────────────────────────────────────
class UserPreferenceRequest(BaseModel):
    user_id:            str  = Field(..., example="user_123")
    preferred_language: str  = Field(..., example="ta", description="'en' or 'ta'")


class StartSessionRequest(BaseModel):
    is_unknown_caller: bool = Field(True, description="True if caller is not in contacts")


class EventPayload(BaseModel):
    """
    A live event from the device. Supported types:

    | type            | extra fields                        |
    |-----------------|-------------------------------------|
    | call_started    | is_unknown_caller: bool             |
    | transcript      | text: str                           |
    | sms_received    | has_link: bool                      |
    | app_opened      | app_name: str                       |
    | call_duration   | seconds: float                      |
    """
    user_id:           str  = Field(..., example="user_123")
    type:              str  = Field(..., example="transcript")
    # Optional fields depending on event type
    text:              Optional[str]   = None
    is_unknown_caller: Optional[bool]  = None
    has_link:          Optional[bool]  = None
    app_name:          Optional[str]   = None
    seconds:           Optional[float] = None


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.post("/api/user/preference", tags=["User"])
async def set_preference(req: UserPreferenceRequest):
    """
    Set a user's preferred language for warnings and alerts.
    Supported: 'en' (English), 'ta' (Tamil).
    """
    result = await set_user_language(req.user_id, req.preferred_language)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])

    return {
        "success":            True,
        "user_id":            req.user_id,
        "preferred_language": req.preferred_language,
        "message": (
            f"Language preference set to '{req.preferred_language}' successfully."
        ),
    }


@app.get("/api/user/{user_id}/preference", tags=["User"])
async def get_preference(user_id: str = Path(..., example="user_123")):
    """Get a user's currently saved language preference."""
    language = await get_user_language(user_id)
    return {"user_id": user_id, "preferred_language": language}


@app.post("/api/session/{user_id}/start", tags=["Session"])
async def start_session(
    user_id: str = Path(..., example="user_123"),
    req: StartSessionRequest = StartSessionRequest(),
):
    """Explicitly start a monitoring session for a user."""
    session = risk_calculator.start_session(user_id, is_unknown_caller=req.is_unknown_caller)
    return {
        "success":          True,
        "user_id":          user_id,
        "risk_score":       session.risk_score,
        "started_at":       session.call_start_time,
        "is_unknown_caller": req.is_unknown_caller,
    }


@app.post("/api/session/{user_id}/end", tags=["Session"])
async def end_session(user_id: str = Path(..., example="user_123")):
    """End a monitoring session and clear session data."""
    final_status = risk_calculator.get_status(user_id)
    risk_calculator.end_session(user_id)
    return {"success": True, "user_id": user_id, "final_status": final_status}


@app.post("/api/events/ingest", tags=["Events"])
async def ingest_event(payload: EventPayload):
    """
    Ingest a live event from the mobile app.

    The event is routed to the `SessionRiskCalculator`, which updates
    the session risk score and fires alerts if thresholds are breached.

    Returns the updated session risk summary.
    """
    event_dict = payload.model_dump(exclude_none=True)
    user_id = event_dict.pop("user_id")

    try:
        session = risk_calculator.ingest_event(user_id, event_dict)
    except Exception as e:
        logger.error(f"Event ingestion error for user={user_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Event processing failed: {str(e)}")

    # Get localised warnings
    language = await get_user_language(user_id)
    warnings = get_all_warnings_for_codes(session.alert_codes, language)

    return {
        "user_id":           user_id,
        "event_type":        payload.type,
        "risk_score":        session.risk_score,
        "is_critical":       session.is_critical,
        "alert_codes":       session.alert_codes,
        "localised_warnings": warnings,
        "language":          language,
    }


@app.get("/api/session/{user_id}/status", tags=["Session"])
async def get_session_status(user_id: str = Path(..., example="user_123")):
    """
    Get the current risk score and localised warning messages for a user.

    If the user's risk score has exceeded the critical threshold (85),
    the response will include 'is_critical: true' and a full list of
    localised warning messages in the user's preferred language.
    """
    status = risk_calculator.get_status(user_id)
    language = await get_user_language(user_id)

    # Resolve all alert codes into localised warnings
    localised_warnings = get_all_warnings_for_codes(status["alert_codes"], language)

    # Build a single primary warning message
    if status["is_critical"]:
        primary_warning = get_warning("CRITICAL_SCAM_ALERT", language)
    elif status["alert_codes"]:
        primary_warning = get_warning(status["alert_codes"][0], language)
    else:
        primary_warning = get_warning("CALL_SAFE", language)

    return {
        **status,
        "language":          language,
        "primary_warning":   primary_warning,
        "localised_warnings": localised_warnings,
        "timestamp":         time.time(),
    }


@app.get("/api/health", tags=["Health"])
async def health_check():
    """Service health and model status check."""
    model_loaded = MuRILClassifier._instance is not None
    return {
        "status":       "healthy",
        "model_loaded": model_loaded,
        "active_sessions": len(risk_calculator._sessions),
    }


# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8002,
        reload=False,           # disable reload in production
        log_level="info",
    )

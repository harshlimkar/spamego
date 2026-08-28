from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional

from firewall import firewall as _firewall
from firewall.campaign_engine import load_history
from firewall.recovery import recovery_plan, reporting_plan
from database.db_setup import init_db, seed_db

router = APIRouter(prefix="/intel", tags=["firewall"])


class AnalyzeRequest(BaseModel):
    channel: str = "sms"
    sender: Optional[str] = None
    number: Optional[str] = None
    text: Optional[str] = None
    content: Optional[str] = None
    transcript: Optional[str] = None
    amount_inr: Optional[float] = None
    upi_id: Optional[str] = None
    url: Optional[str] = None
    recipient: Optional[str] = None
    timestamp: Optional[str] = None


class VerifyNumberRequest(BaseModel):
    number: str


class VerifyLinkRequest(BaseModel):
    url: str


class VerifyAppRequest(BaseModel):
    app_name: str


@router.get("/healthz")
def healthz():
    init_db()
    seed_db()
    return {"status": "ok", "engine": "unified-firewall"}


@router.post("/analyze")
def analyze_event(payload: AnalyzeRequest):
    try:
        event = {
            "channel": payload.channel or "sms",
            "sender": payload.sender or payload.number or None,
            "text": payload.text or payload.content or payload.transcript or None,
            "amount_inr": payload.amount_inr,
            "upi_id": payload.upi_id,
            "url": payload.url,
            "recipient": payload.recipient,
            "timestamp": payload.timestamp,
        }
        result = _firewall.analyze_event(event)
        return result
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/verify/number")
def verify_number(payload: VerifyNumberRequest):
    return _firewall.verifier.verify_number(payload.number)


@router.post("/verify/link")
def verify_link(payload: VerifyLinkRequest):
    from firewall.entities import link_analyzer
    finding = link_analyzer.analyze(payload.url)
    verification = _firewall.verifier.verify_domain(finding["domain"], payload.url)
    return {"link": finding, "verification": _to_dict(verification)}


@router.post("/verify/application")
def verify_application(payload: VerifyAppRequest):
    return _to_dict(_firewall.verifier.verify_app(payload.app_name))


@router.get("/campaigns")
def list_campaigns():
    campaigns, events = load_history()
    return {"campaigns": campaigns, "events": events}


@router.get("/campaign/{campaign_id}")
def campaign_detail(campaign_id: str):
    campaigns, events = load_history()
    campaign = next((c for c in campaigns if c.get("campaign_id") == campaign_id), None)
    if campaign is None:
        raise HTTPException(status_code=404, detail="campaign not found")
    related = [e for e in events if e.get("campaign_id") == campaign_id]
    return {"campaign": campaign, "events": related}


@router.get("/history")
def history(channel: Optional[str] = None, min_risk: Optional[int] = None):
    campaigns, events = load_history()
    filtered = []
    for e in events:
        if channel and e.get("event_type") and e["event_type"].lower() != channel.lower():
            continue
        if min_risk is not None and (e.get("risk_score") or 0) < min_risk:
            continue
        filtered.append(e)
    return {"events": filtered, "campaigns": campaigns}


@router.post("/report")
def report_scam(sender: Optional[str] = None, report_type: str = "scam"):
    from database.repository import NumberRepository
    if not sender:
        raise HTTPException(status_code=400, detail="sender number required")
    try:
        conn = _get_conn()
        existing = conn.execute("SELECT * FROM reported_numbers WHERE number = ?", (sender,)).fetchone()
        if existing:
            conn.execute("UPDATE reported_numbers SET report_count = report_count + 1, last_reported = date('now') WHERE number = ?", (sender,))
        else:
            conn.execute("INSERT INTO reported_numbers (number, report_type, category, report_count, first_reported, last_reported) VALUES (?, ?, ?, 1, date('now'), date('now'))", (sender, report_type, "User Report"))
        conn.commit()
        conn.close()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
    return {"status": "reported", "number": sender}


@router.get("/recovery")
def recovery():
    return recovery_plan()


def _get_conn():
    from database.db_setup import get_db_connection
    return get_db_connection()


def _to_dict(obj):
    import dataclasses
    if dataclasses.is_dataclass(obj):
        return dataclasses.asdict(obj)
    return obj
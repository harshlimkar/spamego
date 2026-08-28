from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database.base import get_db
import sys
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from firewall.pipeline import firewall
from firewall.schema import to_dict

router = APIRouter()


class AnalyzeRequest(BaseModel):
    text: str
    sender: str = ""
    channel: str = "sms"
    upi_id: str | None = None
    amount_inr: float | None = None
    url: str | None = None
    recipient: str | None = None
    timestamp: str | None = None


class AnalyzeResponse(BaseModel):
    risk_score: int
    risk_level: str
    detected_stage: str
    campaign_id: str
    exposure: dict
    verdict: str
    headline: str
    confidence: float
    explanations: list[str]
    intervention: dict
    family_alert: dict
    recovery: dict | None = None
    support_sms: str | None = None
    intents: list[dict] = []
    stage: dict
    entities: dict
    link_findings: list[dict] = []
    otp: dict
    verification: dict
    ml: dict


@router.post("/firewall/analyze", response_model=AnalyzeResponse)
async def analyze_firewall(payload: AnalyzeRequest, db: Session = Depends(get_db)):
    event = {
        "text": payload.text,
        "sender": payload.sender,
        "channel": payload.channel,
        "upi_id": payload.upi_id,
        "amount_inr": payload.amount_inr,
        "url": payload.url,
        "recipient": payload.recipient,
        "timestamp": payload.timestamp,
    }

    try:
        result = firewall.analyze_event(event)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")

    campaign = result.get("campaign", {})
    risk = result.get("risk", {})
    exposure = campaign.get("exposure", {})

    return AnalyzeResponse(
        risk_score=risk.get("score", 0),
        risk_level=risk.get("level", "safe"),
        detected_stage=result.get("stage", {}).get("stage", "delivery"),
        campaign_id=campaign.get("campaign_id", ""),
        exposure=exposure,
        verdict=result.get("verdict", "UNKNOWN"),
        headline=result.get("headline", ""),
        confidence=risk.get("confidence", 0.0),
        explanations=risk.get("explanations", []),
        intervention=result.get("intervention", {}),
        family_alert=result.get("family_alert", {}),
        recovery=result.get("recovery"),
        support_sms=result.get("support_sms"),
        intents=result.get("intents", []),
        stage=result.get("stage", {}),
        entities=result.get("entities", {}),
        link_findings=result.get("link_findings", []),
        otp=result.get("otp", {}),
        verification=result.get("verification", {}),
        ml=result.get("ml", {}),
    )
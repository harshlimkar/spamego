from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import json
import asyncio
import sys
import os

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

from backend.app.database.base import get_db
from llm.orchestrator import create_agent, ScameGoAgent
from llm.database import AgentDatabaseService
from llm.schemas import (
    AgentEventInput, AgentEventInputSMS, AgentEventInputCall, 
    AgentEventInputPayment, AgentEventInputSocial,
    AgentDecision, Campaign, AgentAlert, TrustedContact,
    ConsentRecord, UserFeedback, FeedbackType, RecoveryAction,
    ExposureAssessment, RiskLevel, ScamStage
)
from llm.trusted_contacts import TrustedContactManager
from llm.recovery import RecoveryEngine
from llm.config import config

router = APIRouter(prefix="/api/agent", tags=["agent"])


# Request/Response Models
class EventResponse(BaseModel):
    event_id: str
    campaign_id: Optional[str]
    classification: str
    risk_score: int
    risk_level: str
    stage: str
    intent: List[str]
    exposure: Dict[str, Any]
    legitimacy: Dict[str, Any]
    explanation: str
    recommended_action: str
    intervention_level: str
    actions: List[str]
    notify_trusted_contact: bool
    recovery_required: bool
    recovery_actions: List[str]


class CampaignResponse(BaseModel):
    campaign_id: str
    user_id: int
    created_at: str
    last_activity: str
    current_stage: str
    risk_score: int
    exposure: Dict[str, Any]
    status: str
    event_count: int
    stage_progression: List[Dict]
    sender_numbers: List[str]
    channels: List[str]


class AlertResponse(BaseModel):
    alert_id: str
    user_id: int
    event_id: str
    campaign_id: Optional[str]
    severity: str
    alert_type: str
    title: str
    plain_language_reason: str
    recommended_action: str
    status: str
    created_at: str


class TrustedContactRequest(BaseModel):
    name: str
    contact_method: str  # sms, email, push
    contact_value: str
    relationship: str
    alert_level: str = "HIGH"


class ConsentRequest(BaseModel):
    consent_given: bool
    consent_scope: List[str] = []


class FeedbackRequest(BaseModel):
    event_id: str
    feedback_type: str
    comment: Optional[str] = None


class RecoveryActionRequest(BaseModel):
    action: str
    status: str = "COMPLETED"
    details: Dict[str, Any] = {}


# Dependency
def get_agent(db: Session = Depends(get_db)) -> ScameGoAgent:
    return create_agent(db)


def get_db_service(db: Session = Depends(get_db)) -> AgentDatabaseService:
    return AgentDatabaseService(db)


# Event Processing Endpoints
@router.post("/events", response_model=EventResponse)
async def process_event(event: AgentEventInput, agent: ScameGoAgent = Depends(get_agent)):
    """Process a security event through the agent pipeline."""
    try:
        result = agent.process_event(event)
        
        return EventResponse(
            event_id=result.decision.event_id,
            campaign_id=result.decision.campaign_id,
            classification=result.analysis.classification,
            risk_score=result.decision.risk_score,
            risk_level=result.decision.risk_level.value,
            stage=result.decision.stage.value,
            intent=[i.value for i in result.decision.intent],
            exposure=result.decision.exposure.model_dump(),
            legitimacy=result.decision.legitimacy.model_dump(),
            explanation=result.decision.explanation,
            recommended_action=result.decision.recommended_action,
            intervention_level=result.decision.intervention_level,
            actions=[a.value for a in result.decision.actions],
            notify_trusted_contact=result.decision.notify_trusted_contact,
            recovery_required=result.decision.recovery_required,
            recovery_actions=result.decision.recovery_actions
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Event processing failed: {str(e)}")


@router.post("/events/sms", response_model=EventResponse)
async def process_sms_event(event: AgentEventInputSMS, agent: ScameGoAgent = Depends(get_agent)):
    """Process an SMS event."""
    return await process_event(event, agent)


@router.post("/events/call", response_model=EventResponse)
async def process_call_event(event: AgentEventInputCall, agent: ScameGoAgent = Depends(get_agent)):
    """Process a call transcript event."""
    return await process_event(event, agent)


@router.post("/events/payment", response_model=EventResponse)
async def process_payment_event(event: AgentEventInputPayment, agent: ScameGoAgent = Depends(get_agent)):
    """Process a payment event."""
    return await process_event(event, agent)


@router.post("/events/social", response_model=EventResponse)
async def process_social_event(event: AgentEventInputSocial, agent: ScameGoAgent = Depends(get_agent)):
    """Process a social media message event."""
    return await process_event(event, agent)


# Analysis Endpoint (without full pipeline)
@router.post("/analyze")
async def analyze_text(text: str, sender: str = None, user_id: int = 1, agent: ScameGoAgent = Depends(get_agent)):
    """Quick analysis without full event pipeline."""
    from llm.schemas import AgentEventInput
    event = AgentEventInput(
        user_id=user_id,
        event_type="manual_text",
        channel="manual",
        content=text,
        sender=sender
    )
    return await process_event(event, agent)


# Event Retrieval
@router.get("/events/{event_id}")
async def get_event(event_id: str, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get event details by ID."""
    event = db_service.get_event(event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    decision = db_service.get_decision(event_id)
    
    return {
        "event": {
            "event_id": event.event_id,
            "user_id": event.user_id,
            "event_type": event.event_type,
            "channel": event.channel,
            "timestamp": event.timestamp.isoformat() if event.timestamp else None,
            "sender": event.sender,
            "content": event.content,
            "metadata": event.metadata
        },
        "decision": {
            "risk_score": decision.risk_score if decision else None,
            "risk_level": decision.risk_level if decision else None,
            "stage": decision.stage if decision else None,
            "explanation": decision.explanation if decision else None,
            "recommended_action": decision.recommended_action if decision else None
        } if decision else None
    }


# Campaign Endpoints
@router.get("/campaigns", response_model=List[CampaignResponse])
async def get_campaigns(user_id: int = 1, status: str = None, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get all campaigns for a user."""
    campaigns = db_service.get_user_campaigns(user_id, status)
    return [
        CampaignResponse(
            campaign_id=c.campaign_id,
            user_id=c.user_id,
            created_at=c.created_at.isoformat() if c.created_at else "",
            last_activity=c.last_activity.isoformat() if c.last_activity else "",
            current_stage=c.current_stage,
            risk_score=c.risk_score,
            exposure=c.exposure or {},
            status=c.status,
            event_count=c.event_count,
            stage_progression=c.stage_progression or [],
            sender_numbers=c.sender_numbers or [],
            channels=c.channels or []
        )
        for c in campaigns
    ]


@router.get("/campaigns/{campaign_id}", response_model=CampaignResponse)
async def get_campaign(campaign_id: str, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get campaign details by ID."""
    campaign = db_service.get_campaign(campaign_id)
    if not campaign:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    return CampaignResponse(
        campaign_id=campaign.campaign_id,
        user_id=campaign.user_id,
        created_at=campaign.created_at.isoformat() if campaign.created_at else "",
        last_activity=campaign.last_activity.isoformat() if campaign.last_activity else "",
        current_stage=campaign.current_stage,
        risk_score=campaign.risk_score,
        exposure=campaign.exposure or {},
        status=campaign.status,
        event_count=campaign.event_count,
        stage_progression=campaign.stage_progression or [],
        sender_numbers=campaign.sender_numbers or [],
        channels=campaign.channels or []
    )


# Risk/Exposure Endpoints
@router.get("/risk/{user_id}")
async def get_user_risk(user_id: int, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get overall risk assessment for user."""
    campaigns = db_service.get_user_campaigns(user_id)
    
    max_risk = 0
    critical_campaigns = 0
    high_campaigns = 0
    
    for c in campaigns:
        if c.risk_score > max_risk:
            max_risk = c.risk_score
        if c.status == "CRITICAL":
            critical_campaigns += 1
        elif c.status == "HIGH_RISK":
            high_campaigns += 1
    
    overall_level = "SAFE"
    if max_risk >= 91:
        overall_level = "CRITICAL"
    elif max_risk >= 61:
        overall_level = "HIGH"
    elif max_risk >= 31:
        overall_level = "MEDIUM"
    elif max_risk >= 1:
        overall_level = "LOW"
    
    return {
        "user_id": user_id,
        "overall_risk_score": max_risk,
        "overall_risk_level": overall_level,
        "active_campaigns": len(campaigns),
        "critical_campaigns": critical_campaigns,
        "high_risk_campaigns": high_campaigns
    }


@router.get("/exposure/{user_id}")
async def get_user_exposure(user_id: int, campaign_id: str = None, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get total exposure for user."""
    exposure = db_service.get_total_exposure(user_id, campaign_id)
    return exposure.model_dump()


# Alert Endpoints
@router.get("/alerts/{user_id}", response_model=List[AlertResponse])
async def get_alerts(user_id: int, limit: int = 50, unread_only: bool = False, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get alerts for a user."""
    alerts = db_service.get_user_alerts(user_id, limit, unread_only)
    return [
        AlertResponse(
            alert_id=a.alert_id,
            user_id=a.user_id,
            event_id=a.event_id,
            campaign_id=a.campaign_id,
            severity=a.severity,
            alert_type=a.alert_type,
            title=a.title,
            plain_language_reason=a.plain_language_reason,
            recommended_action=a.recommended_action,
            status=a.status,
            created_at=a.created_at.isoformat() if a.created_at else ""
        )
        for a in alerts
    ]


@router.post("/alerts/{alert_id}/read")
async def mark_alert_read(alert_id: str, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Mark alert as read."""
    alert = db_service.mark_alert_read(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return {"status": "ok", "alert_id": alert_id}


# Trusted Contact Endpoints
@router.post("/trusted-contacts", response_model=Dict)
async def add_trusted_contact(contact: TrustedContactRequest, user_id: int = 1, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Add a trusted contact."""
    tc = TrustedContact(
        user_id=user_id,
        name=contact.name,
        contact_method=contact.contact_method,
        contact_value=contact.contact_value,
        relationship=contact.relationship,
        consent_status=False,  # Consent must be given separately
        alert_level=RiskLevel(contact.alert_level)
    )
    manager = TrustedContactManager(db_service)
    saved = manager.add_contact(tc)
    return {"id": saved.id, "status": "created"}


@router.get("/trusted-contacts", response_model=List[Dict])
async def get_trusted_contacts(user_id: int = 1, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get all trusted contacts for user."""
    manager = TrustedContactManager(db_service)
    contacts = manager.get_contacts(user_id)
    return [
        {
            "id": c.id,
            "name": c.name,
            "contact_method": c.contact_method,
            "contact_value": c.contact_value,
            "relationship": c.relationship,
            "consent_status": c.consent_status,
            "alert_level": c.alert_level.value
        }
        for c in contacts
    ]


@router.post("/trusted-contacts/{contact_id}/consent")
async def update_consent(contact_id: int, consent: ConsentRequest, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Update consent for trusted contact."""
    manager = TrustedContactManager(db_service)
    result = manager.update_consent(contact_id, consent.consent_given, consent.consent_scope)
    if not result:
        raise HTTPException(status_code=404, detail="Contact not found")
    return {"status": "updated", "consent_given": consent.consent_given}


# Feedback Endpoint
@router.post("/feedback")
async def submit_feedback(feedback: FeedbackRequest, user_id: int = 1, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Submit user feedback on event analysis."""
    try:
        fb_type = FeedbackType(feedback.feedback_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid feedback type")
    
    fb = UserFeedback(
        user_id=user_id,
        event_id=feedback.event_id,
        feedback_type=fb_type,
        comment=feedback.comment
    )
    db_service.save_feedback(fb)
    return {"status": "recorded"}


# Recovery Endpoints
@router.get("/recovery/{user_id}")
async def get_recovery_plan(user_id: int, campaign_id: str = None, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Get recovery actions for user/campaign."""
    engine = RecoveryEngine(db_service)
    status = engine.get_recovery_status(user_id, campaign_id)
    contacts = engine.get_official_contacts()
    return {
        "recovery_actions": status,
        "official_contacts": contacts
    }


@router.post("/recovery/{user_id}/action")
async def update_recovery_action(user_id: int, campaign_id: str, action_req: RecoveryActionRequest, db_service: AgentDatabaseService = Depends(get_db_service)):
    """Update recovery action status."""
    try:
        action = RecoveryAction(action_req.action)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid recovery action")
    
    engine = RecoveryEngine(db_service)
    engine.update_recovery_status(user_id, campaign_id, action, action_req.status, action_req.details)
    return {"status": "updated"}


# Health Check
@router.get("/health")
async def health_check():
    """Agent health check."""
    return {
        "status": "healthy",
        "agent_enabled": config.agent_enabled,
        "groq_enabled": config.groq_enabled,
        "groq_model": config.groq_model if config.groq_enabled else None
    }
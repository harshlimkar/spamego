from sqlalchemy.orm import Session
from sqlalchemy import desc, and_, or_
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import json
import sys
import os

# Add backend to path for imports
backend_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'backend')
sys.path.insert(0, backend_path)

from app.database.base import SessionLocal

from llm.models import (
    AgentEvent, AgentDecisionRecord, Campaign, ExposureRecord,
    TrustedContactModel, ConsentRecordModel, UserFeedbackModel,
    AgentAuditLogModel, AgentAlertModel, RecoveryActionLog
)
from llm.schemas import (
    AgentEventInput, AgentDecision, Campaign as CampaignSchema,
    ExposureAssessment, LegitimacyAssessment, AgentAlert,
    TrustedContact, ConsentRecord, UserFeedback, AgentAuditLog,
    RecoveryAction
)


class AgentDatabaseService:
    def __init__(self, db: Session):
        self.db = db

    def save_event(self, event: AgentEventInput) -> AgentEvent:
        db_event = AgentEvent(
            event_id=event.event_id,
            user_id=event.user_id,
            event_type=event.event_type.value,
            channel=event.channel.value,
            timestamp=event.timestamp,
            sender=event.sender,
            recipient=event.recipient,
            content=event.content,
            language=event.language,
            event_metadata=event.metadata,
            source=event.source
        )
        self.db.add(db_event)
        self.db.commit()
        self.db.refresh(db_event)
        return db_event

    def get_event(self, event_id: str) -> Optional[AgentEvent]:
        return self.db.query(AgentEvent).filter(AgentEvent.event_id == event_id).first()

    def get_recent_events(self, user_id: int, hours: int = 24, limit: int = 100) -> List[AgentEvent]:
        cutoff = datetime.utcnow() - timedelta(hours=hours)
        return self.db.query(AgentEvent).filter(
            AgentEvent.user_id == user_id,
            AgentEvent.timestamp >= cutoff
        ).order_by(desc(AgentEvent.timestamp)).limit(limit).all()

    def get_events_by_sender(self, user_id: int, sender: str, hours: int = 24) -> List[AgentEvent]:
        cutoff = datetime.utcnow() - timedelta(hours=hours)
        return self.db.query(AgentEvent).filter(
            AgentEvent.user_id == user_id,
            AgentEvent.sender == sender,
            AgentEvent.timestamp >= cutoff
        ).order_by(desc(AgentEvent.timestamp)).all()

    def save_decision(self, decision: AgentDecision) -> AgentDecisionRecord:
        db_decision = AgentDecisionRecord(
            event_id=decision.event_id,
            user_id=decision.campaign_id,  # This is wrong, let me fix
            campaign_id=decision.campaign_id,
            risk_score=decision.risk_score,
            risk_level=decision.risk_level.value,
            stage=decision.stage.value,
            intent=[i.value for i in decision.intent],
            exposure=decision.exposure.model_dump(),
            legitimacy=decision.legitimacy.model_dump(),
            explanation=decision.explanation,
            recommended_action=decision.recommended_action,
            intervention_level=decision.intervention_level,
            actions=[a.value for a in decision.actions],
            notify_trusted_contact=decision.notify_trusted_contact,
            recovery_required=decision.recovery_required,
            recovery_actions=decision.recovery_actions,
            timestamp=decision.timestamp,
            audit_trail=decision.audit_trail
        )
        # Fix user_id - we need to get it from event
        event = self.get_event(decision.event_id)
        if event:
            db_decision.user_id = event.user_id
        
        self.db.add(db_decision)
        self.db.commit()
        self.db.refresh(db_decision)
        return db_decision

    def get_decision(self, event_id: str) -> Optional[AgentDecisionRecord]:
        return self.db.query(AgentDecisionRecord).filter(AgentDecisionRecord.event_id == event_id).first()

    def get_or_create_campaign(self, campaign_id: str, user_id: int) -> Campaign:
        campaign = self.db.query(Campaign).filter(Campaign.campaign_id == campaign_id).first()
        if not campaign:
            campaign = Campaign(
                campaign_id=campaign_id,
                user_id=user_id,
                created_at=datetime.utcnow(),
                last_activity=datetime.utcnow(),
                current_stage="UNKNOWN",
                risk_score=0,
                exposure={},
                status="ACTIVE",
                event_count=0,
                stage_progression=[],
                sender_numbers=[],
                channels=[]
            )
            self.db.add(campaign)
            self.db.commit()
            self.db.refresh(campaign)
        return campaign

    def update_campaign(self, campaign_id: str, updates: Dict[str, Any]) -> Optional[Campaign]:
        campaign = self.db.query(Campaign).filter(Campaign.campaign_id == campaign_id).first()
        if campaign:
            for key, value in updates.items():
                if hasattr(campaign, key):
                    setattr(campaign, key, value)
            campaign.updated_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(campaign)
        return campaign

    def get_campaign(self, campaign_id: str) -> Optional[Campaign]:
        return self.db.query(Campaign).filter(Campaign.campaign_id == campaign_id).first()

    def get_user_campaigns(self, user_id: int, status: Optional[str] = None) -> List[Campaign]:
        query = self.db.query(Campaign).filter(Campaign.user_id == user_id)
        if status:
            query = query.filter(Campaign.status == status)
        return query.order_by(desc(Campaign.last_activity)).all()

    def _serialize_event_data(self, event_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convert datetime objects to ISO format strings for JSON serialization."""
        serialized = {}
        for key, value in event_data.items():
            if isinstance(value, datetime):
                serialized[key] = value.isoformat()
            elif isinstance(value, (list, dict)):
                serialized[key] = self._serialize_complex(value)
            else:
                serialized[key] = value
        return serialized

    def _serialize_complex(self, value):
        """Recursively serialize complex objects."""
        if isinstance(value, datetime):
            return value.isoformat()
        elif isinstance(value, dict):
            return {k: self._serialize_complex(v) for k, v in value.items()}
        elif isinstance(value, list):
            return [self._serialize_complex(v) for v in value]
        else:
            return value

    def add_campaign_event(self, campaign_id: str, event_data: Dict[str, Any]) -> Optional[Campaign]:
        campaign = self.get_campaign(campaign_id)
        if not campaign:
            return None
        
        campaign.event_count += 1
        campaign.last_activity = datetime.utcnow()
        
        # Update stage progression
        progression = campaign.stage_progression or []
        progression.append(self._serialize_event_data(event_data))
        campaign.stage_progression = progression
        
        # Update sender numbers
        senders = campaign.sender_numbers or []
        if event_data.get("sender") and event_data["sender"] not in senders:
            senders.append(event_data["sender"])
        campaign.sender_numbers = senders
        
        # Update channels
        channels = campaign.channels or []
        if event_data.get("channel") and event_data["channel"] not in channels:
            channels.append(event_data["channel"])
        campaign.channels = channels
        
        self.db.commit()
        self.db.refresh(campaign)
        return campaign

    def save_exposure(self, exposure: ExposureAssessment, event_id: str, campaign_id: Optional[str], user_id: int) -> ExposureRecord:
        db_exposure = ExposureRecord(
            event_id=event_id,
            campaign_id=campaign_id,
            user_id=user_id,
            money_amount=exposure.money_exposure,
            credential_exposure=exposure.credential_exposure,
            otp_exposure=exposure.otp_exposure,
            device_access_exposure=exposure.device_access_exposure,
            account_access_exposure=exposure.account_access_exposure,
            personal_info_exposure=exposure.personal_info_exposure,
            payment_auth_exposure=exposure.payment_auth_exposure,
            exposure_types=[e.value for e in exposure.exposure_types]
        )
        self.db.add(db_exposure)
        self.db.commit()
        self.db.refresh(db_exposure)
        return db_exposure

    def get_total_exposure(self, user_id: int, campaign_id: Optional[str] = None) -> ExposureAssessment:
        query = self.db.query(ExposureRecord).filter(ExposureRecord.user_id == user_id)
        if campaign_id:
            query = query.filter(ExposureRecord.campaign_id == campaign_id)
        
        records = query.all()
        
        total_money = sum(r.money_amount for r in records)
        credential_exp = any(r.credential_exposure for r in records)
        otp_exp = any(r.otp_exposure for r in records)
        device_exp = any(r.device_access_exposure for r in records)
        account_exp = any(r.account_access_exposure for r in records)
        personal_exp = any(r.personal_info_exposure for r in records)
        payment_exp = any(r.payment_auth_exposure for r in records)
        
        all_types = set()
        for r in records:
            if r.exposure_types:
                all_types.update(r.exposure_types)
        
        return ExposureAssessment(
            money_exposure=total_money,
            credential_exposure=credential_exp,
            otp_exposure=otp_exp,
            device_access_exposure=device_exp,
            account_access_exposure=account_exp,
            personal_info_exposure=personal_exp,
            payment_auth_exposure=payment_exp,
            exposure_types=[ExposureType(t) for t in all_types]
        )

    def save_trusted_contact(self, contact: TrustedContact) -> TrustedContactModel:
        db_contact = TrustedContactModel(
            user_id=contact.user_id,
            name=contact.name,
            contact_method=contact.contact_method,
            contact_value=contact.contact_value,
            relationship=contact.relationship,
            consent_status=contact.consent_status,
            alert_level=contact.alert_level.value
        )
        self.db.add(db_contact)
        self.db.commit()
        self.db.refresh(db_contact)
        contact.id = db_contact.id
        return db_contact

    def get_trusted_contacts(self, user_id: int) -> List[TrustedContactModel]:
        return self.db.query(TrustedContactModel).filter(TrustedContactModel.user_id == user_id).all()

    def get_trusted_contact(self, contact_id: int) -> Optional[TrustedContactModel]:
        return self.db.query(TrustedContactModel).filter(TrustedContactModel.id == contact_id).first()

    def update_consent(self, contact_id: int, consent_given: bool, scope: List[str] = None) -> Optional[ConsentRecordModel]:
        contact = self.get_trusted_contact(contact_id)
        if not contact:
            return None
        
        contact.consent_status = consent_given
        
        consent_record = ConsentRecordModel(
            user_id=contact.user_id,
            trusted_contact_id=contact_id,
            consent_given=consent_given,
            consent_scope=scope or []
        )
        self.db.add(consent_record)
        self.db.commit()
        self.db.refresh(consent_record)
        return consent_record

    def save_feedback(self, feedback: UserFeedback) -> UserFeedbackModel:
        db_feedback = UserFeedbackModel(
            user_id=feedback.user_id,
            event_id=feedback.event_id,
            feedback_type=feedback.feedback_type.value,
            comment=feedback.comment
        )
        self.db.add(db_feedback)
        self.db.commit()
        self.db.refresh(db_feedback)
        return db_feedback

    def log_audit(self, audit: AgentAuditLog) -> AgentAuditLogModel:
        db_audit = AgentAuditLogModel(
            event_id=audit.event_id,
            user_id=audit.user_id,
            step=audit.step,
            details=audit.details
        )
        self.db.add(db_audit)
        self.db.commit()
        self.db.refresh(db_audit)
        return db_audit

    def get_audit_trail(self, event_id: str) -> List[AgentAuditLogModel]:
        return self.db.query(AgentAuditLogModel).filter(
            AgentAuditLogModel.event_id == event_id
        ).order_by(AgentAuditLogModel.timestamp).all()

    def save_alert(self, alert: AgentAlert) -> AgentAlertModel:
        db_alert = AgentAlertModel(
            alert_id=alert.alert_id,
            user_id=alert.user_id,
            event_id=alert.event_id,
            campaign_id=alert.campaign_id,
            severity=alert.severity.value,
            alert_type=alert.alert_type.value,
            title=alert.title,
            plain_language_reason=alert.plain_language_reason,
            recommended_action=alert.recommended_action,
            status=alert.status,
            created_at=alert.created_at
        )
        self.db.add(db_alert)
        self.db.commit()
        self.db.refresh(db_alert)
        return db_alert

    def get_user_alerts(self, user_id: int, limit: int = 50, unread_only: bool = False) -> List[AgentAlertModel]:
        query = self.db.query(AgentAlertModel).filter(AgentAlertModel.user_id == user_id)
        if unread_only:
            query = query.filter(AgentAlertModel.status == "unread")
        return query.order_by(desc(AgentAlertModel.created_at)).limit(limit).all()

    def mark_alert_read(self, alert_id: str) -> Optional[AgentAlertModel]:
        alert = self.db.query(AgentAlertModel).filter(AgentAlertModel.alert_id == alert_id).first()
        if alert:
            alert.status = "read"
            alert.read_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(alert)
        return alert

    def log_recovery_action(self, user_id: int, campaign_id: Optional[str], event_id: Optional[str], 
                           action: RecoveryAction, status: str = "RECOMMENDED", details: Dict = None) -> RecoveryActionLog:
        log = RecoveryActionLog(
            user_id=user_id,
            campaign_id=campaign_id,
            event_id=event_id,
            action=action.value,
            status=status,
            details=details or {}
        )
        self.db.add(log)
        self.db.commit()
        self.db.refresh(log)
        return log

    def get_recovery_actions(self, user_id: int, campaign_id: Optional[str] = None) -> List[RecoveryActionLog]:
        query = self.db.query(RecoveryActionLog).filter(RecoveryActionLog.user_id == user_id)
        if campaign_id:
            query = query.filter(RecoveryActionLog.campaign_id == campaign_id)
        return query.order_by(desc(RecoveryActionLog.created_at)).all()
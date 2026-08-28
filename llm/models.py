from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, Float, Boolean, ForeignKey, JSON, Index
import sys
import os

# Add backend to path for imports
backend_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'backend')
sys.path.insert(0, backend_path)

from app.database.base import Base


class AgentEvent(Base):
    __tablename__ = "agent_events"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String, unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    event_type = Column(String, nullable=False, index=True)
    channel = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    sender = Column(String, nullable=True, index=True)
    recipient = Column(String, nullable=True)
    content = Column(Text, nullable=False)
    language = Column(String, nullable=True)
    event_metadata = Column(JSON, nullable=True)
    source = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class AgentDecisionRecord(Base):
    __tablename__ = "agent_decisions"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    campaign_id = Column(String, nullable=True, index=True)
    risk_score = Column(Integer, nullable=False)
    risk_level = Column(String, nullable=False)
    stage = Column(String, nullable=False)
    intent = Column(JSON, nullable=True)
    exposure = Column(JSON, nullable=True)
    legitimacy = Column(JSON, nullable=True)
    explanation = Column(Text, nullable=True)
    recommended_action = Column(String, nullable=True)
    intervention_level = Column(String, nullable=True)
    actions = Column(JSON, nullable=True)
    notify_trusted_contact = Column(Boolean, default=False)
    recovery_required = Column(Boolean, default=False)
    recovery_actions = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    audit_trail = Column(JSON, nullable=True)


class Campaign(Base):
    __tablename__ = "agent_campaigns"

    id = Column(Integer, primary_key=True, index=True)
    campaign_id = Column(String, unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow, index=True)
    current_stage = Column(String, nullable=False, default="UNKNOWN")
    risk_score = Column(Integer, default=0)
    exposure = Column(JSON, nullable=True)
    status = Column(String, nullable=False, default="ACTIVE")
    event_count = Column(Integer, default=0)
    stage_progression = Column(JSON, nullable=True)
    sender_numbers = Column(JSON, nullable=True)
    channels = Column(JSON, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class ExposureRecord(Base):
    __tablename__ = "exposure_records"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=False, index=True)
    campaign_id = Column(String, nullable=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    money_amount = Column(Float, default=0.0)
    currency = Column(String, default="INR")
    credential_exposure = Column(Boolean, default=False)
    otp_exposure = Column(Boolean, default=False)
    device_access_exposure = Column(Boolean, default=False)
    account_access_exposure = Column(Boolean, default=False)
    personal_info_exposure = Column(Boolean, default=False)
    payment_auth_exposure = Column(Boolean, default=False)
    exposure_types = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)


class TrustedContactModel(Base):
    __tablename__ = "trusted_contacts_extended"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String, nullable=False)
    contact_method = Column(String, nullable=False)
    contact_value = Column(String, nullable=False)
    relationship = Column(String, nullable=False)
    consent_status = Column(Boolean, default=False)
    alert_level = Column(String, nullable=False, default="HIGH")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class ConsentRecordModel(Base):
    __tablename__ = "consent_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    trusted_contact_id = Column(Integer, ForeignKey("trusted_contacts_extended.id"), nullable=False)
    consent_given = Column(Boolean, default=False)
    consent_timestamp = Column(DateTime, default=datetime.utcnow)
    consent_scope = Column(JSON, nullable=True)


class UserFeedbackModel(Base):
    __tablename__ = "user_feedback"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=False, index=True)
    feedback_type = Column(String, nullable=False)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class AgentAuditLogModel(Base):
    __tablename__ = "agent_audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    step = Column(String, nullable=False)
    details = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

Index("ix_agent_audit_event_step", AgentAuditLogModel.event_id, AgentAuditLogModel.step)


class AgentAlertModel(Base):
    __tablename__ = "agent_alerts"

    id = Column(Integer, primary_key=True, index=True)
    alert_id = Column(String, unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=False, index=True)
    campaign_id = Column(String, nullable=True, index=True)
    severity = Column(String, nullable=False)
    alert_type = Column(String, nullable=False)
    title = Column(String, nullable=False)
    plain_language_reason = Column(Text, nullable=False)
    recommended_action = Column(String, nullable=False)
    status = Column(String, default="unread")
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    read_at = Column(DateTime, nullable=True)


class RecoveryActionLog(Base):
    __tablename__ = "recovery_action_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    campaign_id = Column(String, nullable=True, index=True)
    event_id = Column(String, ForeignKey("agent_events.event_id"), nullable=True, index=True)
    action = Column(String, nullable=False)
    status = Column(String, default="RECOMMENDED")
    details = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
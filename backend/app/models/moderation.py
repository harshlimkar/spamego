"""
ScamEgo Moderation Models (Results, Violations, Alerts, Emergency Logs)
"""

from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, JSON
from app.database.base import Base

class ModerationResult(Base):
    __tablename__ = "moderation_results"

    id = Column(Integer, primary_key=True, index=True)
    content_type = Column(String, nullable=False)  # "comment" or "message"
    content_id = Column(Integer, nullable=False)
    scam_label = Column(String, nullable=False)    # "SAFE", "SPAM", "SCAM"
    risk_score = Column(Integer, default=0)        # 0 to 100
    risk_level = Column(String, nullable=False)    # "SAFE", "SUSPICIOUS", "HIGH_RISK", "CRITICAL_SCAM"
    indicators = Column(JSON, nullable=True)       # List of detected indicators
    reasons = Column(JSON, nullable=True)          # List of explainable reasons
    confidence = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

class Violation(Base):
    __tablename__ = "violations"

    id = Column(Integer, primary_key=True, index=True)
    user_identifier = Column(String, nullable=False) # Scammer account / handle
    violation_type = Column(String, nullable=False)  # e.g., OTP_REQUEST, BANK_IMPERSONATION
    severity = Column(String, nullable=False)        # e.g., HIGH_RISK, CRITICAL_SCAM
    created_at = Column(DateTime, default=datetime.utcnow)

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    alert_type = Column(String, nullable=False)       # Scam indicator category
    severity = Column(String, nullable=False)         # "SUSPICIOUS", "HIGH_RISK", "CRITICAL_SCAM"
    content_preview = Column(Text, nullable=False)
    status = Column(String, default="unread")         # "unread" or "read"
    created_at = Column(DateTime, default=datetime.utcnow)

class EmergencyLog(Base):
    __tablename__ = "emergency_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    incident_type = Column(String, nullable=False)
    severity_level = Column(String, nullable=False)
    severity_score = Column(Float, nullable=False)
    report_pdf_path = Column(String, nullable=True)
    email_status = Column(String, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)

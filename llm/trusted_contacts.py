import logging
from typing import List, Optional, Dict, Any
from dataclasses import dataclass

from llm.schemas import TrustedContact, ConsentRecord, RiskLevel, AgentAlert
from llm.database import AgentDatabaseService
from llm.config import config

logger = logging.getLogger(__name__)


@dataclass
class NotificationResult:
    contact_id: int
    contact_name: str
    method: str
    success: bool
    error: Optional[str] = None


class TrustedContactManager:
    def __init__(self, db_service: AgentDatabaseService):
        self.db = db_service
        
        # Notification adapters (in real implementation, these would be actual integrations)
        self.sms_adapter = None  # Would integrate with SMS gateway
        self.email_adapter = None  # Would integrate with email service
        self.push_adapter = None  # Would integrate with push notification service

    def add_contact(self, contact: TrustedContact) -> TrustedContact:
        """Add a new trusted contact."""
        return self.db.save_trusted_contact(contact)

    def get_contacts(self, user_id: int) -> List[TrustedContact]:
        """Get all trusted contacts for a user."""
        db_contacts = self.db.get_trusted_contacts(user_id)
        return [self._to_schema(c) for c in db_contacts]

    def get_primary_contact(self, user_id: int) -> Optional[TrustedContact]:
        """Get the highest priority trusted contact with consent."""
        contacts = self.get_contacts(user_id)
        consented = [c for c in contacts if c.consent_status]
        if not consented:
            return None
        # Sort by alert_level priority (CRITICAL > HIGH > MEDIUM > LOW)
        priority_order = {RiskLevel.CRITICAL: 0, RiskLevel.HIGH: 1, RiskLevel.MEDIUM: 2, RiskLevel.LOW: 3}
        return sorted(consented, key=lambda c: priority_order.get(c.alert_level, 99))[0]

    def update_consent(self, contact_id: int, consent_given: bool, scope: List[str] = None) -> Optional[ConsentRecord]:
        """Update consent status for a trusted contact."""
        return self.db.update_consent(contact_id, consent_given, scope)

    def should_notify(self, user_id: int, alert_severity: RiskLevel) -> bool:
        """Determine if trusted contact should be notified based on severity and consent."""
        if not config.trusted_contact_alert_enabled:
            return False
        
        primary = self.get_primary_contact(user_id)
        if not primary:
            return False
        
        # Check if alert severity meets contact's alert level threshold
        priority_order = {RiskLevel.CRITICAL: 4, RiskLevel.HIGH: 3, RiskLevel.MEDIUM: 2, RiskLevel.LOW: 1}
        alert_priority = priority_order.get(alert_severity, 0)
        contact_priority = priority_order.get(primary.alert_level, 0)
        
        return alert_priority >= contact_priority

    def notify_trusted_contact(self, user_id: int, alert: AgentAlert, user_name: str = "User") -> List[NotificationResult]:
        """Send notification to trusted contact(s)."""
        primary = self.get_primary_contact(user_id)
        if not primary:
            logger.warning(f"No trusted contact with consent for user {user_id}")
            return []
        
        if not self.should_notify(user_id, alert.severity):
            logger.info(f"Alert severity {alert.severity} below contact threshold {primary.alert_level}")
            return []
        
        results = []
        
        # Build message
        message = self._build_alert_message(alert, user_name, primary.name)
        
        # Send via contact method
        if primary.contact_method == "sms":
            result = self._send_sms(primary, message)
            results.append(result)
        elif primary.contact_method == "email":
            result = self._send_email(primary, message, alert.title)
            results.append(result)
        elif primary.contact_method == "push":
            result = self._send_push(primary, message, alert.title)
            results.append(result)
        else:
            logger.warning(f"Unknown contact method: {primary.contact_method}")
        
        return results

    def _build_alert_message(self, alert: AgentAlert, user_name: str, contact_name: str) -> str:
        """Build notification message for trusted contact."""
        severity_labels = {
            RiskLevel.CRITICAL: "CRITICAL",
            RiskLevel.HIGH: "HIGH",
            RiskLevel.MEDIUM: "MEDIUM",
            RiskLevel.LOW: "LOW"
        }
        
        severity_label = severity_labels.get(alert.severity, "ALERT")
        
        if alert.alert_type.value == "TRUSTED_CONTACT_ALERT":
            return (
                f"ScameGo Alert: {severity_label} scam risk detected for {user_name}. "
                f"{alert.plain_language_reason} "
                f"Recommended action: {alert.recommended_action}. "
                f"Please contact {user_name} immediately."
            )
        else:
            return (
                f"ScameGo Alert: {severity_label} risk detected for {user_name}. "
                f"{alert.plain_language_reason} "
                f"Action: {alert.recommended_action}"
            )

    def _send_sms(self, contact: TrustedContact, message: str) -> NotificationResult:
        """Send SMS notification (mock implementation)."""
        logger.info(f"[MOCK SMS] To: {contact.contact_value} - {message[:100]}...")
        # In real implementation: integrate with Twilio, Vonage, or local SMS gateway
        return NotificationResult(
            contact_id=contact.id or 0,
            contact_name=contact.name,
            method="sms",
            success=True
        )

    def _send_email(self, contact: TrustedContact, message: str, subject: str) -> NotificationResult:
        """Send email notification (mock implementation)."""
        logger.info(f"[MOCK EMAIL] To: {contact.contact_value} - Subject: {subject}")
        # In real implementation: integrate with SendGrid, AWS SES, etc.
        return NotificationResult(
            contact_id=contact.id or 0,
            contact_name=contact.name,
            method="email",
            success=True
        )

    def _send_push(self, contact: TrustedContact, message: str, title: str) -> NotificationResult:
        """Send push notification (mock implementation)."""
        logger.info(f"[MOCK PUSH] To: {contact.contact_value} - Title: {title}")
        # In real implementation: integrate with FCM, APNs, etc.
        return NotificationResult(
            contact_id=contact.id or 0,
            contact_name=contact.name,
            method="push",
            success=True
        )

    def _to_schema(self, db_contact) -> TrustedContact:
        return TrustedContact(
            id=db_contact.id,
            user_id=db_contact.user_id,
            name=db_contact.name,
            contact_method=db_contact.contact_method,
            contact_value=db_contact.contact_value,
            relationship=db_contact.relationship,
            consent_status=db_contact.consent_status,
            alert_level=RiskLevel(db_contact.alert_level),
            created_at=db_contact.created_at
        )
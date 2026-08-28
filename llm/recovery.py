import logging
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

from llm.schemas import RecoveryAction, ExposureAssessment, ScamStage, AttackerIntent, RiskLevel
from llm.database import AgentDatabaseService

logger = logging.getLogger(__name__)


@dataclass
class RecoveryPlan:
    actions: List[RecoveryAction]
    priority: str  # IMMEDIATE, HIGH, MEDIUM
    explanation: str
    auto_executable: List[RecoveryAction]  # Actions that can be auto-executed
    manual_actions: List[RecoveryAction]  # Actions requiring user intervention


class RecoveryEngine:
    def __init__(self, db_service: AgentDatabaseService):
        self.db = db_service
        
        # Official contact numbers (India-specific)
        self.official_contacts = {
            "cyber_crime": "1930",
            "banking_ombudsman": "1800-425-3800",
            "rbi": "1800-11-4000",
            "consumer_helpline": "1800-11-4000",
        }
        
        # Bank-specific contacts (sample)
        self.bank_contacts = {
            "hdfc": "1800-202-6161",
            "icici": "1800-200-3344",
            "sbi": "1800-11-2211",
            "axis": "1800-419-5959",
            "kotak": "1860-266-2666",
        }

    def generate_recovery_plan(self, 
                               exposure: ExposureAssessment, 
                               stage: ScamStage,
                               intents: List[AttackerIntent],
                               risk_level: RiskLevel,
                               sender: str = None,
                               metadata: Dict = None) -> RecoveryPlan:
        """Generate a recovery plan based on the threat assessment."""
        actions = []
        auto_executable = []
        manual_actions = []
        
        metadata = metadata or {}
        
        # Financial exposure recovery
        if exposure.money_exposure > 0:
            actions.extend([
                RecoveryAction.CONTACT_BANK,
                RecoveryAction.FREEZE_ACCOUNT,
                RecoveryAction.CALL_1930,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
            manual_actions.extend([
                RecoveryAction.CONTACT_BANK,
                RecoveryAction.FREEZE_ACCOUNT,
                RecoveryAction.CALL_1930,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
        
        # Credential/OTP exposure
        if exposure.credential_exposure or exposure.otp_exposure:
            actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.CONTACT_BANK
            ])
            manual_actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.CONTACT_BANK
            ])
        
        # Device access exposure
        if exposure.device_access_exposure:
            actions.append(RecoveryAction.REVOKE_REMOTE_ACCESS)
            manual_actions.append(RecoveryAction.REVOKE_REMOTE_ACCESS)
        
        # Personal info exposure
        if exposure.personal_info_exposure:
            actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
            manual_actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
        
        # Payment authorization exposure
        if exposure.payment_auth_exposure:
            actions.extend([
                RecoveryAction.CONTACT_BANK,
                RecoveryAction.FREEZE_ACCOUNT,
                RecoveryAction.CALL_1930
            ])
            manual_actions.extend([
                RecoveryAction.CONTACT_BANK,
                RecoveryAction.FREEZE_ACCOUNT,
                RecoveryAction.CALL_1930
            ])
        
        # Always preserve evidence
        actions.append(RecoveryAction.PRESERVE_EVIDENCE)
        auto_executable.append(RecoveryAction.PRESERVE_EVIDENCE)
        
        # Deduplicate while preserving order
        seen = set()
        unique_actions = []
        for a in actions:
            if a not in seen:
                seen.add(a)
                unique_actions.append(a)
        
        seen = set()
        unique_manual = []
        for a in manual_actions:
            if a not in seen:
                seen.add(a)
                unique_manual.append(a)
        
        seen = set()
        unique_auto = []
        for a in auto_executable:
            if a not in seen:
                seen.add(a)
                unique_auto.append(a)
        
        # Determine priority
        if risk_level == RiskLevel.CRITICAL or exposure.money_exposure > 10000:
            priority = "IMMEDIATE"
        elif risk_level == RiskLevel.HIGH or exposure.money_exposure > 0:
            priority = "HIGH"
        else:
            priority = "MEDIUM"
        
        # Generate explanation
        explanation = self._generate_explanation(exposure, stage, intents, unique_actions)
        
        return RecoveryPlan(
            actions=unique_actions,
            priority=priority,
            explanation=explanation,
            auto_executable=unique_auto,
            manual_actions=unique_manual
        )

    def _generate_explanation(self, exposure: ExposureAssessment, stage: ScamStage, 
                              intents: List[AttackerIntent], actions: List[RecoveryAction]) -> str:
        """Generate human-readable explanation for recovery plan."""
        parts = []
        
        if exposure.money_exposure > 0:
            parts.append(f"Financial exposure of ₹{exposure.money_exposure:,.0f} detected.")
        
        if exposure.otp_exposure:
            parts.append("OTP may have been compromised.")
        
        if exposure.credential_exposure:
            parts.append("Login credentials may have been exposed.")
        
        if exposure.device_access_exposure:
            parts.append("Remote access to device may have been granted.")
        
        if not parts:
            parts.append("Potential security risk detected.")
        
        parts.append("Recommended immediate actions:")
        for action in actions[:5]:  # Limit to top 5
            parts.append(f"• {self._action_description(action)}")
        
        return " ".join(parts)

    def _action_description(self, action: RecoveryAction) -> str:
        descriptions = {
            RecoveryAction.CONTACT_BANK: f"Contact your bank immediately. Use official number from your card/bank website.",
            RecoveryAction.FREEZE_ACCOUNT: "Request your bank to freeze/freeze affected accounts and cards.",
            RecoveryAction.CALL_1930: f"Call Cyber Crime Helpline {self.official_contacts['cyber_crime']} to report the fraud.",
            RecoveryAction.REPORT_CYBER_FRAUD: "Report the incident on cybercrime.gov.in or at your local police station.",
            RecoveryAction.CHANGE_CREDENTIALS: "Change all passwords, PINs, and enable 2FA on important accounts.",
            RecoveryAction.REVOKE_REMOTE_ACCESS: "Uninstall any remote access apps (TeamViewer, AnyDesk, etc.) and revoke permissions.",
            RecoveryAction.CONTACT_TRUSTED_FAMILY: "Inform a trusted family member about the incident.",
            RecoveryAction.PRESERVE_EVIDENCE: "Save screenshots, call logs, message records, and transaction details as evidence.",
        }
        return descriptions.get(action, action.value)

    def get_official_contacts(self) -> Dict[str, str]:
        """Get official contact numbers for recovery."""
        return self.official_contacts.copy()

    def get_bank_contact(self, bank_name: str) -> Optional[str]:
        """Get bank-specific contact number."""
        bank_key = bank_name.lower().replace(" ", "")
        for key, number in self.bank_contacts.items():
            if key in bank_key:
                return number
        return None

    def log_recovery_action(self, user_id: int, campaign_id: str, event_id: str,
                           action: RecoveryAction, status: str = "RECOMMENDED",
                           details: Dict = None) -> None:
        """Log recovery action to database."""
        self.db.log_recovery_action(user_id, campaign_id, event_id, action, status, details)

    def update_recovery_status(self, user_id: int, campaign_id: str, 
                               action: RecoveryAction, status: str,
                               details: Dict = None) -> None:
        """Update recovery action status."""
        # In real implementation, would query and update specific log entry
        self.db.log_recovery_action(user_id, campaign_id, None, action, status, details)

    def get_recovery_status(self, user_id: int, campaign_id: str = None) -> List[Dict]:
        """Get recovery action status for user/campaign."""
        logs = self.db.get_recovery_actions(user_id, campaign_id)
        return [
            {
                "action": log.action,
                "status": log.status,
                "details": log.details,
                "created_at": log.created_at.isoformat() if log.created_at else None,
                "completed_at": log.completed_at.isoformat() if log.completed_at else None
            }
            for log in logs
        ]


# Convenience functions for common recovery scenarios
def get_otp_compromise_recovery() -> List[RecoveryAction]:
    """Recovery actions for OTP compromise."""
    return [
        RecoveryAction.CHANGE_CREDENTIALS,
        RecoveryAction.CONTACT_BANK,
        RecoveryAction.CALL_1930,
        RecoveryAction.PRESERVE_EVIDENCE
    ]


def get_remote_access_recovery() -> List[RecoveryAction]:
    """Recovery actions for remote access compromise."""
    return [
        RecoveryAction.REVOKE_REMOTE_ACCESS,
        RecoveryAction.CHANGE_CREDENTIALS,
        RecoveryAction.CONTACT_BANK,
        RecoveryAction.CALL_1930,
        RecoveryAction.PRESERVE_EVIDENCE
    ]


def get_payment_fraud_recovery() -> List[RecoveryAction]:
    """Recovery actions for payment fraud."""
    return [
        RecoveryAction.CONTACT_BANK,
        RecoveryAction.FREEZE_ACCOUNT,
        RecoveryAction.CALL_1930,
        RecoveryAction.REPORT_CYBER_FRAUD,
        RecoveryAction.PRESERVE_EVIDENCE
    ]
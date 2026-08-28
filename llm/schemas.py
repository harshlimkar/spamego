from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
import uuid


class EventType(str, Enum):
    SMS = "sms"
    CALL_STARTED = "call_started"
    CALL_TRANSCRIPT = "call_transcript"
    CALL_ENDED = "call_ended"
    SOCIAL_MESSAGE = "social_message"
    EMAIL = "email"
    PAYMENT_REQUEST = "payment_request"
    PAYMENT_NOTIFICATION = "payment_notification"
    MANUAL_TEXT = "manual_text"


class EventChannel(str, Enum):
    SMS = "sms"
    CALL = "call"
    SOCIAL = "social"
    EMAIL = "email"
    PAYMENT = "payment"
    MANUAL = "manual"


class ScamStage(str, Enum):
    DELIVERY = "DELIVERY"
    PRETEXTING = "PRETEXTING"
    URGENCY = "URGENCY"
    ISOLATION = "ISOLATION"
    CREDENTIAL_HARVESTING = "CREDENTIAL_HARVESTING"
    EXPLOITATION = "EXPLOITATION"
    OBJECTIVE_COMPLETION = "OBJECTIVE_COMPLETION"
    BENIGN = "BENIGN"
    UNKNOWN = "UNKNOWN"


class AttackerIntent(str, Enum):
    SHARE_OTP = "share_otp"
    SHARE_PIN = "share_pin"
    SHARE_PASSWORD = "share_password"
    CLICK_LINK = "click_link"
    INSTALL_APP = "install_app"
    ENABLE_REMOTE_ACCESS = "enable_remote_access"
    SCREEN_SHARE = "screen_share"
    SEND_MONEY = "send_money"
    APPROVE_PAYMENT = "approve_payment"
    CALL_NUMBER = "call_number"
    SHARE_PERSONAL_INFORMATION = "share_personal_information"


class ExposureType(str, Enum):
    MONEY = "money"
    CREDENTIALS = "credentials"
    OTP = "otp"
    ACCOUNT_ACCESS = "account_access"
    DEVICE_ACCESS = "device_access"
    PERSONAL_INFORMATION = "personal_information"
    PAYMENT_AUTHORIZATION = "payment_authorization"


class RiskLevel(str, Enum):
    SAFE = "SAFE"
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class AgentAction(str, Enum):
    IGNORE = "IGNORE"
    LOG = "LOG"
    USER_WARNING = "USER_WARNING"
    STRONG_WARNING = "STRONG_WARNING"
    HIGH_RISK_ALERT = "HIGH_RISK_ALERT"
    CRITICAL_ALERT = "CRITICAL_ALERT"
    NOTIFY_TRUSTED_CONTACT = "NOTIFY_TRUSTED_CONTACT"
    TRIGGER_RECOVERY = "TRIGGER_RECOVERY"
    REQUEST_CONFIRMATION = "REQUEST_CONFIRMATION"
    MARK_CAMPAIGN_CRITICAL = "MARK_CAMPAIGN_CRITICAL"


class AlertType(str, Enum):
    USER_WARNING = "USER_WARNING"
    HIGH_RISK = "HIGH_RISK"
    CRITICAL_SCAM = "CRITICAL_SCAM"
    TRUSTED_CONTACT_ALERT = "TRUSTED_CONTACT_ALERT"
    PAYMENT_WARNING = "PAYMENT_WARNING"
    OTP_WARNING = "OTP_WARNING"
    CALL_WARNING = "CALL_WARNING"
    SMS_WARNING = "SMS_WARNING"
    RECOVERY_ALERT = "RECOVERY_ALERT"
    VERIFICATION_RESULT = "VERIFICATION_RESULT"


class CampaignStatus(str, Enum):
    ACTIVE = "ACTIVE"
    HIGH_RISK = "HIGH_RISK"
    CRITICAL = "CRITICAL"
    RESOLVED = "RESOLVED"
    DISMISSED = "DISMISSED"


class FeedbackType(str, Enum):
    MARK_SAFE = "MARK_SAFE"
    MARK_SCAM = "MARK_SCAM"
    FALSE_POSITIVE = "FALSE_POSITIVE"
    REPORT_SCAM = "REPORT_SCAM"
    DISMISS_ALERT = "DISMISS_ALERT"


class AgentEventInput(BaseModel):
    event_id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: int = 1
    event_type: EventType
    channel: EventChannel
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    sender: Optional[str] = None
    recipient: Optional[str] = None
    content: str
    language: Optional[str] = "en"
    metadata: Dict[str, Any] = Field(default_factory=dict)
    source: str = "api"


class AgentEventInputSMS(AgentEventInput):
    event_type: EventType = EventType.SMS
    channel: EventChannel = EventChannel.SMS


class AgentEventInputCall(AgentEventInput):
    event_type: EventType = EventType.CALL_TRANSCRIPT
    channel: EventChannel = EventChannel.CALL
    call_id: Optional[str] = None
    is_final: bool = False


class AgentEventInputPayment(AgentEventInput):
    event_type: EventType = EventType.PAYMENT_REQUEST
    channel: EventChannel = EventChannel.PAYMENT
    amount: Optional[float] = None
    currency: str = "INR"
    receiver: Optional[str] = None
    upi_id: Optional[str] = None
    related_event_ids: List[str] = Field(default_factory=list)


class AgentEventInputSocial(AgentEventInput):
    event_type: EventType = EventType.SOCIAL_MESSAGE
    channel: EventChannel = EventChannel.SOCIAL
    platform: str = "instagram"
    conversation_id: Optional[str] = None


class ExposureAssessment(BaseModel):
    money_exposure: float = 0.0
    credential_exposure: bool = False
    otp_exposure: bool = False
    device_access_exposure: bool = False
    account_access_exposure: bool = False
    personal_info_exposure: bool = False
    payment_auth_exposure: bool = False
    exposure_types: List[ExposureType] = Field(default_factory=list)


class LegitimacyAssessment(BaseModel):
    verified: bool = False
    confidence: float = 0.0
    sender_status: str = "UNKNOWN"
    domain_trusted: bool = False
    entity_verified: bool = False
    details: Dict[str, Any] = Field(default_factory=dict)


class AgentAnalysisResult(BaseModel):
    classification: str  # SAFE, SPAM, SCAM
    risk_score: int  # 0-100
    confidence: float  # 0-1
    stage: ScamStage = ScamStage.UNKNOWN
    intent: List[AttackerIntent] = Field(default_factory=list)
    signals: List[str] = Field(default_factory=list)
    ml_result: Dict[str, Any] = Field(default_factory=dict)
    rule_result: Dict[str, Any] = Field(default_factory=dict)
    verification_result: Dict[str, Any] = Field(default_factory=dict)


class AgentDecision(BaseModel):
    event_id: str
    campaign_id: Optional[str] = None
    risk_score: int
    risk_level: RiskLevel
    stage: ScamStage
    intent: List[AttackerIntent] = Field(default_factory=list)
    exposure: ExposureAssessment
    legitimacy: LegitimacyAssessment
    explanation: str
    recommended_action: str
    intervention_level: str
    actions: List[AgentAction] = Field(default_factory=list)
    notify_trusted_contact: bool = False
    recovery_required: bool = False
    recovery_actions: List[str] = Field(default_factory=list)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    audit_trail: List[str] = Field(default_factory=list)


class Campaign(BaseModel):
    campaign_id: str
    user_id: int
    created_at: datetime
    last_activity: datetime
    current_stage: ScamStage = ScamStage.UNKNOWN
    risk_score: int = 0
    exposure: ExposureAssessment = Field(default_factory=ExposureAssessment)
    status: CampaignStatus = CampaignStatus.ACTIVE
    event_count: int = 0
    stage_progression: List[Dict[str, Any]] = Field(default_factory=list)
    sender_numbers: List[str] = Field(default_factory=list)
    channels: List[str] = Field(default_factory=list)


class AgentAlert(BaseModel):
    alert_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: int
    event_id: str
    campaign_id: Optional[str] = None
    severity: RiskLevel
    alert_type: AlertType
    title: str
    plain_language_reason: str
    recommended_action: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    status: str = "unread"


class TrustedContact(BaseModel):
    id: Optional[int] = None
    user_id: int
    name: str
    contact_method: str  # "sms", "call", "email", "push"
    contact_value: str  # phone number, email, etc.
    relationship: str
    consent_status: bool = False
    alert_level: RiskLevel = RiskLevel.HIGH
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ConsentRecord(BaseModel):
    id: Optional[int] = None
    user_id: int
    trusted_contact_id: int
    consent_given: bool
    consent_timestamp: datetime = Field(default_factory=datetime.utcnow)
    consent_scope: List[str] = Field(default_factory=list)  # e.g., ["critical_alerts", "all_alerts"]


class UserFeedback(BaseModel):
    id: Optional[int] = None
    user_id: int
    event_id: str
    feedback_type: FeedbackType
    comment: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)


class AgentAuditLog(BaseModel):
    id: Optional[int] = None
    event_id: str
    user_id: int
    step: str
    details: Dict[str, Any] = Field(default_factory=dict)
    timestamp: datetime = Field(default_factory=datetime.utcnow)


class RecoveryAction(str, Enum):
    CONTACT_BANK = "CONTACT_BANK"
    FREEZE_ACCOUNT = "FREEZE_ACCOUNT"
    CALL_1930 = "CALL_1930"
    REPORT_CYBER_FRAUD = "REPORT_CYBER_FRAUD"
    CHANGE_CREDENTIALS = "CHANGE_CREDENTIALS"
    REVOKE_REMOTE_ACCESS = "REVOKE_REMOTE_ACCESS"
    CONTACT_TRUSTED_FAMILY = "CONTACT_TRUSTED_FAMILY"
    PRESERVE_EVIDENCE = "PRESERVE_EVIDENCE"


class RecoveryRecommendation(BaseModel):
    actions: List[RecoveryAction]
    priority: str  # IMMEDIATE, HIGH, MEDIUM
    explanation: str
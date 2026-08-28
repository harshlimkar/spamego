from dataclasses import dataclass, field, asdict
from typing import List, Optional
from enum import Enum


class RiskLevel(str, Enum):
    SAFE = "safe"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


KILL_CHAIN_STAGES = [
    "delivery",
    "pretexting",
    "urgency",
    "isolation",
    "credential_harvesting",
    "exploitation",
    "objective_completion",
]


INTENT_TAXONOMY = {
    "otp_request": "Asking for an OTP",
    "otp_disclosure": "Asking you to reveal a received OTP",
    "payment_request": "Asking for a payment or money transfer",
    "kyc_verification": "Asking you to verify KYC",
    "bank_impersonation": "Pretending to be your bank",
    "government_impersonation": "Pretending to be a government authority",
    "customer_care_impersonation": "Pretending to be customer care",
    "prize_lottery": "Saying you won a prize or lottery",
    "investment": "Offering a high-return investment",
    "remote_access": "Asking you to install an app or give remote access",
    "credential_phishing": "Asking for passwords, PIN or account details",
    "delivery_request": "Saying a delivery failed and asking for action",
    "threat_blackmail": "Threatening or blackmailing you",
    "family_emergency": "Claiming a family member needs urgent help",
    "loan_offer": "Offering a quick loan",
    "malware_link": "Asking you to click a link",
    "information_phishing": "Asking for personal information",
    "marketing": "Marketing or promotional message",
    "notification": "Informational notification",
    "greeting": "Ordinary social message",
    "unknown": "Could not determine",
}


@dataclass
class Intent:
    name: str
    label: str
    confidence: float = 1.0
    signals: List[str] = field(default_factory=list)


@dataclass
class ScamStage:
    stage: str
    label: str
    confidence: float = 1.0
    detected_at: Optional[str] = None


@dataclass
class LinkFinding:
    url: str
    normalized_url: str
    domain: str
    registrable_domain: str
    is_suspicious: bool
    reason: str = ""
    matches_trusted: bool = False
    verdict: str = "unchecked"
    confidence: float = 1.0


@dataclass
class OtpFinding:
    context: str
    label: str
    is_risky: bool = False
    reason: str = ""
    value_present: bool = False


@dataclass
class EntityExtraction:
    phone_numbers: List[str] = field(default_factory=list)
    upi_ids: List[str] = field(default_factory=list)
    amounts_inr: List[float] = field(default_factory=list)
    urls: List[str] = field(default_factory=list)
    apps: List[str] = field(default_factory=list)
    organization_claims: List[str] = field(default_factory=list)


@dataclass
class Verification:
    status: str
    labels: List[str] = field(default_factory=list)
    risk_modifier: int = 0
    organization: str = ""
    details: str = ""


@dataclass
class RiskResult:
    score: int
    level: str
    edge_score: int = 0
    confidence: float = 0.0
    is_legitimate_signal: bool = False
    factors: dict = field(default_factory=dict)
    explanations: List[str] = field(default_factory=list)


@dataclass
class Exposure:
    money_inr: float = 0.0
    credential_risk: str = "none"
    otp_requested: bool = False
    device_access_requested: bool = False
    account_access_possible: bool = False
    description: str = ""


@dataclass
class CampaignInfo:
    campaign_id: str = ""
    risk_score: int = 0
    risk_level: str = "safe"
    categories: List[str] = field(default_factory=list)
    stage_history: List[dict] = field(default_factory=list)
    velocity_seconds: Optional[float] = None
    progression_labels: List[str] = field(default_factory=list)
    exposure: Exposure = field(default_factory=Exposure)
    event_count: int = 0
    channels: List[str] = field(default_factory=list)
    created_at: str = ""
    updated_at: str = ""
    is_new: bool = False


@dataclass
class Intervention:
    action: str
    title: str
    message: str
    buttons: List[str] = field(default_factory=list)


@dataclass
class FamilyAlertDecision:
    alert_sent: bool = False
    recipient: str = ""
    risk: str = ""
    message_preview: str = ""


def to_dict(obj):
    return asdict(obj)
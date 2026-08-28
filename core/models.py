from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from enum import Enum

class RiskLevel(str, Enum):
    SAFE = "SAFE"
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"

class NormalizedMessage(BaseModel):
    source: str  # e.g., "SMS", "INSTAGRAM", "WHATSAPP"
    sender: str
    message: str
    sender_id: Optional[str] = None
    timestamp: Optional[str] = None
    conversation_id: Optional[str] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)

class ScamAnalysisResult(BaseModel):
    risk_score: int = 0
    risk_level: RiskLevel = RiskLevel.SAFE
    domains: List[str] = Field(default_factory=list)
    scam_types: List[str] = Field(default_factory=list)
    impersonation_detected: bool = False
    impersonated_entity: Optional[str] = None
    behavioral_signals: List[str] = Field(default_factory=list)
    payment_request: bool = False
    credential_request: bool = False
    suspicious_link: bool = False
    reasons: List[str] = Field(default_factory=list)
    recommended_action: str = ""
    awareness_message: str = ""

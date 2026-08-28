from typing import Dict, Any, Optional, Tuple
from dataclasses import dataclass

from core.verification_engine import VerificationEngine
from llm.schemas import LegitimacyAssessment
from llm.config import config


@dataclass
class VerificationResult:
    status: str
    details: Optional[Dict] = None
    risk_modifier: int = 0
    is_legitimate: bool = False


class LegitimacyChecker:
    def __init__(self):
        self.verification_engine = VerificationEngine()
        
        # Known legitimate patterns (could be loaded from DB)
        self.legitimate_domains = {
            "hdfcbank.com", "icicibank.com", "sbi.co.in", "axisbank.com",
            "kotak.com", "indusind.com", "yesbank.in", "idfcfirstbank.com",
            "rbi.org.in", "gov.in", "nic.in", "uidai.gov.in"
        }
        
        self.legitimate_short_codes = {
            "1930", "1800123456", "1800200334", "18004253800"
        }

    def check_legitimacy(self, sender: str, content: str, metadata: Dict = None) -> LegitimacyAssessment:
        """Comprehensive legitimacy check combining verification engine and additional heuristics."""
        metadata = metadata or {}
        
        # 1. Use existing verification engine
        ver_result = self.verification_engine.verify_number(sender)
        sender_status = ver_result.get("status", "UNKNOWN")
        
        # 2. Check domain legitimacy if URLs present
        domain_trusted = self._check_domains(content)
        
        # 3. Check if entity can be verified
        entity_verified = self._check_entity_verification(sender, content)
        
        # 4. Calculate overall confidence
        verified = False
        confidence = 0.0
        
        if sender_status == "VERIFIED_OFFICIAL":
            verified = True
            confidence = 0.95
        elif sender_status == "TRUSTED_CONTACT":
            verified = True
            confidence = 0.9
        elif sender_status == "REPORTED_SCAM":
            verified = False
            confidence = 0.95
        else:
            # UNKNOWN - use heuristics
            verified, confidence = self._heuristic_verification(sender, content, domain_trusted, entity_verified)
        
        return LegitimacyAssessment(
            verified=verified,
            confidence=confidence,
            sender_status=sender_status,
            domain_trusted=domain_trusted,
            entity_verified=entity_verified,
            details={
                "verification_result": ver_result,
                "heuristic_checks": {
                    "domain_trusted": domain_trusted,
                    "entity_verified": entity_verified
                }
            }
        )

    def _check_domains(self, content: str) -> bool:
        """Check if any URLs in content point to legitimate domains."""
        import re
        urls = re.findall(r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+', content)
        for url in urls:
            for domain in self.legitimate_domains:
                if domain in url:
                    return True
        return False

    def _check_entity_verification(self, sender: str, content: str) -> bool:
        """Check if the claimed entity can be verified."""
        # Check for short codes
        if sender in self.legitimate_short_codes:
            return True
        
        # Check if sender claims to be from a known entity and number matches
        content_lower = content.lower()
        bank_keywords = ["hdfc", "icici", "sbi", "axis", "kotak", "indusind", "yes bank", "idfc"]
        for bank in bank_keywords:
            if bank in content_lower:
                # In real implementation, would check against official number registry
                return False  # Default to not verified unless in registry
        
        return False

    def _heuristic_verification(self, sender: str, content: str, 
                                domain_trusted: bool, entity_verified: bool) -> Tuple[bool, float]:
        """Heuristic verification for unknown senders."""
        content_lower = content.lower()
        
        # Negative signals
        negative_signals = 0
        if "urgent" in content_lower or "immediately" in content_lower:
            negative_signals += 1
        if any(kw in content_lower for kw in ["otp", "pin", "password", "cvv"]):
            negative_signals += 2
        if any(kw in content_lower for kw in ["remote access", "teamviewer", "anydesk", "install app"]):
            negative_signals += 2
        if "kyc" in content_lower and ("expire" in content_lower or "blocked" in content_lower):
            negative_signals += 2
        
        # Positive signals
        positive_signals = 0
        if domain_trusted:
            positive_signals += 2
        if entity_verified:
            positive_signals += 2
        if sender in self.legitimate_short_codes:
            positive_signals += 3
        if "do not share" in content_lower or "never share" in content_lower:
            positive_signals += 1
        
        net_score = positive_signals - negative_signals
        
        if net_score >= 2:
            return True, 0.7
        elif net_score >= 0:
            return False, 0.4
        else:
            return False, 0.1

    def get_risk_modifier(self, legitimacy: LegitimacyAssessment) -> int:
        """Convert legitimacy assessment to risk modifier."""
        if legitimacy.verified:
            if legitimacy.sender_status == "VERIFIED_OFFICIAL":
                return -50
            elif legitimacy.sender_status == "TRUSTED_CONTACT":
                return -40
            else:
                return -20
        else:
            if legitimacy.sender_status == "REPORTED_SCAM":
                return 30
            elif legitimacy.confidence < 0.2:
                return 15
            else:
                return 5  # Unknown but not verified
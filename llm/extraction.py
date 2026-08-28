import re
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass

from llm.schemas import AttackerIntent, ScamStage, ExposureType


@dataclass
class IntentSignal:
    intent: AttackerIntent
    confidence: float
    matched_pattern: str


@dataclass
class StageSignal:
    stage: ScamStage
    confidence: float
    matched_patterns: List[str]


class IntentExtractor:
    def __init__(self):
        self.intent_patterns = {
            AttackerIntent.SHARE_OTP: [
                (r"\b(?:tell|give|share|send|provide)\s+(?:me\s+)?(?:the\s+)?otp\b", 0.95),
                (r"\botp\s+(?:is|:)\s*\d{4,6}\b", 0.85),
                (r"\bwhat\s+is\s+(?:the\s+)?otp\b", 0.9),
                (r"\bshare\s+(?:your\s+)?otp\b", 0.95),
                (r"\botp\s+(?:code|number)\b", 0.8),
            ],
            AttackerIntent.SHARE_PIN: [
                (r"\b(?:tell|give|share|send)\s+(?:me\s+)?(?:your\s+)?pin\b", 0.95),
                (r"\bwhat\s+is\s+(?:your\s+)?pin\b", 0.9),
                (r"\bpin\s+(?:is|:)\s*\d{4,6}\b", 0.85),
            ],
            AttackerIntent.SHARE_PASSWORD: [
                (r"\b(?:tell|give|share|send)\s+(?:me\s+)?(?:your\s+)?password\b", 0.95),
                (r"\bwhat\s+is\s+(?:your\s+)?password\b", 0.9),
                (r"\blogin\s+(?:credentials|details)\b", 0.8),
            ],
            AttackerIntent.CLICK_LINK: [
                (r"\bclick\s+(?:the\s+)?link\b", 0.9),
                (r"\bopen\s+(?:the\s+)?link\b", 0.9),
                (r"\bvisit\s+(?:the\s+)?(?:link|url)\b", 0.85),
                (r"https?://\S+", 0.7),
                (r"\bgo\s+to\s+\S+\.(?:com|in|net|org)\b", 0.75),
            ],
            AttackerIntent.INSTALL_APP: [
                (r"\binstall\s+(?:the\s+)?(?:app|application)\b", 0.9),
                (r"\bdownload\s+(?:the\s+)?(?:app|apk)\b", 0.9),
                (r"\bapk\s+(?:file|download)\b", 0.85),
                (r"\bplay\s+store\s+link\b", 0.75),
            ],
            AttackerIntent.ENABLE_REMOTE_ACCESS: [
                (r"\b(?:enable|allow|grant)\s+remote\s+access\b", 0.95),
                (r"\bremote\s+(?:access|control|desktop)\b", 0.85),
                (r"\bteamviewer|anydesk|quick\s+support\b", 0.9),
                (r"\bscreen\s+sharing\s+(?:app|tool)\b", 0.85),
            ],
            AttackerIntent.SCREEN_SHARE: [
                (r"\bshare\s+(?:your\s+)?screen\b", 0.95),
                (r"\bscreen\s+share\b", 0.9),
                (r"\bcan\s+you\s+see\s+my\s+screen\b", 0.85),
            ],
            AttackerIntent.SEND_MONEY: [
                (r"\b(?:send|transfer|pay)\s+(?:money|amount|rs\.?|₹)\b", 0.9),
                (r"\bmake\s+(?:a\s+)?payment\b", 0.85),
                (r"\bupi\s+(?:payment|transfer|id)\b", 0.85),
                (r"\bscan\s+(?:qr|code)\b", 0.8),
            ],
            AttackerIntent.APPROVE_PAYMENT: [
                (r"\bapprove\s+(?:the\s+)?payment\b", 0.95),
                (r"\bauthorize\s+(?:the\s+)?(?:transaction|payment)\b", 0.9),
                (r"\baccept\s+(?:the\s+)?(?:request|payment)\b", 0.85),
            ],
            AttackerIntent.CALL_NUMBER: [
                (r"\bcall\s+(?:me\s+)?(?:at|on)\s+\d{10}\b", 0.85),
                (r"\bdial\s+\d{10}\b", 0.8),
                (r"\bcall\s+this\s+number\b", 0.8),
            ],
            AttackerIntent.SHARE_PERSONAL_INFORMATION: [
                (r"\b(?:tell|give|share|send)\s+(?:me\s+)?(?:your\s+)?(?:aadhaar|pan|address|dob|date\s+of\s+birth)\b", 0.9),
                (r"\bpersonal\s+(?:details|information|info)\b", 0.8),
                (r"\bkyc\s+(?:details|documents|verification)\b", 0.85),
            ],
        }

    def extract_intents(self, text: str) -> List[IntentSignal]:
        text_lower = text.lower()
        detected = []
        
        for intent, patterns in self.intent_patterns.items():
            for pattern, confidence in patterns:
                matches = list(re.finditer(pattern, text_lower, re.IGNORECASE))
                if matches:
                    for match in matches:
                        detected.append(IntentSignal(
                            intent=intent,
                            confidence=confidence,
                            matched_pattern=match.group()
                        ))
        
        # Sort by confidence descending
        detected.sort(key=lambda x: x.confidence, reverse=True)
        return detected

    def get_unique_intents(self, text: str) -> List[AttackerIntent]:
        signals = self.extract_intents(text)
        seen = set()
        unique = []
        for signal in signals:
            if signal.intent not in seen:
                seen.add(signal.intent)
                unique.append(signal.intent)
        return unique


class StageExtractor:
    def __init__(self):
        self.stage_patterns = {
            ScamStage.DELIVERY: [
                (r"\b(?:received|got|gotten)\s+(?:a\s+)?(?:call|message|sms|email)\b", 0.7),
                (r"\bincoming\s+(?:call|message)\b", 0.6),
                (r"\bnotification\b", 0.5),
            ],
            ScamStage.PRETEXTING: [
                (r"\b(?:calling|call)\s+from\s+(?:your\s+)?(?:bank|police|rbi|government|income\s+tax)\b", 0.9),
                (r"\b(?:i\s+am|this\s+is)\s+(?:from|calling\s+from)\b", 0.85),
                (r"\b(?:bank|police|rbi|government)\s+(?:officer|employee|representative)\b", 0.9),
                (r"\bon\s+behalf\s+of\b", 0.8),
                (r"\bverify\s+(?:your\s+)?(?:account|identity|kyc)\b", 0.85),
            ],
            ScamStage.URGENCY: [
                (r"\b(?:urgent|immediately|right\s+now|asap|quickly)\b", 0.85),
                (r"\b(?:account\s+(?:blocked|block|frozen|closed)|will\s+be\s+blocked)\b", 0.9),
                (r"\blast\s+chance|final\s+notice|deadline\b", 0.85),
                (r"\bif\s+you\s+don't|unless\s+you\b", 0.8),
                (r"\btime\s+(?:is\s+)?running\s+out\b", 0.8),
            ],
            ScamStage.ISOLATION: [
                (r"\bdon't\s+tell\s+(?:anyone|anybody)\b", 0.9),
                (r"\bkeep\s+this\s+(?:secret|confidential|private)\b", 0.85),
                (r"\bdon't\s+call\s+(?:back|anyone)\b", 0.8),
                (r"\bthis\s+is\s+(?:confidential|between\s+us)\b", 0.8),
            ],
            ScamStage.CREDENTIAL_HARVESTING: [
                (r"\b(?:otp|pin|password|cvv|aadhaar|pan)\b", 0.85),
                (r"\bshare\s+(?:otp|pin|password)\b", 0.95),
                (r"\bverify\s+(?:otp|pin|password)\b", 0.85),
                (r"\b(?:login|banking)\s+(?:credentials|details)\b", 0.9),
            ],
            ScamStage.EXPLOITATION: [
                (r"\b(?:send|transfer|pay)\s+(?:money|amount|₹|rs\.?)\s*\d+\b", 0.95),
                (r"\bupi\s+(?:id|payment|transfer)\b", 0.9),
                (r"\bscan\s+(?:qr|code)\s+to\s+pay\b", 0.9),
                (r"\bapprove\s+(?:payment|request)\b", 0.9),
                (r"\bremote\s+(?:access|control)\b", 0.9),
                (r"\binstall\s+(?:app|apk)\b", 0.85),
            ],
            ScamStage.OBJECTIVE_COMPLETION: [
                (r"\b(?:payment\s+sent|money\s+transferred|transaction\s+complete)\b", 0.9),
                (r"\botp\s+(?:shared|given|provided)\b", 0.85),
                (r"\bapp\s+installed\b", 0.8),
                (r"\bremote\s+access\s+(?:granted|enabled)\b", 0.85),
            ],
            ScamStage.BENIGN: [
                (r"\b(?:thank\s+you|thanks|okay|ok)\b", 0.5),
                (r"\bhave\s+a\s+(?:nice|good)\s+day\b", 0.5),
            ],
        }

    def extract_stage(self, text: str, previous_stage: Optional[ScamStage] = None) -> Tuple[ScamStage, float]:
        text_lower = text.lower()
        stage_scores = {}
        
        for stage, patterns in self.stage_patterns.items():
            score = 0.0
            matched = []
            for pattern, weight in patterns:
                if re.search(pattern, text_lower, re.IGNORECASE):
                    score += weight
                    matched.append(pattern)
            
            if score > 0:
                stage_scores[stage] = (score, matched)
        
        if not stage_scores:
            return ScamStage.UNKNOWN, 0.0
        
        # Get highest scoring stage
        best_stage = max(stage_scores.items(), key=lambda x: x[1][0])
        stage = best_stage[0]
        confidence = min(best_stage[1][0], 1.0)
        
        # Consider progression logic
        if previous_stage:
            stage = self._validate_progression(previous_stage, stage, confidence)
        
        return stage, confidence

    def _validate_progression(self, previous: ScamStage, current: ScamStage, confidence: float) -> ScamStage:
        # Define valid progressions
        valid_progressions = {
            ScamStage.DELIVERY: [ScamStage.PRETEXTING, ScamStage.URGENCY, ScamStage.BENIGN],
            ScamStage.PRETEXTING: [ScamStage.URGENCY, ScamStage.ISOLATION, ScamStage.CREDENTIAL_HARVESTING, ScamStage.BENIGN],
            ScamStage.URGENCY: [ScamStage.ISOLATION, ScamStage.CREDENTIAL_HARVESTING, ScamStage.EXPLOITATION, ScamStage.BENIGN],
            ScamStage.ISOLATION: [ScamStage.CREDENTIAL_HARVESTING, ScamStage.EXPLOITATION, ScamStage.BENIGN],
            ScamStage.CREDENTIAL_HARVESTING: [ScamStage.EXPLOITATION, ScamStage.OBJECTIVE_COMPLETION, ScamStage.BENIGN],
            ScamStage.EXPLOITATION: [ScamStage.OBJECTIVE_COMPLETION, ScamStage.BENIGN],
            ScamStage.OBJECTIVE_COMPLETION: [ScamStage.BENIGN],
            ScamStage.BENIGN: [ScamStage.BENIGN],
            ScamStage.UNKNOWN: list(ScamStage),
        }
        
        valid_next = valid_progressions.get(previous, list(ScamStage))
        if current in valid_next:
            return current
        
        # If invalid progression but high confidence, allow it
        if confidence > 0.8:
            return current
        
        # Otherwise, stay at previous or go to UNKNOWN
        return previous if previous != ScamStage.UNKNOWN else ScamStage.UNKNOWN


class ExposureExtractor:
    def __init__(self):
        self.money_patterns = [
            (r"(?:₹|rs\.?|inr)\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)", 1.0),
            (r"(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)\s*(?:rupees|rs|₹)", 0.9),
            (r"\b(\d{5,7})\b(?=\s*(?:rupees|rs|₹))", 0.7),  # 5-7 digits likely money
        ]
        
        self.credential_keywords = [
            "password", "pin", "cvv", "aadhaar", "pan", "otp", 
            "login", "credentials", "username", "user id"
        ]
        
        self.device_access_keywords = [
            "remote access", "teamviewer", "anydesk", "quick support",
            "screen sharing", "screen share", "remote control",
            "install app", "apk", "download app"
        ]
        
        self.payment_keywords = [
            "upi", "qr code", "scan qr", "payment request",
            "approve payment", "authorize payment"
        ]

    def extract_exposure(self, text: str, intents: List[AttackerIntent], 
                        metadata: Dict[str, Any] = None) -> Dict[str, Any]:
        text_lower = text.lower()
        metadata = metadata or {}
        
        # Money exposure
        money_amount = 0.0
        for pattern, weight in self.money_patterns:
            matches = re.findall(pattern, text_lower, re.IGNORECASE)
            for match in matches:
                try:
                    # Clean the match (remove commas)
                    amount_str = match.replace(",", "")
                    amount = float(amount_str)
                    if amount > money_amount:
                        money_amount = amount
                except ValueError:
                    pass
        
        # Check metadata for payment amount
        if metadata.get("amount"):
            money_amount = max(money_amount, float(metadata["amount"]))
        
        # Credential exposure
        credential_exposure = any(kw in text_lower for kw in self.credential_keywords)
        credential_exposure = credential_exposure or any(
            i in [AttackerIntent.SHARE_OTP, AttackerIntent.SHARE_PIN, 
                  AttackerIntent.SHARE_PASSWORD, AttackerIntent.SHARE_PERSONAL_INFORMATION]
            for i in intents
        )
        
        # OTP exposure
        otp_exposure = AttackerIntent.SHARE_OTP in intents
        otp_exposure = otp_exposure or bool(re.search(r"\botp\b", text_lower))
        
        # Device access exposure
        device_access_exposure = any(kw in text_lower for kw in self.device_access_keywords)
        device_access_exposure = device_access_exposure or any(
            i in [AttackerIntent.ENABLE_REMOTE_ACCESS, AttackerIntent.SCREEN_SHARE, 
                  AttackerIntent.INSTALL_APP]
            for i in intents
        )
        
        # Payment authorization exposure
        payment_auth_exposure = any(kw in text_lower for kw in self.payment_keywords)
        payment_auth_exposure = payment_auth_exposure or any(
            i in [AttackerIntent.APPROVE_PAYMENT, AttackerIntent.SEND_MONEY]
            for i in intents
        )
        
        # Account access exposure
        account_access_exposure = credential_exposure or device_access_exposure
        
        # Personal info exposure
        personal_info_exposure = AttackerIntent.SHARE_PERSONAL_INFORMATION in intents
        personal_info_exposure = personal_info_exposure or any(
            kw in text_lower for kw in ["aadhaar", "pan", "address", "dob", "date of birth"]
        )
        
        exposure_types = []
        if money_amount > 0:
            exposure_types.append(ExposureType.MONEY)
        if credential_exposure:
            exposure_types.append(ExposureType.CREDENTIALS)
        if otp_exposure:
            exposure_types.append(ExposureType.OTP)
        if device_access_exposure:
            exposure_types.append(ExposureType.DEVICE_ACCESS)
        if account_access_exposure:
            exposure_types.append(ExposureType.ACCOUNT_ACCESS)
        if personal_info_exposure:
            exposure_types.append(ExposureType.PERSONAL_INFORMATION)
        if payment_auth_exposure:
            exposure_types.append(ExposureType.PAYMENT_AUTHORIZATION)
        
        return {
            "money_exposure": money_amount,
            "credential_exposure": credential_exposure,
            "otp_exposure": otp_exposure,
            "device_access_exposure": device_access_exposure,
            "account_access_exposure": account_access_exposure,
            "personal_info_exposure": personal_info_exposure,
            "payment_auth_exposure": payment_auth_exposure,
            "exposure_types": exposure_types
        }


intent_extractor = IntentExtractor()
stage_extractor = StageExtractor()
exposure_extractor = ExposureExtractor()
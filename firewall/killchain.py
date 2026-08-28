import re
from datetime import datetime, timezone

from .schema import ScamStage, KILL_CHAIN_STAGES

STAGE_LABELS = {
    "delivery": "Initial delivery of the scam message/call",
    "pretexting": "The attacker states a false reason to talk to you",
    "urgency": "The attacker pressures you to act fast",
    "isolation": "The attacker isolates you from checking with others",
    "credential_harvesting": "The attacker asks for a secret (OTP, PIN, password)",
    "exploitation": "The attacker tries to take your money or access",
    "objective_completion": "The attacker's goal may have been completed",
    "benign": "No scam progression detected",
}

STAGE_KEYWORDS = {
    "delivery": ["dear", "sir", "madam", "greetings", "hello", "hi", "notice"],
    "pretexting": ["bank", "sbi", "hdfc", "icici", "income tax", "kyc", "customer care", "police", "delivery", "electricity", "winner", "prize", "lottery", "accident"],
    "urgency": ["within 24", "today", "immediately", "urgent", "last date", "will be blocked", "will be suspended", "expire", "expired", "action required", "final reminder", "உடனே", "அவசர", "तुरंत", "जल्दी"],
    "isolation": ["do not tell anyone", "don't share this call", "keep it secret", "do not consult", "alone", "don't discuss", "avoid family", "don't inform"],
    "credential_harvesting": ["otp", "pin", "password", "cvv", "netbanking id", "atmpin", "verify otp", "share otp", "tell me the otp", "one time password"],
    "exploitation": ["transfer", "send money", "payment", "processing fee", "install app", "anydesk", "teamviewer", "upi", "advance", "deposit"],
    "objective_completion": ["confirm payment", "paid", "transfer done", "submit", "done"],
}

BENIGN_INTENTS = {"marketing", "notification", "greeting", "unknown"}


PRE_TEXT_INTENTS = {"bank_impersonation", "government_impersonation", "prize_lottery", "family_emergency", "threat_blackmail", "delivery_request", "customer_care_impersonation"}
HARVEST_INTENTS = {"otp_request", "otp_disclosure", "credential_phishing"}
EXPLOIT_INTENTS = {"payment_request", "remote_access"}
MONEY_SEND_MARKERS = ["send money", "transfer", "pay now", "pay", "send", "deposit", "advance", "fee", "upi"]


class KillChainDetector:
    def detect(self, text, intents, otp, entities):
        lowered = (text or "").lower()
        top_intent = intents[0].name if intents else "unknown"
        benign_intent = top_intent in BENIGN_INTENTS
        has_money_send = any(m in lowered for m in MONEY_SEND_MARKERS)
        current = "benign"
        best_weight = 0.0
        for stage in ["delivery", "pretexting", "urgency", "isolation", "credential_harvesting", "exploitation", "objective_completion"]:
            weight = 0
            for kw in STAGE_KEYWORDS[stage]:
                if kw in lowered:
                    weight += 1
            if top_intent in PRE_TEXT_INTENTS and stage == "pretexting":
                weight += 3
            if top_intent in HARVEST_INTENTS and stage == "credential_harvesting":
                weight += 5
            if top_intent in EXPLOIT_INTENTS and stage == "exploitation":
                weight += 6
            if otp and otp.is_risky and stage == "credential_harvesting":
                weight += 5
            if entities.apps and stage == "exploitation":
                weight += 3
            if entities.amounts_inr and stage == "exploitation" and has_money_send:
                weight += 3
            if benign_intent:
                weight = max(0, weight - 5)
            if weight > best_weight:
                best_weight = weight
                current = stage
        if best_weight == 0:
            current = "benign"
        return ScamStage(
            stage=current,
            label=STAGE_LABELS[current],
            confidence=min(0.99, 0.5 + best_weight * 0.1),
            detected_at=datetime.now(timezone.utc).isoformat(),
        )


kill_chain = KillChainDetector()
import re

from .schema import Intent, INTENT_TAXONOMY

INTENT_RULES = {
    "otp_request": [
        ["otp", "tell"], ["otp", "share"], ["otp", "send me"], ["otp", "give me"],
        ["otp", "provide"], ["otp", "confirm"], ["otp", "சொல்லுங்க"], ["otp", "kudunga"],
        ["otp", "बताइए"], ["otp", "भेजें"],
    ],
    "otp_disclosure": [
        ["otp you received", "tell"], ["received otp"], ["that otp", "send"],
        ["the otp just"],

    ],
    "kyc_verification": [
        ["kyc", "complete"], ["kyc", "update"], ["kyc", "expire"], ["kyc", "expired"],
        ["kyc", "link"], ["kyc", "verify"], ["know your customer"],
        ["kyc", "suspend"], ["kyc", "blocked"], ["kyc", "aagiduchu"], ["kyc", "उम्र"],
    ],
    "bank_impersonation": [
        ["bank", "otp"], ["bank", "kyc"], ["bank", "block"], ["bank", "account", "verify"],
        ["sbi"], ["hdfc", "account"], ["icici", "account"], ["bank", "employee"],
        ["bank", "update"], ["bank", "freeze"], ["bank", "suspension"], ["rbi", "account"],
        ["state bank"], ["bank", "limit"], ["bank", "aadhaar"],
    ],
    "government_impersonation": [
        ["income tax", "pending"], ["gst", "blocked"], ["cyber crime", "arrest"],
        ["police", "case"], ["court", "warrant"], ["investigation", "phone"],
        ["aadhaar", "suspend"], ["passport", "block"], ["epfo", "kyc"],
        ["electricity", "disconnect"], ["govt", "refund"],
    ],
    "customer_care_impersonation": [
        ["customer care", "call"], ["support", "confirm order"], ["help desk"],
        ["executive", "otp"], ["toll free", "claim"],
    ],
    "payment_request": [
        ["send money", "now"], ["transfer", "now"], ["pay", "today"], ["processing fee"],
        ["registration fee"], ["advance", "money"], ["refund", "pay"], ["pay", "within"],
        ["complete payment"], ["security deposit", "pay"], ["shipping fee"],
        ["money", "send"], ["bank", "transfer", "verify"],
    ],
    "remote_access": [
        ["anydesk"], ["teamviewer"], ["quicksupport"], ["install", "app"], ["screen share"],
        ["download", "app", "verify"], ["remote", "access"],
    ],
    "credential_phishing": [
        ["password", "tell"], ["pin", "tell"], ["netbanking", "user id"], ["atm pin", "share"],
        ["login", "details"], ["customer id", "give"], ["cvv"], ["debit card", "number"],
        ["password", "reset", "link"],
    ],
    "prize_lottery": [
        ["won", "prize"], ["lucky draw", "won"], ["lottery", "won"], ["congratulations", "won"],
        ["you have won"], ["winner", "claim"], ["prize", "claim"],
    ],
    "investment": [
        ["investment", "return"], ["double", "money"], ["guaranteed", "return"],
        ["stock", "tips"], ["binary", "trading"], ["crypto", "investment"], ["mutual fund", "high return"],
    ],
    "delivery_request": [
        ["delivery", "failed"], ["package", "fee"], ["parcel", "pending"], ["courier", "fee"],
        ["delivery", "address"],
    ],
    "threat_blackmail": [
        ["arrest"], ["blackmail"], ["supari"], ["personal photos"], ["compromising"],
        ["you will be arrested"], ["non-bailable"], ["police", "complaint"],
    ],
    "family_emergency": [
        ["accident", "money"], ["family member", "helpline"], ["brother", "emergency"],
        ["son", "accident"], ["daughter", "emergency"], ["hospitalized", "money"],
        ["relative", "urgent"],
    ],
    "malware_link": [
        ["click", "link", "verify"], ["update", "link"], ["reset", "link"],
        ["suspicious", "link", "click"],
    ],
    "information_phishing": [
        ["full name", "gotra"], ["address", "tell"], ["date of birth", "tell"],
        ["account balance", "tell"], ["details", "share"],
    ],
}

GENERIC_INTENTS = {
    "marketing": ["offer", "discount", "sale begins", "exclusive", "limited period"],
    "notification": ["transaction", "credited", "debited", "ref no", "txn id", "received rs", "balance", "due amount", "statement"],
    "greeting": ["hi", "hello", "good morning", "good evening", "how are you", "how r u"],
}


class IntentClassifier:
    def detect(self, text, entities, ml_label):
        lowered = (text or "").lower()
        lowered = re.sub(r"\s+", " ", lowered)
        scores = {}
        for intent, rule_groups in INTENT_RULES.items():
            total = 0.0
            pos_signal_found = 1.0
            for group in rule_groups:
                if all(g in lowered for g in group):
                    total = max(total, 0.9)
                    pos_signal_found = max(pos_signal_found, 0.95)
            if total:
                scores[intent] = total
        if ml_label in ("SCAM", "SPAM"):
            scores["malware_link"] = max(scores.get("malware_link", 0), 0.55)
        claimed_org = entities.organization_claims
        if claimed_org:
            bankish = any(
                o in b for o in ["sbi", "bank", "hdfc", "icici", "axis", "kotak", "pnb", "rbi", "paytm", "phonepe", "upi"]
                for b in claimed_org
            )
            if bankish:
                scores["bank_impersonation"] = max(scores.get("bank_impersonation", 0), 0.5)
            govish = any(o in b for o in ["income tax", "gov", "police", "passport", "epfo", "gst", "aadhaar"] for b in claimed_org)
            if govish:
                scores["government_impersonation"] = max(scores.get("government_impersonation", 0), 0.5)
        if entities.apps:
            scores["remote_access"] = max(scores.get("remote_access", 0), 0.85)
        if not scores:
            for intent, terms in GENERIC_INTENTS.items():
                if any(t in lowered for t in terms):
                    scores[intent] = 0.6
        if not scores:
            scores["unknown"] = 0.4
        ranked = sorted(scores.items(), key=lambda kv: kv[1], reverse=True)[:3]
        return [
            Intent(name=name, label=INTENT_TAXONOMY.get(name, name), confidence=conf)
            for name, conf in ranked
        ]


intent_classifier = IntentClassifier()
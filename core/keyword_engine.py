class KeywordEngine:
    def __init__(self):
        # Universal keyword dictionary categorized by Domain, Scam Type, and Behavior
        self.keywords = {
            # Domains (Level 1) - Low weight for pure domains to prevent false positives
            "bank": {"weight": 5, "domain": "FINANCIAL", "type": "DOMAIN_MARKER"},
            "rbi": {"weight": 5, "domain": "FINANCIAL", "type": "DOMAIN_MARKER"},
            "police": {"weight": 10, "domain": "LEGAL", "type": "DOMAIN_MARKER"},
            "cbi": {"weight": 10, "domain": "LEGAL", "type": "DOMAIN_MARKER"},
            "court": {"weight": 10, "domain": "LEGAL", "type": "DOMAIN_MARKER"},
            "hospital": {"weight": 5, "domain": "MEDICAL", "type": "DOMAIN_MARKER"},
            "doctor": {"weight": 5, "domain": "MEDICAL", "type": "DOMAIN_MARKER"},
            "customs": {"weight": 10, "domain": "DELIVERY", "type": "DOMAIN_MARKER"},
            "fedex": {"weight": 10, "domain": "DELIVERY", "type": "DOMAIN_MARKER"},
            "courier": {"weight": 5, "domain": "DELIVERY", "type": "DOMAIN_MARKER"},
            "hr": {"weight": 5, "domain": "EMPLOYMENT", "type": "DOMAIN_MARKER"},
            "job": {"weight": 5, "domain": "EMPLOYMENT", "type": "DOMAIN_MARKER"},

            # Scam Types (Level 2) & Requests
            "otp": {"weight": 25, "scam_type": "OTP_SCAM", "behavior": "CREDENTIAL_REQUEST"},
            "cvv": {"weight": 30, "scam_type": "OTP_SCAM", "behavior": "CREDENTIAL_REQUEST"},
            "password": {"weight": 25, "scam_type": "PHISHING", "behavior": "CREDENTIAL_REQUEST"},
            "kyc": {"weight": 15, "scam_type": "KYC_SCAM", "behavior": "IDENTITY_REQUEST"},
            "digital arrest": {"weight": 50, "scam_type": "DIGITAL_ARREST", "behavior": "THREAT"},
            "arrest warrant": {"weight": 40, "scam_type": "DIGITAL_ARREST", "behavior": "THREAT"},
            "legal action": {"weight": 40, "scam_type": "LEGAL_SCAM", "behavior": "THREAT"},
            "seized": {"weight": 30, "scam_type": "LEGAL_SCAM", "behavior": "THREAT"},
            "fir": {"weight": 30, "scam_type": "LEGAL_SCAM", "behavior": "THREAT"},
            "blood needed": {"weight": 30, "scam_type": "MEDICAL_EMERGENCY", "behavior": "EMERGENCY_CLAIM"},
            "accident": {"weight": 25, "scam_type": "MEDICAL_EMERGENCY", "behavior": "EMERGENCY_CLAIM"},
            "screen sharing": {"weight": 40, "scam_type": "MALWARE", "behavior": "REMOTE_ACCESS_REQUEST"},
            "anydesk": {"weight": 40, "scam_type": "MALWARE", "behavior": "REMOTE_ACCESS_REQUEST"},
            "apk": {"weight": 30, "scam_type": "MALWARE", "behavior": "LINK_REQUEST"},
            "pay the fine": {"weight": 30, "scam_type": "PAYMENT_SCAM", "behavior": "PAYMENT_REQUEST"},
            "payment": {"weight": 20, "scam_type": "PAYMENT_SCAM", "behavior": "PAYMENT_REQUEST"},
            "send money": {"weight": 30, "scam_type": "PAYMENT_SCAM", "behavior": "PAYMENT_REQUEST"},
            "upi": {"weight": 20, "scam_type": "PAYMENT_SCAM", "behavior": "PAYMENT_REQUEST"},
            "refund": {"weight": 20, "scam_type": "REFUND_SCAM", "behavior": "MANIPULATION"},
            "lottery": {"weight": 20, "scam_type": "LOTTERY_SCAM", "behavior": "MANIPULATION"},
            "prize": {"weight": 20, "scam_type": "LOTTERY_SCAM", "behavior": "MANIPULATION"},

            # Behavioral Signals
            "urgent": {"weight": 15, "behavior": "URGENCY"},
            "immediately": {"weight": 15, "behavior": "URGENCY"},
            "account blocked": {"weight": 25, "behavior": "THREAT"},
            "suspend": {"weight": 20, "behavior": "THREAT"},
            "secret": {"weight": 20, "behavior": "SECRECY"},
            "don't tell anyone": {"weight": 30, "behavior": "ISOLATION"},
            
            # Tamil / Mixed
            "பணம்": {"weight": 20, "scam_type": "PAYMENT_SCAM", "behavior": "PAYMENT_REQUEST"},
            "வங்கி": {"weight": 10, "domain": "FINANCIAL", "type": "DOMAIN_MARKER"},
            "கணக்கு முடக்கம்": {"weight": 25, "behavior": "THREAT"}
        }

    def analyze_text(self, text: str) -> dict:
        text_lower = text.lower()
        detected = []
        domains = set()
        scam_types = set()
        behaviors = set()
        total_weight = 0

        for keyword, data in self.keywords.items():
            if keyword in text_lower:
                detected.append(keyword)
                total_weight += data["weight"]
                
                if "domain" in data:
                    domains.add(data["domain"])
                if "scam_type" in data:
                    scam_types.add(data["scam_type"])
                if "behavior" in data:
                    behaviors.add(data["behavior"])
        
        return {
            "keywords_detected": detected,
            "domains": list(domains),
            "scam_types": list(scam_types),
            "behaviors": list(behaviors),
            "keyword_weight": total_weight
        }

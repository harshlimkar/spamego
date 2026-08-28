import re

class KeywordEngine:
    def __init__(self):
        # Universal keyword dictionary categorized by Domain, Scam Type, Category, and Behavior
        self.keywords = {
            # Domains (Level 1)
            "bank": {"weight": 5, "domain": "FINANCIAL", "category": "Bank Context", "type": "DOMAIN_MARKER"},
            "rbi": {"weight": 5, "domain": "FINANCIAL", "category": "Bank Context", "type": "DOMAIN_MARKER"},
            "sbi": {"weight": 5, "domain": "FINANCIAL", "category": "Bank Context", "type": "DOMAIN_MARKER"},
            "hdfc": {"weight": 5, "domain": "FINANCIAL", "category": "Bank Context", "type": "DOMAIN_MARKER"},
            "icici": {"weight": 5, "domain": "FINANCIAL", "category": "Bank Context", "type": "DOMAIN_MARKER"},
            "police": {"weight": 10, "domain": "LEGAL", "category": "Police Impersonation", "type": "DOMAIN_MARKER"},
            "cbi": {"weight": 10, "domain": "LEGAL", "category": "Police Impersonation", "type": "DOMAIN_MARKER"},
            "court": {"weight": 10, "domain": "LEGAL", "category": "Legal Threat", "type": "DOMAIN_MARKER"},
            "hospital": {"weight": 5, "domain": "MEDICAL", "category": "Hospital Impersonation", "type": "DOMAIN_MARKER"},
            "doctor": {"weight": 5, "domain": "MEDICAL", "category": "Hospital Impersonation", "type": "DOMAIN_MARKER"},
            "customs": {"weight": 10, "domain": "DELIVERY", "category": "Courier Scam", "type": "DOMAIN_MARKER"},
            "fedex": {"weight": 10, "domain": "DELIVERY", "category": "Courier Scam", "type": "DOMAIN_MARKER"},
            "courier": {"weight": 5, "domain": "DELIVERY", "category": "Courier Scam", "type": "DOMAIN_MARKER"},
            "hr": {"weight": 5, "domain": "EMPLOYMENT", "category": "Job Scam", "type": "DOMAIN_MARKER"},
            "job": {"weight": 5, "domain": "EMPLOYMENT", "category": "Job Scam", "type": "DOMAIN_MARKER"},

            # Credential & OTP Theft
            "otp": {"weight": 25, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "pin": {"weight": 30, "domain": "FINANCIAL", "scam_type": "CREDENTIAL_THEFT", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "password": {"weight": 25, "domain": "CYBER", "scam_type": "PHISHING", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "cvv": {"weight": 30, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "share otp": {"weight": 40, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "tell me the otp": {"weight": 45, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "tell otp": {"weight": 40, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "otp batao": {"weight": 40, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},
            "otp dijiye": {"weight": 40, "domain": "FINANCIAL", "scam_type": "OTP_SCAM", "category": "Credential Theft", "behavior": "CREDENTIAL_REQUEST"},

            # KYC & Bank Impersonation
            "kyc": {"weight": 15, "domain": "FINANCIAL", "scam_type": "KYC_SCAM", "category": "KYC Scam", "behavior": "IDENTITY_REQUEST"},
            "update kyc": {"weight": 30, "domain": "FINANCIAL", "scam_type": "KYC_SCAM", "category": "KYC Scam", "behavior": "IDENTITY_REQUEST"},
            "kyc expired": {"weight": 35, "domain": "FINANCIAL", "scam_type": "KYC_SCAM", "category": "KYC Scam", "behavior": "THREAT"},
            "bank manager of sbi": {"weight": 40, "domain": "FINANCIAL", "scam_type": "BANKING_SCAM", "category": "Bank Impersonation", "behavior": "AUTHORITY_PRESSURE"},
            "ur debit card is about to expire": {"weight": 40, "domain": "FINANCIAL", "scam_type": "BANKING_SCAM", "category": "Bank Impersonation", "behavior": "THREAT"},
            "debit card expire": {"weight": 35, "domain": "FINANCIAL", "scam_type": "BANKING_SCAM", "category": "Bank Impersonation", "behavior": "THREAT"},
            "issue new card": {"weight": 25, "domain": "FINANCIAL", "scam_type": "BANKING_SCAM", "category": "Bank Impersonation", "behavior": "MANIPULATION"},

            # Legal & Digital Arrest
            "digital arrest": {"weight": 50, "domain": "LEGAL", "scam_type": "DIGITAL_ARREST", "category": "Police Impersonation", "behavior": "THREAT"},
            "arrest warrant": {"weight": 40, "domain": "LEGAL", "scam_type": "DIGITAL_ARREST", "category": "Police Impersonation", "behavior": "THREAT"},
            "legal action": {"weight": 40, "domain": "LEGAL", "scam_type": "LEGAL_SCAM", "category": "Legal Threat", "behavior": "THREAT"},
            "seized": {"weight": 30, "domain": "LEGAL", "scam_type": "LEGAL_SCAM", "category": "Legal Threat", "behavior": "THREAT"},
            "fir": {"weight": 30, "domain": "LEGAL", "scam_type": "LEGAL_SCAM", "category": "Legal Threat", "behavior": "THREAT"},
            "cyber crime": {"weight": 35, "domain": "LEGAL", "scam_type": "POLICE_IMPERSONATION", "category": "Police Impersonation", "behavior": "AUTHORITY_PRESSURE"},

            # Medical Emergency
            "blood needed": {"weight": 30, "domain": "MEDICAL", "scam_type": "MEDICAL_EMERGENCY", "category": "Medical Emergency", "behavior": "EMERGENCY_CLAIM"},
            "accident": {"weight": 25, "domain": "MEDICAL", "scam_type": "MEDICAL_EMERGENCY", "category": "Medical Emergency", "behavior": "EMERGENCY_CLAIM"},
            "emergency treatment": {"weight": 35, "domain": "MEDICAL", "scam_type": "MEDICAL_EMERGENCY", "category": "Medical Emergency", "behavior": "EMERGENCY_CLAIM"},
            "relative in hospital": {"weight": 35, "domain": "MEDICAL", "scam_type": "MEDICAL_EMERGENCY", "category": "Medical Emergency", "behavior": "EMERGENCY_CLAIM"},

            # Remote Access & Malware
            "screen sharing": {"weight": 40, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "REMOTE_ACCESS_REQUEST"},
            "remote access": {"weight": 40, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "REMOTE_ACCESS_REQUEST"},
            "anydesk": {"weight": 40, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "REMOTE_ACCESS_REQUEST"},
            "teamviewer": {"weight": 40, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "REMOTE_ACCESS_REQUEST"},
            "quicksupport": {"weight": 35, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "REMOTE_ACCESS_REQUEST"},
            "install app": {"weight": 25, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "LINK_REQUEST"},
            "apk": {"weight": 30, "domain": "CYBER", "scam_type": "MALWARE", "category": "Remote Access", "behavior": "LINK_REQUEST"},

            # Payment Requests & Wallet Lures
            "pay the fine": {"weight": 30, "domain": "FINANCIAL", "scam_type": "PAYMENT_SCAM", "category": "Payment Scam", "behavior": "PAYMENT_REQUEST"},
            "send money": {"weight": 30, "domain": "FINANCIAL", "scam_type": "PAYMENT_SCAM", "category": "Payment Scam", "behavior": "PAYMENT_REQUEST"},
            "transfer money": {"weight": 30, "domain": "FINANCIAL", "scam_type": "PAYMENT_SCAM", "category": "Payment Scam", "behavior": "PAYMENT_REQUEST"},
            "upi": {"weight": 20, "domain": "FINANCIAL", "scam_type": "UPI_SCAM", "category": "Payment Scam", "behavior": "PAYMENT_REQUEST"},
            "added to your wallet": {"weight": 40, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Wallet Phishing", "behavior": "MANIPULATION"},
            "bonus is credited": {"weight": 35, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Wallet Phishing", "behavior": "MANIPULATION"},
            "directly withdraw now": {"weight": 45, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Wallet Phishing", "behavior": "MANIPULATION"},
            "move to your bank a/c": {"weight": 40, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Wallet Phishing", "behavior": "MANIPULATION"},
            "instantly withdraw": {"weight": 40, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Wallet Phishing", "behavior": "MANIPULATION"},
            "visitor id": {"weight": 25, "domain": "FINANCIAL", "scam_type": "PHISHING", "category": "Loan/Wallet Phishing", "behavior": "MANIPULATION"},

            # Luxury Prize & Parcel Lottery
            "winning parcel": {"weight": 45, "domain": "DELIVERY", "scam_type": "DELIVERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "apple usa": {"weight": 35, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "1 crore rupees": {"weight": 40, "domain": "FINANCIAL", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "iphone 15": {"weight": 35, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "re-verification form": {"weight": 35, "domain": "CYBER", "scam_type": "PHISHING", "category": "Lottery Scam", "behavior": "IDENTITY_REQUEST"},
            "selected to receive a award": {"weight": 40, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "jio prize": {"weight": 35, "domain": "TELECOM", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "lucky draw": {"weight": 35, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "lottery": {"weight": 25, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},
            "prize": {"weight": 20, "domain": "OTHER", "scam_type": "LOTTERY_SCAM", "category": "Lottery Scam", "behavior": "MANIPULATION"},

            # Fake Part-time Jobs & Employment
            "part-time jobs": {"weight": 35, "domain": "EMPLOYMENT", "scam_type": "JOB_SCAM", "category": "Job Scam", "behavior": "MANIPULATION"},
            "earn 1000-3000": {"weight": 40, "domain": "EMPLOYMENT", "scam_type": "JOB_SCAM", "category": "Job Scam", "behavior": "MANIPULATION"},
            "earn 8000-20000": {"weight": 40, "domain": "EMPLOYMENT", "scam_type": "JOB_SCAM", "category": "Job Scam", "behavior": "MANIPULATION"},
            "daily salary": {"weight": 30, "domain": "EMPLOYMENT", "scam_type": "JOB_SCAM", "category": "Job Scam", "behavior": "MANIPULATION"},
            "work online without investment": {"weight": 35, "domain": "EMPLOYMENT", "scam_type": "JOB_SCAM", "category": "Job Scam", "behavior": "MANIPULATION"},

            # Predatory Loans & Gambling
            "loan is approve": {"weight": 35, "domain": "FINANCIAL", "scam_type": "INVESTMENT_SCAM", "category": "Loan Scam", "behavior": "MANIPULATION"},
            "zero documentation": {"weight": 30, "domain": "FINANCIAL", "scam_type": "INVESTMENT_SCAM", "category": "Loan Scam", "behavior": "MANIPULATION"},
            "fast loans": {"weight": 25, "domain": "FINANCIAL", "scam_type": "INVESTMENT_SCAM", "category": "Loan Scam", "behavior": "MANIPULATION"},
            "junglee rummy": {"weight": 30, "domain": "OTHER", "scam_type": "PHISHING", "category": "Gambling Phishing", "behavior": "MANIPULATION"},
            "welcome bonus": {"weight": 25, "domain": "OTHER", "scam_type": "PHISHING", "category": "Gambling Phishing", "behavior": "MANIPULATION"},
            "special5500": {"weight": 30, "domain": "OTHER", "scam_type": "PHISHING", "category": "Gambling Phishing", "behavior": "MANIPULATION"},

            # Behavioral Urgency & Threat
            "urgent": {"weight": 15, "behavior": "URGENCY", "category": "Urgency"},
            "immediately": {"weight": 15, "behavior": "URGENCY", "category": "Urgency"},
            "account blocked": {"weight": 30, "behavior": "THREAT", "category": "Urgency"},
            "account block": {"weight": 25, "behavior": "THREAT", "category": "Urgency"},
            "suspend": {"weight": 20, "behavior": "THREAT", "category": "Urgency"},
            "secret": {"weight": 20, "behavior": "SECRECY", "category": "Manipulation"},
            "don't tell anyone": {"weight": 30, "behavior": "ISOLATION", "category": "Manipulation"},
            "trai disconnection": {"weight": 35, "domain": "TELECOM", "scam_type": "GOVERNMENT_IMPERSONATION", "category": "Government Impersonation", "behavior": "THREAT"},
            "electricity cut": {"weight": 35, "domain": "OTHER", "scam_type": "TECH_SUPPORT_SCAM", "category": "Utility Scam", "behavior": "THREAT"},

            # Multilingual
            "பணம்": {"weight": 20, "domain": "FINANCIAL", "scam_type": "PAYMENT_SCAM", "category": "Payment Scam", "behavior": "PAYMENT_REQUEST"},
            "வங்கி": {"weight": 10, "domain": "FINANCIAL", "category": "Bank Impersonation", "type": "DOMAIN_MARKER"},
            "கணக்கு முடக்கம்": {"weight": 25, "category": "Urgency", "behavior": "THREAT"},
            "sollunga": {"weight": 10, "category": "Request Direction", "behavior": "REQUEST"},
            "pannunga": {"weight": 10, "category": "Request Direction", "behavior": "REQUEST"},
            "turant": {"weight": 15, "category": "Urgency", "behavior": "URGENCY"},
            "khata block": {"weight": 30, "domain": "FINANCIAL", "category": "Urgency", "behavior": "THREAT"},
        }

    def _deobfuscate(self, text: str) -> str:
        res = text
        res = re.sub(r'\bt0\b', 'to', res, flags=re.I)
        res = re.sub(r'\b0n\b', 'on', res, flags=re.I)
        res = re.sub(r'\bB0nus\b', 'Bonus', res, flags=re.I)
        res = re.sub(r'\bY0u\b', 'You', res, flags=re.I)
        res = re.sub(r'\bY0ur\b', 'Your', res, flags=re.I)
        res = re.sub(r'\bL0an\b', 'Loan', res, flags=re.I)
        res = re.sub(r'\bN0\b', 'No', res, flags=re.I)
        res = re.sub(r'(Rs\.?|INR|₹|\b)(\d+[, ]*[O0]{2,6})\b', lambda m: m.group(1) + m.group(2).replace('O', '0').replace('o', '0'), res, flags=re.I)
        return res

    def analyze_text(self, text: str) -> dict:
        deobf = self._deobfuscate(text or "")
        text_lower = deobf.lower()
        detected = []
        domains = set()
        scam_types = set()
        behaviors = set()
        categories = set()
        total_weight = 0

        for keyword, data in self.keywords.items():
            if keyword in text_lower:
                detected.append(keyword)
                total_weight += data["weight"]
                if "domain" in data:
                    domains.add(data["domain"])
                if "scam_type" in data:
                    scam_types.add(data["scam_type"])
                if "category" in data:
                    categories.add(data["category"])
                if "behavior" in data:
                    behaviors.add(data["behavior"])

        return {
            "keywords_detected": detected,
            "domains": list(domains),
            "scam_types": list(scam_types),
            "behaviors": list(behaviors),
            "categories": list(categories),
            "keyword_weight": min(100, total_weight)
        }

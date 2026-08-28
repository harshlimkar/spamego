import re

class KeywordEngine:
    def __init__(self):
        self.keywords = {
            # Credential & OTP Theft
            "otp": {"weight": 25, "category": "Credential Theft"},
            "pin": {"weight": 30, "category": "Credential Theft"},
            "password": {"weight": 25, "category": "Credential Theft"},
            "cvv": {"weight": 30, "category": "Credential Theft"},
            "share otp": {"weight": 40, "category": "Credential Theft"},
            "tell me the otp": {"weight": 45, "category": "Credential Theft"},
            "tell otp": {"weight": 40, "category": "Credential Theft"},
            "otp batao": {"weight": 40, "category": "Credential Theft"},
            "otp dijiye": {"weight": 40, "category": "Credential Theft"},
            
            # KYC & Bank Impersonation
            "kyc": {"weight": 20, "category": "KYC Scam"},
            "update kyc": {"weight": 30, "category": "KYC Scam"},
            "kyc expired": {"weight": 35, "category": "KYC Scam"},
            "bank manager of sbi": {"weight": 40, "category": "Bank Impersonation"},
            "ur debit card is about to expire": {"weight": 40, "category": "Bank Impersonation"},
            "debit card expire": {"weight": 35, "category": "Bank Impersonation"},
            "issue new card": {"weight": 25, "category": "Bank Impersonation"},
            
            # Direct Wallet Credit / Withdrawal Lures
            "added to your wallet": {"weight": 40, "category": "Wallet Phishing"},
            "bonus is credited": {"weight": 35, "category": "Wallet Phishing"},
            "directly withdraw now": {"weight": 45, "category": "Wallet Phishing"},
            "move to your bank a/c": {"weight": 40, "category": "Wallet Phishing"},
            "instantly withdraw": {"weight": 40, "category": "Wallet Phishing"},
            "visitor id": {"weight": 25, "category": "Loan/Wallet Phishing"},
            
            # Luxury Prize & Parcel Lottery
            "winning parcel": {"weight": 45, "category": "Lottery Scam"},
            "apple usa": {"weight": 35, "category": "Lottery Scam"},
            "1 crore rupees": {"weight": 40, "category": "Lottery Scam"},
            "iphone 15": {"weight": 35, "category": "Lottery Scam"},
            "re-verification form": {"weight": 35, "category": "Lottery Scam"},
            "selected to receive a award": {"weight": 40, "category": "Lottery Scam"},
            "jio prize": {"weight": 35, "category": "Lottery Scam"},
            "lucky draw": {"weight": 35, "category": "Lottery Scam"},
            "prize": {"weight": 20, "category": "Lottery Scam"},
            "lottery": {"weight": 25, "category": "Lottery Scam"},
            
            # Fake Part-time Jobs
            "part-time jobs": {"weight": 35, "category": "Job Scam"},
            "earn 1000-3000": {"weight": 40, "category": "Job Scam"},
            "earn 8000-20000": {"weight": 40, "category": "Job Scam"},
            "daily salary": {"weight": 30, "category": "Job Scam"},
            "work online without investment": {"weight": 35, "category": "Job Scam"},
            
            # Predatory Loans & Rummy Bonuses
            "loan is approve": {"weight": 35, "category": "Loan Scam"},
            "zero documentation": {"weight": 30, "category": "Loan Scam"},
            "fast loans": {"weight": 25, "category": "Loan Scam"},
            "junglee rummy": {"weight": 30, "category": "Gambling Phishing"},
            "welcome bonus": {"weight": 25, "category": "Gambling Phishing"},
            "special5500": {"weight": 30, "category": "Gambling Phishing"},
            
            # Urgency & Panic
            "urgent": {"weight": 15, "category": "Urgency"},
            "immediately": {"weight": 15, "category": "Urgency"},
            "account blocked": {"weight": 30, "category": "Urgency"},
            "account block": {"weight": 25, "category": "Urgency"},
            "police": {"weight": 20, "category": "Police Impersonation"},
            "digital arrest": {"weight": 40, "category": "Police Impersonation"},
            "rbi": {"weight": 15, "category": "Government Impersonation"},
            "trai disconnection": {"weight": 35, "category": "Government Impersonation"},
            "electricity cut": {"weight": 35, "category": "Utility Scam"},
            
            # Remote Access & Malware
            "screen sharing": {"weight": 35, "category": "Remote Access"},
            "remote access": {"weight": 40, "category": "Remote Access"},
            "anydesk": {"weight": 40, "category": "Remote Access"},
            "teamviewer": {"weight": 40, "category": "Remote Access"},
            "quicksupport": {"weight": 35, "category": "Remote Access"},
            "install app": {"weight": 25, "category": "Remote Access"},
            "apk": {"weight": 25, "category": "Remote Access"},
            
            # Multilingual
            "பணம்": {"weight": 15, "category": "Payment Scam"},
            "வங்கி": {"weight": 10, "category": "Bank Impersonation"},
            "கணக்கு முடக்கம்": {"weight": 25, "category": "Urgency"},
            "sollunga": {"weight": 10, "category": "Request Direction"},
            "pannunga": {"weight": 10, "category": "Request Direction"},
            "turant": {"weight": 15, "category": "Urgency"},
            "khata block": {"weight": 30, "category": "Urgency"},
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

    def analyze_text(self, text: str):
        deobf = self._deobfuscate(text or "")
        text_lower = deobf.lower()
        detected = []
        categories = set()
        total_keyword_weight = 0

        for keyword, data in self.keywords.items():
            if keyword in text_lower:
                detected.append(keyword)
                categories.add(data["category"])
                total_keyword_weight += data["weight"]
        
        return {
            "keywords_detected": detected,
            "categories": list(categories),
            "keyword_weight": min(100, total_keyword_weight)
        }

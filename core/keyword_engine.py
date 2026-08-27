class KeywordEngine:
    def __init__(self):
        # In a real app, these would come from the database (keywords table)
        self.keywords = {
            "otp": {"weight": 25, "category": "Credential Theft"},
            "pin": {"weight": 30, "category": "Credential Theft"},
            "password": {"weight": 25, "category": "Credential Theft"},
            "cvv": {"weight": 30, "category": "Credential Theft"},
            "kyc": {"weight": 15, "category": "KYC Scam"},
            "verify": {"weight": 10, "category": "General"},
            "urgent": {"weight": 10, "category": "Urgency"},
            "immediately": {"weight": 10, "category": "Urgency"},
            "account blocked": {"weight": 20, "category": "Urgency"},
            "account block": {"weight": 20, "category": "Urgency"},
            "bank": {"weight": 5, "category": "Bank Impersonation"},
            "police": {"weight": 20, "category": "Police Impersonation"},
            "rbi": {"weight": 15, "category": "Government Impersonation"},
            "refund": {"weight": 15, "category": "Payment Scam"},
            "prize": {"weight": 20, "category": "Lottery Scam"},
            "lottery": {"weight": 20, "category": "Lottery Scam"},
            "investment": {"weight": 15, "category": "Investment Scam"},
            "upi": {"weight": 20, "category": "Payment Scam"},
            "qr": {"weight": 20, "category": "Payment Scam"},
            "payment": {"weight": 15, "category": "Payment Scam"},
            "send money": {"weight": 25, "category": "Payment Scam"},
            "screen sharing": {"weight": 30, "category": "Remote Access"},
            "remote access": {"weight": 35, "category": "Remote Access"},
            "install app": {"weight": 25, "category": "Remote Access"},
            "apk": {"weight": 25, "category": "Remote Access"},
            
            # Tamil / Mixed
            "பணம்": {"weight": 15, "category": "Payment Scam"},
            "வங்கி": {"weight": 5, "category": "Bank Impersonation"},
            "கணக்கு முடக்கம்": {"weight": 20, "category": "Urgency"},
            "sollunga": {"weight": 5, "category": "Request Direction"},
            "pannunga": {"weight": 5, "category": "Request Direction"}
        }

    def analyze_text(self, text):
        text_lower = text.lower()
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
            "keyword_weight": total_keyword_weight
        }

from database.repository import NumberRepository

class VerificationEngine:
    def __init__(self):
        self.repository = NumberRepository()

    def verify_number(self, phone_number):
        if not phone_number:
            return {"status": "UNKNOWN", "details": None, "risk_modifier": 0}
            
        result = self.repository.check_number(phone_number)
        status = result["status"]
        
        risk_modifier = 0
        
        if status == "VERIFIED_OFFICIAL":
            # If it's official, it heavily reduces risk
            risk_modifier = -50 
        elif status == "TRUSTED_CONTACT":
            # If it's family, it reduces risk
            risk_modifier = -50
        elif status == "REPORTED_SCAM":
            # If it's a known scammer, it increases risk heavily
            risk_modifier = 30
        else: # UNKNOWN or UNVERIFIED
            # Unknown numbers inherently carry a tiny bit of suspicion but aren't scams by themselves
            risk_modifier = 10 
            
        result["risk_modifier"] = risk_modifier
        return result

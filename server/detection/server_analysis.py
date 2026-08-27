class ServerAnalysis:
    @staticmethod
    def calculate_risk(number_status, categories_str):
        categories = categories_str.split(",") if categories_str else []
        
        base_score = 0
        
        if number_status == "VERIFIED_OFFICIAL":
            base_score = 10
            level = "SAFE"
        elif number_status == "REPORTED_SCAM":
            base_score = 80
            level = "CRITICAL"
        else:
            base_score = 30
            level = "MEDIUM"
            
        # Contextual bumps based on categories
        if "Credential Theft" in categories or "OTP" in categories_str.upper():
            base_score += 20
        if "Urgency" in categories:
            base_score += 10
            
        final_score = min(100, base_score)
        
        if final_score >= 85: level = "CRITICAL"
        elif final_score >= 70: level = "HIGH"
        elif final_score >= 50: level = "MEDIUM"
        elif final_score >= 30: level = "LOW"
        else: level = "SAFE"
        
        return {
            "score": final_score,
            "level": level
        }

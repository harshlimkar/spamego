class RiskEngine:
    def calculate_risk(self, keyword_weight, rule_score, verification_modifier):
        # Base calculation
        total_risk = keyword_weight + rule_score + verification_modifier
        
        # Clamp to 0-100 range
        total_risk = max(0, min(100, total_risk))
        
        # Determine Level
        level = "SAFE"
        if total_risk >= 85:
            level = "CRITICAL"
        elif total_risk >= 70:
            level = "HIGH"
        elif total_risk >= 50:
            level = "MEDIUM"
        elif total_risk >= 30:
            level = "LOW"
            
        return {
            "score": total_risk,
            "level": level
        }

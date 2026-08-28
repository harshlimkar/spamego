from risk_scoring.risk_engine import RiskEngine

class RiskManager:
    def __init__(self):
        self.engine = RiskEngine()

    def evaluate_event_risk(self, keyword_weight, rule_score, verification_modifier, source="UNKNOWN"):
        """
        Evaluates the risk for a given event, regardless of source (SMS, CALL, etc.).
        Can be extended later to apply source-specific weighting.
        """
        # Right now we just pass through to the base engine, but this centralized manager
        # allows us to apply source-specific adjustments in the future.
        risk_result = self.engine.calculate_risk(
            keyword_weight, 
            rule_score, 
            verification_modifier
        )
        
        # Example of how source could influence the result (currently no-op)
        if source == "SMS":
            pass
        elif source == "CALL":
            pass
            
        return risk_result

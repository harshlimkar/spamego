from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.verification_engine import VerificationEngine
from core.risk_engine import RiskEngine
from core.campaign_engine import CampaignEngine

class CallProvider:
    def get_caller_id(self):
        raise NotImplementedError
    def get_call_speech(self):
        raise NotImplementedError

class DemoCallProvider(CallProvider):
    def __init__(self, caller_id, transcript):
        self.caller_id = caller_id
        self.transcript = transcript

    def get_caller_id(self):
        return self.caller_id

    def get_call_speech(self):
        return self.transcript

class CallProcessor:
    def __init__(self):
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.verification_engine = VerificationEngine()
        self.risk_engine = RiskEngine()
        self.campaign_engine = CampaignEngine()

    def process_call(self, call_provider: CallProvider):
        caller_number = call_provider.get_caller_id()
        speech_text = call_provider.get_call_speech()
        
        # Analyze speech as if it were SMS text
        kw_result = self.keyword_engine.analyze_text(speech_text)
        rule_result = self.rule_engine.evaluate_rules(kw_result["categories"], kw_result["keywords_detected"])
        ver_result = self.verification_engine.verify_number(caller_number)
        
        risk_result = self.risk_engine.calculate_risk(
            kw_result["keyword_weight"], 
            rule_result["rule_risk_score"], 
            ver_result["risk_modifier"]
        )

        camp_result = self.campaign_engine.process_event(
            caller_number, 
            risk_result, 
            kw_result["categories"], 
            "CALL", 
            speech_text
        )

        return {
            "caller_number": caller_number,
            "caller_status": ver_result["status"],
            "speech_analyzed": speech_text,
            "final_risk_score": camp_result["campaign_risk_score"],
            "final_risk_level": camp_result["campaign_risk_level"],
            "campaign_id": camp_result["campaign_id"],
            "categories": kw_result["categories"]
        }

from sms.sms_normalizer import SMSNormalizer
from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.verification_engine import VerificationEngine
from core.risk_engine import RiskEngine
from core.campaign_engine import CampaignEngine
import datetime

class SMSProcessor:
    def __init__(self):
        self.normalizer = SMSNormalizer()
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.verification_engine = VerificationEngine()
        self.risk_engine = RiskEngine()
        self.campaign_engine = CampaignEngine()

    def process(self, sender_number, text):
        # 1. Normalize
        norm_result = self.normalizer.normalize(text)
        clean_text = norm_result["normalized"]

        # 2. Extract Keywords
        kw_result = self.keyword_engine.analyze_text(clean_text)

        # 3. Apply Rules
        rule_result = self.rule_engine.evaluate_rules(kw_result["categories"], kw_result["keywords_detected"])

        # 4. Verify Sender
        ver_result = self.verification_engine.verify_number(sender_number)

        # 5. Calculate Risk
        risk_result = self.risk_engine.calculate_risk(
            kw_result["keyword_weight"], 
            rule_result["rule_risk_score"], 
            ver_result["risk_modifier"]
        )

        # 6. Update Campaign
        camp_result = self.campaign_engine.process_event(
            sender_number, 
            risk_result, 
            kw_result["categories"], 
            "SMS", 
            text
        )

        # Build final response
        return {
            "sender_number": sender_number,
            "timestamp": datetime.datetime.now().isoformat(),
            "message_text": text,
            "detected_language": norm_result["detected_language"],
            "detected_keywords": kw_result["keywords_detected"],
            "categories": kw_result["categories"],
            "sender_status": ver_result["status"],
            "event_risk_score": risk_result["score"],
            "event_risk_level": risk_result["level"],
            "campaign_id": camp_result["campaign_id"],
            "final_risk_score": camp_result["campaign_risk_score"],
            "final_risk_level": camp_result["campaign_risk_level"]
        }

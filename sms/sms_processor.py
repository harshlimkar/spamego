from sms.sms_normalizer import SMSNormalizer
from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.verification_engine import VerificationEngine
from core.risk_engine import RiskEngine
from core.campaign_engine import CampaignEngine
from core.remote_client import RemoteIntelligenceClient
from database.repository import NumberRepository
import datetime

class SMSProcessor:
    def __init__(self):
        self.normalizer = SMSNormalizer()
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.verification_engine = VerificationEngine()
        self.risk_engine = RiskEngine()
        self.campaign_engine = CampaignEngine()
        self.remote_client = RemoteIntelligenceClient()

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

        # 5. Calculate Local Risk
        risk_result = self.risk_engine.calculate_risk(
            kw_result["keyword_weight"], 
            rule_result["rule_risk_score"], 
            ver_result["risk_modifier"]
        )

        # Phase 10: Automatic Remote Query
        if ver_result["status"] in ["UNKNOWN", "UNVERIFIED"] and risk_result["level"] in ["MEDIUM", "HIGH"]:
            print(f"\n[LOCAL ENGINE] Number {sender_number} is UNKNOWN and risk is {risk_result['level']}. Querying remote intelligence...")
            remote_res = self.remote_client.query_server(sender_number, kw_result["categories"])
            
            if remote_res:
                # Override local results with remote response
                print(f"[REMOTE ENGINE] Remote analysis complete. Updating local risk...")
                ver_result["status"] = remote_res["number_status"]
                
                # Combine local and remote risk scores (or trust remote if it's high)
                new_score = max(risk_result["score"], remote_res["risk_score"])
                
                # Re-calculate level
                new_level = "SAFE"
                if new_score >= 85: new_level = "CRITICAL"
                elif new_score >= 70: new_level = "HIGH"
                elif new_score >= 50: new_level = "MEDIUM"
                elif new_score >= 30: new_level = "LOW"

                risk_result["score"] = new_score
                risk_result["level"] = new_level
                
                # Phase 12: Add local caching
                NumberRepository.cache_remote_result(sender_number, ver_result["status"], remote_res["category"])
                print("[LOCAL ENGINE] Remote result cached locally for future use.")
            else:
                print("[LOCAL ENGINE] Remote query failed or timed out. Proceeding with local risk.")

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

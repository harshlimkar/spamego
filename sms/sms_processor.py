from sms.sms_normalizer import SMSNormalizer
from sms.sms_normalizer import SMSNormalizer
from core.universal_engine import UniversalScamEngine
from core.models import NormalizedMessage
from core.verification_engine import VerificationEngine
from core.campaign_engine import CampaignEngine
from core.remote_client import RemoteIntelligenceClient
from database.repository import NumberRepository
import datetime

class SMSProcessor:
    def __init__(self):
        self.normalizer = SMSNormalizer()
        self.universal_engine = UniversalScamEngine()
        self.verification_engine = VerificationEngine()
        self.campaign_engine = CampaignEngine()
        self.remote_client = RemoteIntelligenceClient()

    def process(self, sender_number, text):
        # 1. Normalize Text
        norm_result = self.normalizer.normalize(text)
        clean_text = norm_result["normalized"]

        # 2. Convert to NormalizedMessage
        norm_msg = NormalizedMessage(
            source="SMS",
            sender=sender_number,
            message=clean_text,
            timestamp=datetime.datetime.now().isoformat()
        )

        # 3. Analyze via Universal Engine
        analysis_result = self.universal_engine.analyze(norm_msg)

        # 4. Verify Sender
        ver_result = self.verification_engine.verify_number(sender_number)

        # 5. Local Risk adjustments (Verification impact)
        final_score = analysis_result.risk_score
        if ver_result["risk_modifier"] > 0:
            final_score = min(100, final_score + ver_result["risk_modifier"])
            if final_score >= 85: analysis_result.risk_level = "CRITICAL"
            elif final_score >= 60: analysis_result.risk_level = "HIGH"

        # Phase 10: Automatic Remote Query (optional offline mode)
        if ver_result["status"] in ["UNKNOWN", "UNVERIFIED"] and analysis_result.risk_level in ["MEDIUM", "HIGH", "CRITICAL"]:
            print(f"\n[LOCAL ENGINE] Number {sender_number} is {ver_result['status']} and risk is {analysis_result.risk_level}. Querying remote intelligence...")
            # Querying the remote Universal Engine endpoint
            remote_res = self.remote_client.query_server(sender_number, analysis_result.domains)
            
            if remote_res:
                print(f"[REMOTE ENGINE] Remote analysis complete. Updating local risk...")
                ver_result["status"] = remote_res["number_status"]
                
                new_score = max(final_score, remote_res["risk_score"])
                
                new_level = "SAFE"
                if new_score >= 85: new_level = "CRITICAL"
                elif new_score >= 70: new_level = "HIGH"
                elif new_score >= 50: new_level = "MEDIUM"
                elif new_score >= 30: new_level = "LOW"

                final_score = new_score
                analysis_result.risk_level = new_level
                
                NumberRepository.cache_remote_result(sender_number, ver_result["status"], remote_res.get("category", ""))
                print("[LOCAL ENGINE] Remote result cached locally for future use.")
            else:
                print("[LOCAL ENGINE] Remote query failed or timed out. Proceeding with local risk.")

        # 6. Update Campaign
        risk_result_dict = {"score": final_score, "level": analysis_result.risk_level}
        camp_result = self.campaign_engine.process_event(
            sender_number, 
            risk_result_dict, 
            analysis_result.domains, 
            "SMS", 
            text
        )

        # Build final response combining analysis and context
        return {
            "sender_number": sender_number,
            "timestamp": norm_msg.timestamp,
            "message_text": text,
            "detected_language": norm_result["detected_language"],
            "analysis": analysis_result.dict(),
            "sender_status": ver_result["status"],
            "event_risk_score": final_score,
            "event_risk_level": analysis_result.risk_level,
            "campaign_id": camp_result["campaign_id"],
            "final_risk_score": camp_result["campaign_risk_score"],
            "final_risk_level": camp_result["campaign_risk_level"]
        }

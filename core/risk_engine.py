from core.models import ScamAnalysisResult, RiskLevel, NormalizedMessage

class UniversalRiskEngine:
    def calculate_risk(self, kw_result, rule_result, context_data, message: NormalizedMessage) -> ScamAnalysisResult:
        base_score = min(100, kw_result.get("keyword_weight", 0) + rule_result.get("rule_risk_score", 0))
        
        behaviors = kw_result.get("behaviors", [])
        domains = kw_result.get("domains", [])
        scam_types = kw_result.get("scam_types", [])
        
        # Requests
        payment_req = "PAYMENT_REQUEST" in behaviors or "₹" in message.message or "rs" in message.message.lower()
        cred_req = "CREDENTIAL_REQUEST" in behaviors
        link_req = "LINK_REQUEST" in behaviors or "http" in message.message.lower()
        has_urgency = "URGENCY" in behaviors or "THREAT" in behaviors or "EMERGENCY_CLAIM" in behaviors

        # False positive suppression for benign messages with simple domain markers
        # e.g., "Your hospital appointment is scheduled tomorrow" or "Rs 2000 debited from your account"
        if not payment_req and not cred_req and not has_urgency and not rule_result.get("triggered_rules"):
            base_score = min(base_score, 15)

        # Determine risk level
        level = RiskLevel.SAFE
        if base_score >= 80:
            level = RiskLevel.CRITICAL
        elif base_score >= 60:
            level = RiskLevel.HIGH
        elif base_score >= 40:
            level = RiskLevel.MEDIUM
        elif base_score >= 20:
            level = RiskLevel.LOW
            
        impersonation = False
        impersonated_entity = None
        if "LEGAL" in domains:
            impersonation = True
            impersonated_entity = "Law Enforcement/Police/CBI/Court"
        elif "MEDICAL" in domains and (payment_req or has_urgency):
            impersonation = True
            impersonated_entity = "Hospital/Doctor Emergency"
        elif "DELIVERY" in domains and (payment_req or cred_req or has_urgency):
            impersonation = True
            impersonated_entity = "Courier/FedEx/Customs"
        elif "FINANCIAL" in domains and (payment_req or cred_req or has_urgency):
            impersonation = True
            impersonated_entity = "Bank/Financial Institution"
        elif "EMPLOYMENT" in domains and (payment_req or has_urgency):
            impersonation = True
            impersonated_entity = "HR/Recruitment Agency"
            
        # Explanations
        reasons = []
        if impersonation:
            reasons.append(f"Possible impersonation of {impersonated_entity}.")
        if payment_req:
            reasons.append("Urgent payment or monetary transfer requested.")
        if cred_req:
            reasons.append("Sensitive credentials (OTP/PIN/Password) requested.")
        if "THREAT" in behaviors:
            reasons.append("Coercive threats or legal arrest pressure detected.")
        if "EMERGENCY_CLAIM" in behaviors:
            reasons.append("Fabricated medical or personal emergency claim.")
        if rule_result.get("triggered_rules"):
            reasons.append(f"Behavioral rules triggered: {', '.join(rule_result['triggered_rules'])}")
        
        # Awareness Message
        awareness = ""
        if "DIGITAL_ARREST" in scam_types or "LEGAL" in domains:
            awareness = "Law enforcement and government agencies NEVER conduct 'digital arrests' or demand money over calls/messages."
        elif "MEDICAL_EMERGENCY" in scam_types or "MEDICAL" in domains:
            awareness = "Verify emergency claims directly with the hospital or family member via a verified phone number."
        elif "OTP_SCAM" in scam_types or cred_req:
            awareness = "Never share OTP, PIN, CVV or banking passwords with anyone under any circumstances."
        elif "JOB_SCAM" in scam_types or "EMPLOYMENT" in domains:
            awareness = "Legitimate companies never require payments or deposits for remote part-time jobs."
        else:
            if level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
                awareness = "This message exhibits high-risk manipulative behavior. Do not engage."

        # Recommended Action
        action = "NONE"
        if level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            action = "DO NOT PAY. DO NOT SHARE OTP. DO NOT CLICK LINKS. VERIFY INDEPENDENTLY."
        elif level == RiskLevel.MEDIUM:
            action = "VERIFY SENDER BEFORE PROCEEDING. DO NOT CLICK UNVERIFIED LINKS."

        return ScamAnalysisResult(
            risk_score=base_score,
            risk_level=level,
            domains=domains,
            scam_types=scam_types,
            impersonation_detected=impersonation,
            impersonated_entity=impersonated_entity,
            behavioral_signals=behaviors,
            payment_request=payment_req,
            credential_request=cred_req,
            suspicious_link=link_req,
            reasons=reasons,
            recommended_action=action,
            awareness_message=awareness
        )

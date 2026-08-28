from core.models import ScamAnalysisResult, RiskLevel, NormalizedMessage

class UniversalRiskEngine:
    def calculate_risk(self, kw_result, rule_result, context_data, message: NormalizedMessage) -> ScamAnalysisResult:
        base_score = min(100, kw_result["keyword_weight"] + rule_result["rule_risk_score"])
        
        # Determine risk level
        level = RiskLevel.SAFE
        if base_score >= 85:
            level = RiskLevel.CRITICAL
        elif base_score >= 60:
            level = RiskLevel.HIGH
        elif base_score >= 40:
            level = RiskLevel.MEDIUM
        elif base_score >= 20:
            level = RiskLevel.LOW
            
        behaviors = kw_result["behaviors"]
        domains = kw_result["domains"]
        scam_types = kw_result["scam_types"]
        
        impersonation = False
        impersonated_entity = None
        if "LEGAL" in domains:
            impersonation = True
            impersonated_entity = "Law Enforcement/Gov"
        elif "MEDICAL" in domains:
            impersonation = True
            impersonated_entity = "Hospital/Medical"
        elif "DELIVERY" in domains:
            impersonation = True
            impersonated_entity = "Courier/Customs"
        elif "FINANCIAL" in domains:
            impersonation = True
            impersonated_entity = "Bank/Financial Institution"
            
        # Requests
        payment_req = "PAYMENT_REQUEST" in behaviors
        cred_req = "CREDENTIAL_REQUEST" in behaviors
        link_req = "LINK_REQUEST" in behaviors
        
        # Explanation
        reasons = []
        if impersonation: reasons.append(f"Possible impersonation of {impersonated_entity}.")
        if payment_req: reasons.append("Urgent payment requested.")
        if cred_req: reasons.append("Sensitive credentials requested.")
        if rule_result["triggered_rules"]: reasons.append(f"Behavioral rules triggered: {', '.join(rule_result['triggered_rules'])}")
        
        # Awareness Message
        awareness = ""
        if "DIGITAL_ARREST" in scam_types:
            awareness = "Government agencies do not demand money to avoid arrest. Verify independently."
        elif "MEDICAL_EMERGENCY" in scam_types:
            awareness = "Verify emergency claims directly with the hospital or family member."
        elif "OTP_SCAM" in scam_types or "PHISHING" in scam_types:
            awareness = "Never share OTP, PIN, CVV or passwords."
        else:
            if level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
                awareness = "This message exhibits high-risk manipulative behavior. Do not engage."

        # Action
        action = ""
        if level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            action = "DO NOT PAY. DO NOT SHARE OTP. DO NOT CLICK LINKS. VERIFY INDEPENDENTLY."

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

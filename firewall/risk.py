import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from .schema import RiskResult, RiskLevel

INTENT_POINTS = {
    "otp_disclosure": 28,
    "credential_phishing": 24,
    "remote_access": 24,
    "payment_request": 22,
    "threat_blackmail": 28,
    "otp_request": 18,
    "bank_impersonation": 14,
    "government_impersonation": 14,
    "family_emergency": 16,
    "kyc_verification": 12,
    "prize_lottery": 14,
    "investment": 14,
    "malware_link": 16,
    "delivery_request": 10,
    "information_phishing": 12,
    "loan_offer": 8,
    "marketing": 2,
    "notification": 0,
    "greeting": 0,
    "unknown": 0,
}

STAGE_POINTS = {
    "delivery": 2,
    "pretexting": 8,
    "urgency": 12,
    "isolation": 16,
    "credential_harvesting": 26,
    "exploitation": 30,
    "objective_completion": 34,
    "benign": 0,
}

ML_LABEL_POINTS = {"SAFE": 0, "SPAM": 18, "SCAM": 34, "UNKNOWN": 8, "ERROR": 8}


def clamp(v, lo=0, hi=100):
    return max(lo, min(hi, v))


def level_for_score(score):
    if score >= 85:
        return RiskLevel.CRITICAL.value
    if score >= 70:
        return RiskLevel.HIGH.value
    if score >= 50:
        return RiskLevel.MEDIUM.value
    if score >= 30:
        return RiskLevel.LOW.value
    return RiskLevel.SAFE.value


class UnifiedRiskEngine:
    def calculate(self, content_score, heuristic_score, edge_score, ml_label, ml_confidence, intents, stage, otp, verification, links, amounts):
        content = 0.5 * content_score + 0.5 * heuristic_score
        top_intent = intents[0].name if intents else "unknown"
        intent_pts = INTENT_POINTS.get(top_intent, 0)
        stage_pts = STAGE_POINTS.get(stage.stage, 0)
        otp_extra = 0
        if otp and otp.is_risky:
            otp_extra = 15
        elif otp and otp.context not in ("none", "received_legitimate_like"):
            otp_extra = 6
        link_extra = 0
        for link in links:
            if link["is_suspicious"]:
                link_extra += 12
            elif link["matches_trusted"]:
                link_extra -= 15
        link_extra = clamp(link_extra, -15, 20)
        amounts_extra = 0
        if amounts:
            amounts_extra = min(8, len(amounts) * 3)
        gross = 0.4 * content + intent_pts + stage_pts + otp_extra + link_extra + amounts_extra
        sender_mod = verification.risk_modifier if verification else 0
        score = clamp(round(gross + sender_mod))
        level = level_for_score(score)
        is_legit = verification is not None and verification.status in ("VERIFIED_OFFICIAL", "TRUSTED_CONTACT", "VERIFIED_SENDER_ID", "VERIFIED_DOMAIN")
        if is_legit and score > 40:
            score = clamp(score - 20)
            level = level_for_score(score)

        confidence = max(0.4, ml_confidence) if (intents and intents[0].confidence > 0.7) else max(0.4, ml_confidence, intents[0].confidence if intents else 0.5)

        factors = {
            "ml_score": clamp(round(content_score), 0, 100),
            "heuristic_score": clamp(round(heuristic_score), 0, 100),
            "edge_score": clamp(round(edge_score), 0, 100),
            "intent": top_intent,
            "intent_points": intent_pts,
            "stage": stage.stage,
            "stage_points": stage_pts,
            "otp_extra": otp_extra,
            "link_extra": link_extra,
            "amounts_extra": amounts_extra,
            "sender_modifier": sender_mod,
            "legitimate_signal": is_legit,
        }
        explanations = self._explain(top_intent, stage, otp, links, verification, amounts, level)
        return RiskResult(
            score=score,
            level=level,
            edge_score=clamp(round(edge_score), 0, 100),
            confidence=round(confidence, 3),
            is_legitimate_signal=is_legit,
            factors=factors,
            explanations=explanations,
        )

    def _explain(self, intent, stage, otp, links, verification, amounts, level):
        lines = []
        legit = verification is not None and verification.status in ("VERIFIED_OFFICIAL", "TRUSTED_CONTACT", "VERIFIED_SENDER_ID", "VERIFIED_DOMAIN")
        if legit:
            lines.append("The " + ("sender" if verification.status != "VERIFIED_DOMAIN" else "link") + " was verified against an official source.")
        if amounts and level not in ("safe", "low"):
            lines.append("Money involved: ₹" + str(int(amounts[0])) + ".")
        if intent == "bank_impersonation":
            lines.append("The message pretends to be from a bank or payment service.")
        elif intent == "government_impersonation":
            lines.append("The message pretends to be from a government authority.")
        elif intent == "customer_care_impersonation":
            lines.append("The message pretends to be customer care or tech support.")
        if intent in ("otp_request", "otp_disclosure"):
            lines.append("It is asking for an OTP, which is a private secret and should never be shared.")
        if intent == "payment_request":
            lines.append("It is pushing you to send money.")
        if intent == "remote_access":
            lines.append("It is asking you to install a remote-control application.")
        if intent == "credential_phishing":
            lines.append("It is asking for a password, PIN or card details.")
        if intent == "prize_lottery":
            lines.append("It claims you have won a prize or lottery.")
        if intent == "investment":
            lines.append("It promises unusually high investment returns.")
        if intent in ("threat_blackmail", "family_emergency"):
            lines.append("It uses fear to pressure you into acting fast.")
        if stage.stage == "urgency":
            lines.append("A strong time pressure was used to rush a decision.")
        if stage.stage == "isolation":
            lines.append("It tries to stop you from talking to family or the bank.")
        if stage.stage == "credential_harvesting":
            lines.append("The goal appears to be stealing your private credentials.")
        if stage.stage == "exploitation":
            lines.append("The message appears to be moving towards taking money or access.")
        if otp and otp.is_risky and otp.reason:
            lines.append(otp.reason)
        for link in links:
            if link["is_suspicious"] and link["reason"]:
                lines.append("Link check: " + link["reason"])
        if verification and not legit and verification.status in ("REPORTED_SCAM", "SUSPICIOUS_SENDER"):
            lines.append(verification.details)
        if not lines:
            lines.append("Routine message with no strong scam signals.")
        if level in ("high", "critical") and not any("not share" in l for l in lines):
            pass
        return lines[:6]


risk_engine = UnifiedRiskEngine()
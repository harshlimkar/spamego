import re
from datetime import datetime, timezone

from .schema import OtpFinding

OTP_PATTERNS = [
    re.compile(r"\b(?:otp|one[- ]?time[- ]?password)\b", re.IGNORECASE),
    re.compile(r"\b\d{4,8}\b(?![-+.,]?\d)"),
]

GIVE_TRIGGERS = [
    "tell me", "tell me the otp", "share the otp", "share otp", "send me the otp",
    "send the otp", "give me the otp", "provide otp", "confirm with the otp",
    "type the otp", "enter the otp you received", "sollunga", "kudunga", "சொல்லுங்க",
    "otp சொல்லுங்க", "otp söllunga", "कहिए", "बताइए", "भेजें", "दीजिए",
    "urgent otp", "otp verify", "verify otp",
]

BLOCK_URGENCY = ["block", "blocked", "suspended", "deactivated", "closed", "frozen", "முடக்க", "ब्लॉक"]

PAYMENT_URGENCY = ["validate transaction", "approve transaction", "confirm transaction", "reverse", "refund", "payment failed"]


class OtpIntelligence:
    def _has_otp_token(self, text):
        return bool(OTP_PATTERNS[0].search(text))

    def _value_present(self, text):
        for m in OTP_PATTERNS[1].finditer(text):
            token = m.group(0)
            if token.isdigit() and 4 <= len(token) <= 8:
                return True
        return False

    def analyze(self, text, channel, sender_status=""):
        lowered = (text or "").lower()
        otp_mentioned = self._has_otp_token(lowered)
        if not otp_mentioned:
            return OtpFinding(context="none", label="No OTP activity")

        value_present = self._value_present(text)

        give_matched = any(g in lowered for g in GIVE_TRIGGERS)
        urgency_matched = any(u in lowered for u in BLOCK_URGENCY)
        official_sender = "official" in sender_status.lower() or "verified" in sender_status.lower() or "trusted" in sender_status.lower()

        if give_matched and urgency_matched:
            return OtpFinding(
                context="requested_with_urgency",
                label="OTP being demanded under an urgent threat",
                is_risky=True,
                reason="The message connects an account threat (e.g. blocking) with a demand to reveal your OTP. Banks never do this.",
                value_present=value_present,
            )
        if give_matched:
            return OtpFinding(
                context="requested_unsolicited",
                label="OTP being requested by this sender",
                is_risky=True,
                reason="Someone is asking you to reveal an OTP. An OTP is a secret and must never be shared.",
                value_present=value_present,
            )
        has_payment_context = any(p in lowered for p in PAYMENT_URGENCY)
        if urgency_matched:
            return OtpFinding(
                context="threat_linked",
                label="Account-threat message linked to an OTP",
                is_risky=True,
                reason="The message raises an account threat and mentions an OTP, a common social-engineering pairing.",
                value_present=value_present,
            )
        if has_payment_context:
            return OtpFinding(
                context="transaction_validation",
                label="OTP tied to a payment event",
                is_risky=False,
                reason="OTP used to validate a transaction. Verify the transaction yourself before acting.",
                value_present=value_present,
            )
        if official_sender and not give_matched:
            return OtpFinding(
                context="received_legitimate_like",
                label="Delivered OTP notification",
                is_risky=False,
                reason="This looks like a routine OTP delivery message. Treat the code as secret.",
                value_present=value_present,
            )
        return OtpFinding(
            context="delivery_ambiguous",
            label="OTP mentioned in message",
            is_risky=False,
            reason="An OTP is mentioned. Never share it with anyone who calls or messages you.",
            value_present=value_present,
        )


otp_intelligence = OtpIntelligence()
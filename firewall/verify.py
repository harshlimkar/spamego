import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from .schema import Verification
from .entities import link_analyzer

TRUSTED_SENDER_IDS = {
    "AD-SBIPL", "VM-SBI", "SBIINB", "HDFCBK", "ICICIB", "AXISBK", "KOTAKB",
    "ADB-PNB", "CANARA", "IDFCB", "INDSIND", "YESBNK", "MYGOV", "AADHAR",
    "TX-PAYTM", "PAYTM", "PHONEPE", "UPI-AVN", "NPKI",
}

TRUSTED_APPS = {"paytm", "phonepe", "gpay", "google pay", "sbi yono", "yono sbi", "anydesk"}

SMS_HEADER_SUSPICIOUS_HINTS = {
    "golden", "creditloan", "yourbank", "redbus", "ttb", "mkvy", "kal", "dfdf",
}


class UnifiedVerifier:
    def __init__(self):
        self._num_verify = None

    def _number_verifier(self):
        if self._num_verify is None:
            from core.verification_engine import VerificationEngine
            self._num_verify = VerificationEngine()
        return self._num_verify

    def verify_number(self, phone):
        return self._number_verifier().verify_number(phone)

    def verify_sender(self, sender, channel):
        if not sender:
            return Verification(status="UNKNOWN", labels=["Unknown sender"], risk_modifier=0, details="No sender identity available.")
        lowered = sender.lower()
        if channel in ("sms", "social"):
            if sender in TRUSTED_SENDER_IDS:
                return Verification(
                    status="VERIFIED_SENDER_ID",
                    labels=["Verified sender ID"],
                    risk_modifier=-40,
                    organization=sender,
                    details="This sender identifier is on the official registry list.",
                )
            if any(h in lowered for h in SMS_HEADER_SUSPICIOUS_HINTS):
                return Verification(
                    status="SUSPICIOUS_SENDER",
                    labels=["Suspicious sender ID"],
                    risk_modifier=20,
                    details="The sender identifier matches known high-risk patterns.",
                )
        num_result = self._number_verifier().verify_number(sender)
        status = num_result["status"]
        details = num_result.get("details") or {}
        labels = {
            "TRUSTED_CONTACT": ["Trusted contact"],
            "VERIFIED_OFFICIAL": ["Verified official number"],
            "REPORTED_SCAM": ["Reported for scams"],
            "UNKNOWN": ["Not verified"],
        }.get(status, ["Not verified"])
        org = ""
        if isinstance(details, dict):
            org = details.get("organization") or details.get("name") or ""
        return Verification(
            status=status,
            labels=labels,
            risk_modifier=num_result["risk_modifier"],
            organization=org,
            details=self._describe(status, details),
        )

    def verify_domain(self, domain, original_url):
        finding = link_analyzer.analyze(original_url)
        status = "VERIFIED_DOMAIN" if finding["matches_trusted"] else ("SUSPICIOUS_DOMAIN" if finding["is_suspicious"] else "UNVERIFIED_DOMAIN")
        modifier = -40 if finding["matches_trusted"] else (30 if finding["is_suspicious"] else 5)
        return Verification(
            status=status,
            labels=[{"VERIFIED_DOMAIN": "Verified official domain", "SUSPICIOUS_DOMAIN": "Suspicious domain", "UNVERIFIED_DOMAIN": "Unverified domain"}[status]],
            risk_modifier=modifier,
            organization=domain,
            details=finding["reason"],
        )

    def verify_app(self, app_name):
        if (app_name or "").lower() in TRUSTED_APPS:
            return Verification(status="VERIFIED_APP", labels=["Known application"], risk_modifier=-15, organization=app_name, details="This is a widely used official application.")
        if app_name in ("anydesk", "teamviewer", "quicksupport"):
            return Verification(status="UNVERIFIED_APP", labels=["Remote access tool"], risk_modifier=25, organization=app_name, details="This is a remote-control tool frequently misused in scams.")
        return Verification(status="UNVERIFIED_APP", labels=["Unknown application"], risk_modifier=10, organization=app_name, details="Could not verify this application.")

    def _describe(self, status, details):
        if status == "TRUSTED_CONTACT":
            return "A number you marked as a trusted person."
        if status == "VERIFIED_OFFICIAL":
            org = "an official organisation"
            if isinstance(details, dict) and details.get("organization"):
                org = details["organization"]
            return "Matches an officially published number for %s." % org
        if status == "REPORTED_SCAM":
            return "This number has been reported as a scammer %s times." % details.get("report_count", "several")
        return "We could not verify this number against any trusted source." + _is_suspicious_hint()


def _is_suspicious_hint():
    return ""
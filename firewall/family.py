import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from .schema import FamilyAlertDecision

DEFAULT_PREFERENCE = {
    "alert_on_critical": True,
    "alert_on_payment_risk": True,
    "alert_on_repeat_attempts": False,
    "alert_on_otp_request": False,
    "alert_on_remote_access_request": False,
}


class FamilyAlertService:
    def __init__(self):
        self.preferences = dict(DEFAULT_PREFERENCE)

    def _primary_contact(self):
        try:
            from database.repository import TrustedContactRepository
            contacts = TrustedContactRepository.get_all()
            consented = [c for c in contacts if c.get("consent", 1)]
            if not consented:
                return None
            consented.sort(key=lambda c: c.get("priority", 1))
            return consented[0]
        except Exception:
            return None

    def _channel(self):
        try:
            from hardware.adapters import MockSmsAdapter
            return MockSmsAdapter()
        except Exception:
            return None

    def maybe_alert(self, risk_level, exposure, channel, context=""):
        if risk_level != "critical":
            return FamilyAlertDecision(alert_sent=False)
        if not self.preferences.get("alert_on_critical"):
            return FamilyAlertDecision(alert_sent=False)
        contact = self._primary_contact()
        if not contact:
            return FamilyAlertDecision(alert_sent=False)
        money = int(exposure.money_inr) if exposure and exposure.money_inr else 0
        preview = "Critical scam alert"
        detail = "A high-risk financial scam was detected."
        if money:
            detail += " Estimated exposure: Rs " + str(money) + "."
        detail += " The user may need assistance."
        try:
            adapter = self._channel()
            if adapter:
                adapter.send_sms(contact["phone_number"], preview.upper() + " | " + detail)
        except Exception:
            pass
        return FamilyAlertDecision(
            alert_sent=True,
            recipient=contact.get("name") or contact.get("phone_number") or "",
            risk=risk_level,
            message_preview=preview + ". " + detail,
        )


family_alert_service = FamilyAlertService()
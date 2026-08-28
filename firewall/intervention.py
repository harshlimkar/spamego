from .schema import Intervention


class InterventionEngine:
    def decide(self, risk_level, payment_amount=None, is_payment=False):
        scaled = 0
        if payment_amount:
            scaled = min(20, int(payment_amount) // 10000)
        if is_payment and risk_level in ("high", "critical"):
            return Intervention(
                action="STOP",
                title="Payment safety warning",
                message="This payment is linked to a suspicious conversation. Stop and verify before sending any money.",
                buttons=["STOP & VERIFY", "CONTINUE ANYWAY"],
            )
        if risk_level == "critical":
            return Intervention(
                action="STOP",
                title="Critical scam detected",
                message="This interaction has very strong scam indicators. Stop and verify before doing anything.",
                buttons=["STOP & VERIFY", "REPORT SCAM", "ASK FAMILY"],
            )
        if risk_level == "high":
            return Intervention(
                action="CONFIRM",
                title="Possible scam",
                message="This interaction looks risky. Do not share OTP, PIN or passwords.",
                buttons=["I UNDERSTAND", "VERIFY NUMBER", "SEE REASON"],
            )
        if risk_level == "medium":
            return Intervention(
                action="WARN",
                title="Be careful",
                message="This message shows some suspicious signals. Check before replying or clicking links.",
                buttons=["OK"],
            )
        return Intervention(action="NONE", title="", message="", buttons=[])


intervention_engine = InterventionEngine()
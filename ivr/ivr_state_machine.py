from hardware.adapters import MockAudioAdapter, MockTelephonyAdapter, MockKeypadAdapter
from call.dtmf_handler import DTMFHandler
from trusted.trusted_manager import TrustedManager
from core.campaign_engine import CampaignEngine

class IVRStateMachine:
    def __init__(self):
        self.audio = MockAudioAdapter()
        self.telephony = MockTelephonyAdapter()
        self.keypad = MockKeypadAdapter()
        self.trusted = TrustedManager()
        self.campaign_repo = CampaignEngine().campaign_repo
        self.state = "IDLE"

    def trigger_warning(self, risk_level, categories, caller_number, campaign_id):
        self.state = "WARNING"
        self._play_warning(risk_level, categories)
        self._wait_for_dtmf(risk_level, caller_number, campaign_id)

    def _play_warning(self, risk_level, categories):
        cats_str = ", ".join(categories) if categories else "unknown risks"
        
        if risk_level == "CRITICAL":
            self.audio.play_audio("CRITICAL SCAM DETECTED.")
            self.audio.play_audio(f"The caller is asking for {cats_str}.")
            self.audio.play_audio("Do not share your OTP. Do not send money.")
        else:
            self.audio.play_audio("Warning. This call may be fraudulent.")
            self.audio.play_audio(f"Possible risk: {cats_str}.")

        self.audio.play_audio("Press 1 to continue.")
        self.audio.play_audio("Press 2 to end the call.")
        self.audio.play_audio("Press 3 to contact your trusted person.")

    def _wait_for_dtmf(self, risk_level, caller_number, campaign_id):
        self.state = "WAITING_FOR_DTMF"
        
        while self.state == "WAITING_FOR_DTMF":
            key = self.keypad.get_keypress()
            action = DTMFHandler.get_action(key)

            if action == "CONTINUE":
                self.state = "CONTINUE"
                print("\n[IVR] Call continuing... (Be careful!)")
                break
            elif action == "END_CALL":
                self.state = "END_CALL"
                self.telephony.end_call()
                break
            elif action == "TRUSTED_CONTACT":
                self.state = "TRUSTED_CONTACT"
                self.telephony.end_call()
                primary = self.trusted.get_primary_contact()
                if primary:
                    self.trusted.send_alert(risk_level, "High-risk call detected and ended")
                    self.telephony.bridge_call(primary["phone_number"])
                else:
                    print("[IVR] No trusted contact found.")
                break
            elif action == "REPEAT":
                self.state = "WARNING"
                self._play_warning(risk_level, [])
                self.state = "WAITING_FOR_DTMF"
            elif action == "REASON":
                self.audio.play_audio(f"This number has a risk level of {risk_level}.")
                camp = self.campaign_repo.get_campaign(campaign_id)
                if camp:
                    self.audio.play_audio(f"Correlated categories: {camp['categories']}.")
            else:
                self.audio.play_audio("Invalid input. Press 1, 2, or 3.")

from ivr.ivr_state_machine import IVRStateMachine

class InterventionEngine:
    def __init__(self):
        self.ivr = IVRStateMachine()

    def evaluate_call_intervention(self, call_result):
        risk_level = call_result["final_risk_level"]
        
        if risk_level in ["HIGH", "CRITICAL"]:
            print(f"\n--- INTERVENTION TRIGGERED ({risk_level}) ---")
            self.ivr.trigger_warning(
                risk_level, 
                call_result["categories"], 
                call_result["caller_number"],
                call_result["campaign_id"]
            )
        else:
            print(f"\n--- Call deemed {risk_level}. No active intervention. ---")

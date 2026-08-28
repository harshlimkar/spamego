import time

class EventEngine:
    def __init__(self):
        # Track per-number: call timestamps
        self.history = {}

    def log_call(self, number: str):
        now = time.time()
        if number not in self.history:
            self.history[number] = []
        self.history[number].append(now)

    def calculate_timeline_risk(self, number: str) -> float:
        """
        Calculates timeline risk. e.g. 3 calls within 30 mins = escalation.
        """
        if number not in self.history:
            return 0.0
            
        now = time.time()
        # Filter calls in the last 30 minutes (1800 seconds)
        recent_calls = [t for t in self.history[number] if now - t < 1800]
        
        count = len(recent_calls)
        if count >= 3:
            return 1.0 # High risk (repeated calls in short window)
        elif count == 2:
            return 0.5 # Medium risk
        return 0.0 # Low risk

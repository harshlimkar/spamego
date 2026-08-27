from database.repository import TrustedContactRepository, UserRepository
from hardware.adapters import MockSmsAdapter

class TrustedManager:
    def __init__(self):
        self.repo = TrustedContactRepository()
        self.user_repo = UserRepository()
        self.sms = MockSmsAdapter()

    def get_primary_contact(self):
        contacts = self.repo.get_all()
        if not contacts:
            return None
        # Return highest priority (lowest number)
        return sorted(contacts, key=lambda c: c["priority"])[0]

    def add_contact(self, name, phone_number, relationship):
        self.repo.add(name, phone_number, relationship)

    def send_alert(self, risk_level, details="Possible OTP/payment scam"):
        primary = self.get_primary_contact()
        user_profile = self.user_repo.get_profile()
        user_name = user_profile["name"] if user_profile else "User"

        if not primary:
            print("[TRUSTED MANAGER] No trusted contacts registered to send alert.")
            return

        if risk_level == "CRITICAL":
            msg = f"ScameGo Alert: CRITICAL scam risk detected for {user_name} involving {details}. Please contact them immediately."
        else:
            msg = f"ScameGo Alert: A high-risk interaction was detected for {user_name}. {details}. Please check on them."

        self.sms.send_sms(primary["phone_number"], msg)
        print(f"[TRUSTED MANAGER] Alert sent to {primary['name']} ({primary['phone_number']})")

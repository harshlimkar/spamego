import sys
import os
import json
import time
import subprocess
from database.db_setup import init_db, seed_db
from database.repository import UserRepository
from trusted.trusted_manager import TrustedManager
from sms.sms_processor import SMSProcessor
from call.call_processor import CallProcessor, DemoCallProvider
from core.intervention_engine import InterventionEngine
from core.remote_client import RemoteIntelligenceClient

class ScameGoApp:
    def __init__(self):
        self.user_repo = UserRepository()
        self.trusted_mgr = TrustedManager()
        self.sms_proc = SMSProcessor()
        self.call_proc = CallProcessor()
        self.intervention = InterventionEngine()
        self.remote_client = RemoteIntelligenceClient()
        self.server_process = None

    def start_server(self):
        print("\n[SYSTEM] Starting Simulated ScameGo Intelligence Server...")
        # Start the FastAPI server in the background
        env = os.environ.copy()
        # Add the scamego dir to PYTHONPATH so server can resolve imports
        env["PYTHONPATH"] = os.path.dirname(os.path.abspath(__file__))
        self.server_process = subprocess.Popen(
            [sys.executable, "-m", "uvicorn", "server.main:app", "--port", "8000", "--log-level", "warning"],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        time.sleep(2) # Give it a moment to boot
        print("[SYSTEM] Server is running locally on port 8000.\n")

    def run_setup(self):
        print("\n=== ScameGo Setup ===")
        name = input("1. Enter Name: ")
        lang = input("2. Select Language (English/Tamil): ")
        phone = input("3. Confirm Your Number: ")
        self.user_repo.create_profile(name, lang, phone)
        print("4. Protection Enabled.")
        
        t_name = input("\n5. Add Trusted Person Name: ")
        t_phone = input("   Trusted Person Number: ")
        t_rel = input("   Relationship (e.g. Daughter, Son): ")
        self.trusted_mgr.add_contact(t_name, t_phone, t_rel)
        print("\nSetup Complete!")

    def speed_dial(self):
        print("\n=== SCAMEGO SECURITY ===")
        print("1. Check recent SMS (Simulate)")
        print("2. Trusted person status")
        print("3. Sync Threat Intelligence (Data Required)")
        print("0. Back")
        choice = input("Select option: ")
        if choice == '1':
            print("Speed dial checking SMS...")
            print("Done.")
        elif choice == '2':
            primary = self.trusted_mgr.get_primary_contact()
            if primary:
                print(f"Primary contact: {primary['name']} ({primary['phone_number']})")
            else:
                print("No trusted contact set.")
        elif choice == '3':
            self.remote_client.sync_threat_intelligence()

    def run_demo(self):
        print("\n====== STARTING HACKATHON DEMO ======")
        
        # 1. Setup
        profile = self.user_repo.get_profile()
        if not profile:
            self.run_setup()
        else:
            print(f"Protection ON for {profile['name']}")
        
        # 2. Legitimate SMS
        print("\n>>> INJECTING LEGITIMATE SMS")
        res1 = self.sms_proc.process("1800123456", "Your OTP for login is 123456. Do not share this OTP.")
        print(json.dumps(res1, indent=2))
        
        # 3. Suspicious KYC SMS from unknown number (Triggers Remote Query)
        print("\n>>> INJECTING KYC SCAM SMS (UNKNOWN NUMBER)")
        res2 = self.sms_proc.process("+919999999999", "Sir unga KYC expire aagiduchu. Update immediately.")
        print(json.dumps(res2, indent=2))
        
        # 4. Suspicious Call Simulation
        print("\n>>> INJECTING SUSPICIOUS CALL (From same number)")
        call_text = "I am calling from your bank. Your KYC has expired. Tell me the OTP immediately."
        provider = DemoCallProvider("+919999999999", call_text)
        
        call_res = self.call_proc.process_call(provider)
        print("\nCall analysis complete:")
        print(json.dumps(call_res, indent=2))
        
        # 5. Intervention Check
        self.intervention.evaluate_call_intervention(call_res)
        
        print("\n====== DEMO COMPLETE ======")

def main():
    if not os.path.exists("scamego_local.db"):
        init_db()
        seed_db()
    else:
        # Re-seed for fresh demo run
        init_db()
        seed_db()

    app = ScameGoApp()
    app.start_server()

    try:
        while True:
            print("\n--- SCAMEGO PHONE SIMULATOR ---")
            print("1. Run Full Demo")
            print("9. Speed Dial (Long press 9)")
            print("0. Exit")
            choice = input("Enter choice: ")

            if choice == '1':
                app.run_demo()
            elif choice == '9':
                app.speed_dial()
            elif choice == '0':
                break
            else:
                print("Invalid choice")
    finally:
        if app.server_process:
            app.server_process.terminate()

if __name__ == "__main__":
    main()

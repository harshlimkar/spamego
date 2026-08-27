import unittest
import os
import sys
import subprocess
import time

# Ensure imports work from tests directory
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from database.db_setup import init_db, seed_db
from sms.sms_processor import SMSProcessor
from call.call_processor import CallProcessor, DemoCallProvider
from core.intervention_engine import InterventionEngine

class TestScameGo(unittest.TestCase):
    server_process = None

    @classmethod
    def setUpClass(cls):
        # Force re-init DB for tests
        init_db()
        seed_db()
        cls.sms = SMSProcessor()
        cls.call = CallProcessor()
        
        # Start server for tests
        env = os.environ.copy()
        env["PYTHONPATH"] = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        cls.server_process = subprocess.Popen(
            [sys.executable, "-m", "uvicorn", "server.main:app", "--port", "8000"],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        time.sleep(2) # Wait for server boot

    @classmethod
    def tearDownClass(cls):
        if cls.server_process:
            cls.server_process.terminate()

    def test_01_legitimate_otp(self):
        # Known bank number, safe context despite OTP keyword
        res = self.sms.process("1800123456", "Your OTP is 123456. Never share it.")
        self.assertIn(res["final_risk_level"], ["SAFE", "LOW"])

    def test_02_otp_theft(self):
        # Unknown number, asking for OTP urgently
        res = self.sms.process("+919999888877", "Tell me your OTP immediately to verify your bank account.")
        self.assertIn(res["final_risk_level"], ["HIGH", "CRITICAL"])

    def test_03_tamil_mixed(self):
        res = self.sms.process("+919999888877", "Sir unga KYC expire. OTP sollunga immediately.")
        self.assertEqual(res["detected_language"], "Mixed (Tamil+English)")
        self.assertIn("KYC Scam", res["categories"])

    def test_04_campaign_escalation(self):
        number = "+917777777777"
        # Since server is running, the first suspicious SMS will trigger a server query.
        # If the number is NOT in the server's reported DB, server says "UNKNOWN", risk MEDIUM/HIGH.
        r1 = self.sms.process(number, "Update your KYC.")
        c_res = self.call.process_call(DemoCallProvider(number, "Tell me your OTP now. It is urgent. Please verify."))
        
        self.assertGreater(c_res["final_risk_score"], r1["final_risk_score"])
        self.assertIn(c_res["final_risk_level"], ["MEDIUM", "HIGH", "CRITICAL"])
        
    def test_05_server_sms_intelligence(self):
        # Test B - SMS intelligence available
        # +919876543210 is in server DB as REPORTED_SCAM
        res = self.sms.process("+919876543210", "Your KYC has expired. Send OTP.")
        
        # Local engine should have been overridden by server REPORTED_SCAM response
        self.assertEqual(res["sender_status"], "REPORTED_SCAM")
        self.assertEqual(res["final_risk_level"], "CRITICAL")
        
    def test_06_cached_number(self):
        # Test C - Cached number
        # After test_05, +919876543210 should be in local cache.
        # Kill the server to prove it uses local cache
        if self.server_process:
            self.server_process.terminate()
            self.server_process.wait()
            self.server_process = None
            
        res = self.sms.process("+919876543210", "Send payment.")
        self.assertEqual(res["sender_status"], "REPORTED_SCAM")

if __name__ == '__main__':
    unittest.main()

import unittest
import os
import sys

# Ensure imports work from tests directory
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from database.db_setup import init_db, seed_db
from sms.sms_processor import SMSProcessor
from call.call_processor import CallProcessor, DemoCallProvider
from core.intervention_engine import InterventionEngine

class TestScameGo(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Force re-init DB for tests
        init_db()
        seed_db()
        cls.sms = SMSProcessor()
        cls.call = CallProcessor()

    def test_01_legitimate_otp(self):
        # Known bank number, safe context despite OTP keyword
        res = self.sms.process("1800123456", "Your OTP is 123456. Never share it.")
        # Verified Official modifier (-50) should keep risk SAFE/LOW
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
        # SMS 1
        r1 = self.sms.process(number, "Update your KYC.")
        # SMS 2
        r2 = self.sms.process(number, "Your account blocked. Need PIN.")
        # Call
        c_res = self.call.process_call(DemoCallProvider(number, "Tell me your OTP now."))
        
        self.assertGreater(c_res["final_risk_score"], r1["final_risk_score"])
        self.assertEqual(c_res["final_risk_level"], "CRITICAL")

if __name__ == '__main__':
    unittest.main()

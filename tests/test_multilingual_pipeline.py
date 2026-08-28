import os
import sys
import unittest

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from firewall import firewall
from firewall.language import language_pipeline
from database.db_setup import init_db, seed_db

class TestMultilingualPipeline(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        init_db()
        seed_db()
    def test_01_english_scam(self):
        text = "Your account will be blocked. Send your OTP immediately."
        res = firewall.analyze_event({"channel": "sms", "text": text, "sender": "+919999999999"})
        self.assertIn(res["risk"]["level"], ["high", "critical"])
        self.assertIn(res["verdict"], ["POSSIBLE SCAM", "SCAM / CRITICAL"])
        print("\nTest 1 (English Scam):", res["language"], res["risk"]["level"], res["verdict"])

    def test_02_tamil_native_scam(self):
        text = "உங்கள் கணக்கு முடக்கப்படும். OTP சொல்லுங்கள்."
        res = firewall.analyze_event({"channel": "sms", "text": text, "sender": "+919999999999"})
        self.assertEqual(res["detected_script"], "Tamil")
        self.assertIn(res["risk"]["level"], ["high", "critical"])
        self.assertIn(res["verdict"], ["POSSIBLE SCAM", "SCAM / CRITICAL"])
        print("Test 2 (Tamil Native Scam):", res["language"], res["english_content"], res["risk"]["level"])

    def test_03_tanglish_scam(self):
        text = "Unga account block aagum. OTP sollunga."
        res = firewall.analyze_event({"channel": "whatsapp", "text": text, "sender": "+919999999999"})
        self.assertTrue(res["is_code_mixed"])
        self.assertIn("Tanglish", res["language"])
        self.assertIn(res["risk"]["level"], ["high", "critical"])
        self.assertIn(res["verdict"], ["POSSIBLE SCAM", "SCAM / CRITICAL"])
        print("Test 3 (Tanglish Scam):", res["language"], res["english_content"], res["risk"]["level"])

    def test_04_hinglish_scam(self):
        text = "Aapka account block ho jayega. OTP bhejo."
        res = firewall.analyze_event({"channel": "sms", "text": text, "sender": "+919999999999"})
        self.assertTrue(res["is_code_mixed"])
        self.assertIn("Hinglish", res["language"])
        self.assertIn(res["risk"]["level"], ["high", "critical"])
        self.assertIn(res["verdict"], ["POSSIBLE SCAM", "SCAM / CRITICAL"])
        print("Test 4 (Hinglish Scam):", res["language"], res["english_content"], res["risk"]["level"])

    def test_05_normal_tamil_message_safe(self):
        text = "Veetuku vandhutiya?"
        res = firewall.analyze_event({"channel": "whatsapp", "text": text, "sender": "+919876543210"})
        self.assertIn(res["risk"]["level"], ["safe", "low"])
        self.assertIn(res["verdict"], ["SAFE", "MOSTLY SAFE"])
        print("Test 5 (Normal Tamil):", res["language"], res["english_content"], res["risk"]["level"])

    def test_06_normal_banking_message_safe(self):
        text = "₹2,000 has been debited from your account."
        res = firewall.analyze_event({"channel": "sms", "text": text, "sender": "HDFCBK"})
        self.assertEqual(res["risk"]["level"], "safe")
        self.assertEqual(res["verdict"], "SAFE")
        print("Test 6 (Normal Banking):", res["language"], res["risk"]["level"])

if __name__ == "__main__":
    unittest.main()

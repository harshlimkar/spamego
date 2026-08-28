import os
import sys
import unittest

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from core.models import NormalizedMessage, RiskLevel
from core.universal_engine import UniversalScamEngine

class TestUniversalScamEngineIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = UniversalScamEngine()

    def test_01_cross_source_consistency(self):
        """Mandatory cross-source test: Same threat across SMS, WhatsApp, Instagram, Snapchat produces same verdict."""
        threat_text = "I am from Cyber Crime. Your Aadhaar is linked to a criminal case. Transfer ₹50,000 immediately."
        sources = ["SMS", "WHATSAPP", "INSTAGRAM", "SNAPCHAT"]
        
        results = []
        for src in sources:
            msg = NormalizedMessage(
                source=src,
                sender="+919988776655",
                message=threat_text,
                conversation_id=f"conv_{src}"
            )
            res = self.engine.analyze(msg)
            results.append(res)
            
            self.assertEqual(res.risk_level, RiskLevel.CRITICAL)
            self.assertIn("LEGAL", res.domains)
            self.assertTrue(res.impersonation_detected)
            self.assertTrue(res.payment_request)
            self.assertIn("DO NOT PAY", res.recommended_action)
            print(f"[Cross-Source] {src}: Risk={res.risk_score} Level={res.risk_level} Domains={res.domains} Impersonation={res.impersonated_entity}")

        # Ensure consistent classification
        self.assertEqual(results[0].risk_level, results[1].risk_level)
        self.assertEqual(results[1].risk_level, results[2].risk_level)
        self.assertEqual(results[2].risk_level, results[3].risk_level)

    def test_02_medical_emergency_scam(self):
        msg = NormalizedMessage(
            source="WHATSAPP",
            sender="+919123456789",
            message="I am from the hospital doctor. Your relative is in emergency treatment. Send ₹50,000 immediately for surgery."
        )
        res = self.engine.analyze(msg)
        self.assertIn(res.risk_level, [RiskLevel.HIGH, RiskLevel.CRITICAL])
        self.assertIn("MEDICAL", res.domains)
        self.assertTrue(res.impersonation_detected)
        self.assertTrue(res.payment_request)
        print("\n[Medical Emergency Scam]:", res.risk_level, res.impersonated_entity, res.reasons)

    def test_03_job_recruitment_scam(self):
        msg = NormalizedMessage(
            source="INSTAGRAM",
            sender="hr_recruiter_official",
            message="Amazon HR urgently recruiting for online part-time jobs. Daily salary 1000-3000 rs. Pay registration fee ₹500 to join."
        )
        res = self.engine.analyze(msg)
        self.assertIn(res.risk_level, [RiskLevel.HIGH, RiskLevel.CRITICAL])
        self.assertIn("EMPLOYMENT", res.domains)
        self.assertTrue(res.payment_request)
        print("[Job Scam]:", res.risk_level, res.domains, res.reasons)

    def test_04_delivery_courier_customs_scam(self):
        msg = NormalizedMessage(
            source="SMS",
            sender="FEDEX-IN",
            message="FedEx Customs Alert: Your winning parcel from Apple USA is held at customs. Pay customs clearance ₹2,500."
        )
        res = self.engine.analyze(msg)
        self.assertIn(res.risk_level, [RiskLevel.HIGH, RiskLevel.CRITICAL])
        self.assertIn("DELIVERY", res.domains)
        self.assertTrue(res.payment_request)
        print("[Courier Scam]:", res.risk_level, res.domains, res.reasons)

    def test_05_multilingual_tanglish_otp_theft(self):
        msg = NormalizedMessage(
            source="WHATSAPP",
            sender="+919876543210",
            message="Unga account block aagum. OTP sollunga."
        )
        res = self.engine.analyze(msg)
        self.assertIn(res.risk_level, [RiskLevel.HIGH, RiskLevel.CRITICAL])
        self.assertTrue(res.credential_request)
        print("[Tanglish Scam]:", res.risk_level, res.credential_request, res.reasons)

    def test_06_false_positive_benign_hospital_appointment(self):
        """Legitimate message without payment request or threats must be SAFE."""
        msg = NormalizedMessage(
            source="SMS",
            sender="APOLLO-HOSP",
            message="Dear Customer, your doctor appointment at Apollo Hospital is scheduled tomorrow at 10:00 AM."
        )
        res = self.engine.analyze(msg)
        self.assertEqual(res.risk_level, RiskLevel.SAFE)
        self.assertFalse(res.payment_request)
        self.assertFalse(res.credential_request)
        print("\n[Benign Hospital]: Risk=", res.risk_score, "Level=", res.risk_level)

    def test_07_false_positive_benign_bank_alert(self):
        msg = NormalizedMessage(
            source="SMS",
            sender="HDFCBK",
            message="Your account has been debited by Rs 2,000.00 at Starbucks on 28-Aug-2026. Avail bal: Rs 45,000."
        )
        res = self.engine.analyze(msg)
        self.assertEqual(res.risk_level, RiskLevel.SAFE)
        print("[Benign Bank Alert]: Risk=", res.risk_score, "Level=", res.risk_level)

if __name__ == "__main__":
    unittest.main()

import 'package:flutter_test/flutter_test.dart';
import 'package:scamego/services/risk_engine.dart';
import 'package:scamego/services/language/multilingual_pipeline.dart';
import 'package:scamego/services/language/language_detector.dart';

void main() {
  group('Multilingual Threat Analysis Tests', () {
    test('1. English Scam: Direct OTP Theft & Account Threat', () {
      const text = 'Your account will be blocked. Send your OTP immediately.';
      final event = RiskEngine.analyzeLocal(channel: 'sms', text: text, sender: '+919999999999');

      expect(event.risk.level, anyOf('high', 'critical'));
      expect(event.risk.score, greaterThanOrEqualTo(60));
      expect(event.language, contains('English'));
    });

    test('2. Native Tamil Scam: Account Block and OTP demand', () {
      const text = 'உங்கள் கணக்கு முடக்கப்படும். OTP சொல்லுங்கள்.';
      final event = RiskEngine.analyzeLocal(channel: 'sms', text: text, sender: '+919999999999');

      expect(event.risk.level, anyOf('high', 'critical'));
      expect(event.risk.score, greaterThanOrEqualTo(60));
      expect(event.language, equals('Tamil'));
      expect(event.normalized.toLowerCase(), contains('your account will be blocked'));
      expect(event.normalized.toLowerCase(), contains('tell / provide'));
    });

    test('3. Tanglish Scam: Code-mixed Romanized Tamil (Unga account block aagum OTP sollunga)', () {
      const text = 'Unga account block aagum. OTP sollunga.';
      final event = RiskEngine.analyzeLocal(channel: 'whatsapp', text: text, sender: '+919999999999');

      expect(event.risk.level, anyOf('high', 'critical'));
      expect(event.risk.score, greaterThanOrEqualTo(60));
      expect(event.language, contains('Tanglish'));
      expect(event.normalized.toLowerCase(), contains('your account will be blocked'));
      expect(event.normalized.toLowerCase(), contains('tell me the otp'));
    });

    test('4. Hinglish Scam: Code-mixed Romanized Hindi (Aapka account block ho jayega OTP bhejo)', () {
      const text = 'Aapka account block ho jayega. OTP bhejo.';
      final event = RiskEngine.analyzeLocal(channel: 'sms', text: text, sender: '+919999999999');

      expect(event.risk.level, anyOf('high', 'critical'));
      expect(event.risk.score, greaterThanOrEqualTo(60));
      expect(event.language, contains('Hinglish'));
      expect(event.normalized.toLowerCase(), contains('your account will be blocked'));
      expect(event.normalized.toLowerCase(), contains('send the otp'));
    });

    test('5. Benign Tanglish message is classified safe / low', () {
      const text = 'Veetuku vandhutiya?';
      final event = RiskEngine.analyzeLocal(channel: 'whatsapp', text: text, sender: '+919876543210');

      expect(event.risk.level, anyOf('safe', 'low'));
      expect(event.risk.score, lessThan(40));
      expect(event.language, contains('Tanglish'));
      expect(event.normalized.toLowerCase(), contains('did you reach home'));
    });

    test('6. Benign Banking message remains safe', () {
      const text = '₹2,000 has been debited from your account.';
      final event = RiskEngine.analyzeLocal(channel: 'sms', text: text, sender: 'HDFCBK');

      expect(event.risk.level, equals('safe'));
      expect(event.risk.score, lessThanOrEqualTo(10));
    });
  });
}

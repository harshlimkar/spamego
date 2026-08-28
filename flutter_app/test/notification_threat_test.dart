import 'package:flutter_test/flutter_test.dart';
import 'package:scamego/models/notification_event.dart';
import 'package:scamego/services/threat_event_normalizer.dart';
import 'package:scamego/services/risk_engine.dart';

void main() {
  group('Notification & Threat Pipeline Tests', () {
    test('AppSourceRegistry correctly categorizes package names', () {
      expect(
        AppSourceRegistry.getSourceForPackage('com.whatsapp'),
        NotificationSource.whatsapp,
      );
      expect(
        AppSourceRegistry.getSourceForPackage('com.snapchat.android'),
        NotificationSource.snapchat,
      );
      expect(
        AppSourceRegistry.getSourceForPackage('com.google.android.apps.messaging'),
        NotificationSource.sms,
      );
      expect(
        AppSourceRegistry.getSourceForPackage('com.sbi.lotusintouch'),
        NotificationSource.banking,
      );
      expect(
        AppSourceRegistry.getSourceForPackage('com.phonepe.app'),
        NotificationSource.payment,
      );
      expect(
        AppSourceRegistry.getSourceForPackage('com.instagram.android'),
        NotificationSource.social,
      );
    });

    test('ThreatEventNormalizer masks sensitive OTPs for privacy', () {
      final notif = NotificationEvent(
        id: 'test_1',
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        title: 'Customer Service',
        text: 'Your security OTP is 482910. Do not disclose it.',
        timestamp: DateTime.now(),
        source: NotificationSource.whatsapp,
      );

      final normalized = ThreatEventNormalizer.normalizeNotification(notif);
      expect(normalized.hasOtpContext, true);
      expect(normalized.sanitizedText.contains('482910'), false);
      expect(normalized.sanitizedText.contains('******'), true);
    });

    test('ThreatEventNormalizer identifies safe transactional banking alerts', () {
      final notif = NotificationEvent(
        id: 'test_2',
        packageName: 'com.sbi.lotusintouch',
        appName: 'YONO SBI',
        title: 'Transaction Alert',
        text: 'A/C *1234 debited by Rs 2,500 on 28-Aug-2026. Bal: Rs 50,000.',
        timestamp: DateTime.now(),
        source: NotificationSource.banking,
      );

      final normalized = ThreatEventNormalizer.normalizeNotification(notif);
      expect(normalized.isSafeBankingAlert, true);
      expect(normalized.extractedAmountsInr, contains(2500.0));
    });

    test('RiskEngine accurately classifies Fake KYC SMS as HIGH risk', () {
      final result = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: '+919999999999',
        text: 'URGENT: Your SBI account KYC has expired. Your account will be blocked today. Click http://sbi-kyc-secure.xyz to update now.',
        url: 'http://sbi-kyc-secure.xyz',
      );

      expect(result.risk.score >= 60, true);
      expect(result.risk.level == 'high' || result.risk.level == 'critical', true);
    });

    test('RiskEngine accurately classifies OTP Theft attempt as CRITICAL risk', () {
      final result = RiskEngine.analyzeLocal(
        channel: 'whatsapp',
        sender: '+919999999999',
        text: 'Sir please share the 6-digit OTP you just received to verify your bank account and stop immediate suspension.',
      );

      expect(result.risk.score >= 80, true);
      expect(result.risk.level, 'critical');
    });

    test('RiskEngine accurately classifies UPI Payment fraud attempt', () {
      final result = RiskEngine.analyzeLocal(
        channel: 'payment',
        sender: 'fraudster@upi',
        text: 'UPI Payment Request: Rs 50,000 to fraudster@upi for Mandatory KYC Account Security Deposit.',
        amountInr: 50000.0,
        upiId: 'fraudster@upi',
      );

      expect(result.risk.score >= 80, true);
      expect(result.risk.level, 'critical');
    });
  });
}

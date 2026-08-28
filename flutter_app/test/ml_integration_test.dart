import 'package:flutter_test/flutter_test.dart';
import 'package:scamego/services/platform_service.dart';

void main() {
  group('ML Integration Tests', () {
    late PlatformService platformService;

    setUp(() {
      platformService = PlatformService();
    });

    final scamMessages = [
      'SIR YOUR KYC HAS EXPIRED. UPDATE IMMEDIATELY OR ACCOUNT WILL BE BLOCKED TODAY. CLICK http://sbi-kyc-secure-login.xyz TO VERIFY',
      'Your account will be blocked. Tell me the OTP you just received immediately.',
      'Congratulations! You won ₹10,00,000 in Jio Lucky Draw. Click http://jio-prize-claim.xyz to claim now!',
      'Double your money in 30 days! Guaranteed returns on crypto investment. WhatsApp +919876543210',
      'Your computer has a virus. Install AnyDesk immediately so we can fix it. Download from anydesk.com',
    ];

    final legitMessages = [
      'Your A/C XXXXX is credited Rs. 5000. OTP 482918 for transaction. Do not share.',
      'Hi Mom, I am at the grocery store. Do you need anything?',
      'Reminder: Your dentist appointment is scheduled for tomorrow at 10 AM.',
      'Your food order from Zomato is out for delivery and will reach you in 15 mins.',
      'Can we reschedule our meeting to 3 PM? Thanks!',
    ];

    test('Test 5 scam messages', () async {
      print('--- Testing Scam Messages ---');
      for (int i = 0; i < scamMessages.length; i++) {
        final text = scamMessages[i];
        final result = await platformService.analyzeWithBackend(
          channel: 'sms',
          sender: '+919999999999',
          text: text,
        );
        
        print('Scam Msg ${i + 1}:');
        print('  Text: $text');
        print('  Verdict: ${result.verdict}');
        print('  Risk Level: ${result.risk.level}');
        print('  Risk Score: ${result.risk.score}');
        
        // We just assert that the integration works and returns a valid result.
        expect(result.verdict.isNotEmpty, true, reason: 'Expected a verdict');
        expect(result.risk.score >= 0, true, reason: 'Expected a non-negative risk score');
      }
    });

    test('Test 5 legitimate messages', () async {
      print('\n--- Testing Legitimate Messages ---');
      for (int i = 0; i < legitMessages.length; i++) {
        final text = legitMessages[i];
        final result = await platformService.analyzeWithBackend(
          channel: 'sms',
          sender: '+918888888888',
          text: text,
        );
        
        print('Legit Msg ${i + 1}:');
        print('  Text: $text');
        print('  Verdict: ${result.verdict}');
        print('  Risk Level: ${result.risk.level}');
        print('  Risk Score: ${result.risk.score}');
        
        // We just assert that the integration works and returns a valid result.
        expect(result.verdict.isNotEmpty, true, reason: 'Expected a verdict');
        expect(result.risk.score >= 0, true, reason: 'Expected a non-negative risk score');
      }
    });
  });
}

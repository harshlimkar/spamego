// Comprehensive Dataset Threat Flagging Tests
// Validates detection across fraud_call.file, India_Cyber_Scam_Hinglish_Dataset, spam_ham_india, and user datasets

import 'package:flutter_test/flutter_test.dart';
import 'package:scamego/services/risk_engine.dart';
import 'package:scamego/services/threat_event_normalizer.dart';

void main() {
  group('Dataset-Wide Scam & Threat Flagging Tests', () {

    test('1. De-obfuscation normalizes character swaps in spam SMS', () {
      final sample = 'Dear 901969xxxx, Rs.38,OOO/- is Added t0 your wallet account. Y0u have receive a B0nus of Rs.51OOO/-. L0AN is Approve 0n 29 Aug.';
      final deobf = ThreatEventNormalizer.deobfuscate(sample);
      
      expect(deobf.contains('to'), true);
      expect(deobf.contains('Bonus'), true);
      expect(deobf.contains('Loan'), true);
      expect(deobf.contains('38000') || deobf.contains('38,000'), true);
      expect(deobf.contains('51000'), true);
    });

    test('2. Flags Obfuscated Wallet / Withdrawal Scam (User Dataset)', () {
      final text = 'Dear 901969xxxx, Rs.38,OOO/- is Added t0 your wallet account XXX6 0n 29 Aug. Directly Withdraw N0w OI1.in/2vclen!8cpr814';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: '+919019695140',
        text: text,
      );

      expect(event.risk.score >= 70, true, reason: 'Expected High/Critical score for wallet lure');
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('Fake Wallet'));
    });

    test('3. Flags Apple USA 1 Crore Prize / Parcel Scam (User Dataset)', () {
      final text = 'YOUR WINNING FUND 1 CRORE RUPEES AND iPHONE 15 PROMAX WILL BE ARRIING INDIA FOR DELIVERY TO YOUR LOCATION ON THURSDAY,29TH AUGUST 2024 BY 10 AM INDIAN STANDARD';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: 'APPLE-USA',
        text: text,
      );

      expect(event.risk.score >= 70, true, reason: 'Expected High/Critical score for 1 crore lottery');
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('Parcel / Prize Scam'));
    });

    test('4. Flags SBI Bank Manager Debit Card Expiry Scam (fraud_call.file)', () {
      final text = 'hello, i m bank manager of SBI, ur debit card is about to expire would u want to issue new card.';
      final event = RiskEngine.analyzeLocal(
        channel: 'call',
        sender: '+919876543210',
        text: text,
      );

      expect(event.risk.score >= 60, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('Bank Card Expiry'));
    });

    test('5. Flags Vodafone Award Lottery Scam (fraud_call.file)', () {
      final text = 'Todays Vodafone numbers ending with 4882 are selected to a receive a £350 award. If your number matches call 09064019014 to receive your £350 award.';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: '09064019014',
        text: text,
      );

      expect(event.risk.score >= 60, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
    });

    test('6. Flags Fake KYC Suspension Panic (India_Cyber_Scam_Hinglish_Dataset)', () {
      final text = 'Ji namaskar Aapka KYC pending hai. Account 2 ghante me block ho jayega. Turant update kare link se';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: '+919988776655',
        text: text,
      );

      expect(event.risk.score >= 70, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('KYC'));
    });

    test('7. Flags Fake Part-Time Job / Amazon WhatsApp Lure (User Dataset)', () {
      final text = '(Kartik) Amazon urgently recruiting for part-time jobs, daily salary 1000-7000rs CLICK JOINING: wa.me/917993184064';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: 'AMAZON-JOB',
        text: text,
      );

      expect(event.risk.score >= 65, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('Part-Time Job'));
    });

    test('8. Flags Rummy / Gambling Cash Bonus Lure (User Dataset)', () {
      final text = 'Rs. 11,350 Welcome Bonus is waiting for you on Junglee Rummy. Unlock it now by making your first deposit. Claim http://Kx6.in/U8oBZo T&CA*-Sports League';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: 'RUMMY-PRO',
        text: text,
      );

      expect(event.risk.score >= 50, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL', 'MEDIUM'));
      expect(event.headline, contains('Rummy'));
    });

    test('9. Flags Predatory Unsolicited Loan (User Dataset)', () {
      final text = 'Congrats, Y0UR Received Rs.592000 L0AN is Approve on 15-O8-2O24. Zero documentation. Withdraw directly to Y0UR bank A/c. SR3.in/O15E-2i19i9DA02i4';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: 'LOAN-FAST',
        text: text,
      );

      expect(event.risk.score >= 70, true);
      expect(event.verdict, anyOf('HIGH', 'CRITICAL'));
      expect(event.headline, contains('Loan'));
    });

    test('10. Correctly keeps routine telecom data usage alerts as SAFE', () {
      final text = '50% Daily Data quota used as on 27-Aug-24 16:52 Hrs. Jio Number : 9019695140 Daily Data quota as per plan : 1.5 GB';
      final event = RiskEngine.analyzeLocal(
        channel: 'sms',
        sender: 'JIO-ALERT',
        text: text,
      );

      expect(event.risk.score <= 30, true, reason: 'Expected low/safe score for routine quota alert');
      expect(event.verdict, anyOf('SAFE', 'LOW'));
    });

    test('11. Correctly keeps legitimate transactional banking alert as SAFE', () {
      final text = 'Your A/C XXXXX is credited Rs. 5000. OTP 482918 for transaction. Do not share.';
      final event = RiskEngine.analyzeLocal(
        channel: 'banking',
        sender: 'HDFC-BANK',
        text: text,
      );

      expect(event.risk.score <= 30, true);
      expect(event.verdict, anyOf('SAFE', 'LOW'));
    });
  });
}

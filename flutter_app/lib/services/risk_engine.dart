// Dart port of the unified risk engine from Python, enhanced with full 18k+ dataset knowledge
import 'dart:math';

import '../models/scam_event.dart';
import 'threat_event_normalizer.dart';
import 'language/multilingual_pipeline.dart';

class RiskEngine {
  static const Map<String, int> _intentPoints = {
    'otp_disclosure': 28,
    'credential_phishing': 24,
    'remote_access': 24,
    'payment_request': 22,
    'threat_blackmail': 28,
    'otp_request': 18,
    'bank_impersonation': 16,
    'government_impersonation': 16,
    'family_emergency': 16,
    'kyc_verification': 14,
    'prize_lottery': 16,
    'fake_loan': 18,
    'rummy_gambling': 14,
    'part_time_job': 18,
    'investment': 14,
    'malware_link': 18,
    'delivery_request': 10,
    'information_phishing': 12,
    'loan_offer': 10,
    'marketing': 4,
    'notification': 0,
    'greeting': 0,
    'unknown': 0,
  };

  static const Map<String, int> _stagePoints = {
    'delivery': 2,
    'pretexting': 8,
    'urgency': 12,
    'isolation': 16,
    'credential_harvesting': 26,
    'exploitation': 30,
    'objective_completion': 34,
    'benign': 0,
  };

  static int _clamp(int v, {int lo = 0, int hi = 100}) => max(lo, min(hi, v));

  static String _levelForScore(int score) {
    if (score >= 80) return 'critical';
    if (score >= 60) return 'high';
    if (score >= 35) return 'medium';
    if (score >= 20) return 'low';
    return 'safe';
  }

  static RiskResult calculate({
    required int contentScore,
    required int heuristicScore,
    required int edgeScore,
    required String mlLabel,
    required double mlConfidence,
    required List<Intent> intents,
    required ScamStage stage,
    required OtpFinding otp,
    required Verification? verification,
    required List<LinkFinding> links,
    required List<double> amounts,
  }) {
    final content = (0.5 * contentScore + 0.5 * heuristicScore).round();
    final topIntent = intents.isNotEmpty ? intents.first.name : 'unknown';
    final intentPts = _intentPoints[topIntent] ?? 0;
    final stagePts = _stagePoints[stage.stage] ?? 0;

    int otpExtra = 0;
    if (otp.isRisky) {
      otpExtra = 15;
    } else if (otp.context != 'none' && otp.context != 'received_legitimate_like') {
      otpExtra = 6;
    }

    int linkExtra = 0;
    for (final link in links) {
      if (link.isSuspicious) {
        linkExtra += 12;
      } else if (link.matchesTrusted) {
        linkExtra -= 15;
      }
    }
    linkExtra = _clamp(linkExtra, lo: -15, hi: 20);

    int amountsExtra = 0;
    if (amounts.isNotEmpty) {
      amountsExtra = min(8, amounts.length * 3);
    }

    double gross = 0.4 * content + intentPts + stagePts + otpExtra + linkExtra + amountsExtra;
    final senderMod = verification?.riskModifier ?? 0;
    int score = _clamp((gross + senderMod).round());
    String level = _levelForScore(score);

    bool isLegit = verification != null &&
        ['VERIFIED_OFFICIAL', 'TRUSTED_CONTACT', 'VERIFIED_SENDER_ID', 'VERIFIED_DOMAIN'].contains(verification.status);

    if (isLegit && score > 40) {
      score = _clamp(score - 20);
      level = _levelForScore(score);
    }

    double confidence = 0.4;
    if (intents.isNotEmpty && intents.first.confidence > 0.7) {
      confidence = max(0.4, mlConfidence);
    } else {
      confidence = max(0.4, max(mlConfidence, intents.isNotEmpty ? intents.first.confidence : 0.5));
    }

    final factors = <String, dynamic>{
      'ml_score': _clamp(contentScore),
      'heuristic_score': _clamp(heuristicScore),
      'edge_score': _clamp(edgeScore),
      'intent': topIntent,
      'intent_points': intentPts,
      'stage': stage.stage,
      'stage_points': stagePts,
      'otp_extra': otpExtra,
      'link_extra': linkExtra,
      'amounts_extra': amountsExtra,
      'sender_modifier': senderMod,
      'legitimate_signal': isLegit,
    };

    final explanations = _explain(topIntent, stage, otp, links, verification, amounts, level);

    return RiskResult(
      score: score,
      level: level,
      edgeScore: edgeScore,
      confidence: confidence,
      isLegitimateSignal: isLegit,
      factors: factors,
      explanations: explanations,
    );
  }

  static List<String> _explain(
    String intent,
    ScamStage stage,
    OtpFinding otp,
    List<LinkFinding> links,
    Verification? verification,
    List<double> amounts,
    String level,
  ) {
    final lines = <String>[];
    final legit = verification != null && verification.status.startsWith('VERIFIED');

    if (intent == 'otp_disclosure' || intent == 'otp_request') {
      lines.add('It is asking for an OTP, which is a private secret.');
    }
    if (intent == 'bank_impersonation') {
      lines.add('The message pretends to be from a bank or financial institution.');
    }
    if (intent == 'government_impersonation') {
      lines.add('It claims to be from a government agency (TRAI, Police, IT, ED, CBI).');
    }
    if (intent == 'credential_phishing') {
      lines.add('It is asking for passwords, PIN, or card credentials.');
    }
    if (intent == 'prize_lottery') {
      lines.add('It claims you won a prize, lottery, parcel, or reward.');
    }
    if (intent == 'fake_loan') {
      lines.add('Unsolicited instant loan offer with suspicious links or advance fee demand.');
    }
    if (intent == 'part_time_job') {
      lines.add('High-paying daily online job lure requiring private WhatsApp contact.');
    }
    if (intent == 'rummy_gambling') {
      lines.add('Unsolicited rummy/betting cash bonus lure with withdrawal links.');
    }
    if (intent == 'investment') {
      lines.add('It promises guaranteed high returns on trading or crypto.');
    }
    if (intent == 'threat_blackmail' || intent == 'family_emergency') {
      lines.add('It uses fear and urgency to pressure you into acting fast.');
    }
    if (stage.stage == 'urgency') {
      lines.add('A strong time pressure was used to rush a decision.');
    }
    if (stage.stage == 'credential_harvesting') {
      lines.add('The goal appears to be stealing your private credentials.');
    }
    if (stage.stage == 'exploitation') {
      lines.add('The interaction appears to be moving towards money transfer.');
    }
    if (otp.isRisky && otp.reason.isNotEmpty) {
      lines.add(otp.reason);
    }
    for (final link in links) {
      if (link.isSuspicious && link.reason.isNotEmpty) {
        lines.add('Link check: ${link.reason}');
      }
    }
    if (verification != null && !legit && ['REPORTED_SCAM', 'SUSPICIOUS_SENDER'].contains(verification.status)) {
      lines.add(verification.details);
    }
    if (lines.isEmpty) {
      lines.add('Routine message with no strong scam signals.');
    }

    return lines.take(6).toList();
  }

  // ── Static method for offline/local analysis fallback ────────────────────────

  static ScamEvent analyzeLocal({
    required String channel,
    required String sender,
    required String text,
    String? upiId,
    double? amountInr,
    String? url,
    String? recipient,
  }) {
    final timestamp = DateTime.now();
    final risk = _analyzeOffline(
      text,
      sender: sender,
      channel: channel,
      amountInr: amountInr,
      upiId: upiId,
    );
    return _createScamEvent(
      channel: channel,
      sender: sender,
      text: text,
      risk: risk,
      timestamp: timestamp,
    );
  }

  static _RiskResult _analyzeOffline(
    String text, {
    String sender = '',
    String channel = 'sms',
    double? amountInr,
    String? upiId,
  }) {
    var score = 0;
    final threatInput = MultilingualPipeline.process(text);
    final deobf = threatInput.deobfuscatedText;
    final english = threatInput.canonicalEnglishText.toLowerCase();
    final t = '${deobf.toLowerCase()} $english';
    final s = sender.toLowerCase();

    // 1. HIGH-SEVERITY SCAM PATTERNS (Instantly flagged High/Critical)
    // -------------------------------------------------------------
    // Wallet / Direct Cash / Unsolicited Withdrawal
    const walletScamWords = [
      'added to your wallet account',
      'bonus is credited to your wallet',
      'bonus is credited',
      'directly withdraw now',
      'directly move to your bank',
      'instantly withdraw now',
      'move to your bank a/c',
      'join now to withdrawal',
      'direct transfer to bank a/c',
      'visitor id',
      'receive rs.10,000 to wallet',
      'withdraw directly',
      'withdrawal directly',
    ];
    if (walletScamWords.any((w) => t.contains(w))) score += 65;

    // Apple / Luxury Parcel / 1 Crore Lottery Scams / Award lures
    const bigLotteryWords = [
      'winning parcel',
      'winning fund',
      '1 crore',
      'iphone 15',
      'arriving india',
      'arrive india',
      're-verification form',
      'apple usa',
      'jio lucky draw',
      'jio prize claim',
      'won ₹',
      'won ?',
      'award',
      'selected to receive',
      'selected to a receive',
      'receive a £',
      'receive a rs',
      'prize pool',
    ];
    if (bigLotteryWords.any((w) => t.contains(w))) score += 70;

    // Fake Part-time Jobs & Daily Earning
    const partTimeJobWords = [
      'amazon urgently recruiting for part-time',
      'part-time jobs, daily salary',
      'earn 1000-3000rs every day',
      'earn 8000-20000/day',
      'earn 200-3000 rs a day',
      'online part-time job',
      'work online without investment',
      'daily salary 1000-7000rs',
      'no time limit, contact: https://wa.me',
    ];
    if (partTimeJobWords.any((w) => t.contains(w))) score += 65;

    // Rummy & Gambling Unsolicited Cash Lures
    const rummyLures = [
      'junglee rummy',
      'welcome bonus on first deposit',
      'special5500',
      'prize pool: 5,00,00,000',
      'prize pool: 2,50,00,000',
      'prize pool: 36,00,000',
      'millionaire tournament',
      'superstar finale',
      'play rummy & win cash',
      'my 11circle',
      'bonus in your rummy wallet',
      'rs. 11,350 welcome bonus',
    ];
    if (rummyLures.any((w) => t.contains(w))) score += 55;

    // Bank Manager Impersonation / Debit Card Expiry / KYC Fraud
    const bankImpersonationWords = [
      'bank manager of sbi',
      'debit card is about to expire',
      'issue new card',
      'kyc has expired',
      'update immediately or account will be blocked',
      'account will be blocked today',
      'update kyc',
      'pan card link',
      'electricity bill disconnect',
      'power cut tonight',
      'digital arrest',
      'cbi verification',
      'trai disconnection',
    ];
    if (bankImpersonationWords.any((w) => t.contains(w))) score += 60;

    // Suspicious Shortlink & Phishing Domains from Datasets
    const suspiciousDomains = [
      'oi1.in', 'sr3.in', '0kb.in', '1kx.in', 'gmg.im', 'kx6.in', 'p6x.in', 'qz6.in',
      'a0n.in', '1vp.cc', 'weurl.co', 'bnkbzr.co', 'rp17.in', 'tltx.in', 'is.gd', 'cutt.ly',
      's.cplry.com', 'tiny.xbees.in', 'xyz', 'top', 'click', 'site', 'bid',
    ];
    if (suspiciousDomains.any((d) => t.contains(d))) score += 40;

    // OTP Request & Theft (Matches both exact phrases and fuzzy keyword combinations, excluding "do not share" warnings)
    final hasDoNotShareOtp = t.contains('do not share') || t.contains('dont share') || t.contains("don't share") || t.contains('never share');
    final isOtpTheft = t.contains('otp') &&
        !hasDoNotShareOtp &&
        (t.contains('share') ||
            t.contains('tell') ||
            t.contains('give') ||
            t.contains('send') ||
            t.contains('forward') ||
            t.contains('provide') ||
            t.contains('batao') ||
            t.contains('dijiye') ||
            t.contains('sollu') ||
            t.contains('kudu'));
    if (isOtpTheft) score += 85;

    // Remote Access Software
    const remoteAppWords = ['anydesk', 'teamviewer', 'quicksupport', 'screen share', 'install rustdesk', 'download apk'];
    if (remoteAppWords.any((w) => t.contains(w))) score += 60;

    // Fake Investment / Trading Telegram / WhatsApp Groups
    const investmentLures = [
      'guaranteed returns on crypto',
      'double your money',
      'profit of 10% every day',
      'xai international securities',
      'chief investment officer',
      'prof sohan sharma',
      'assistant rama',
      'arvind singh',
      'vijay bajaj',
      'stockholding corporation',
    ];
    if (investmentLures.any((w) => t.contains(w))) score += 45;

    // Unsolicited Instant Loans & Predatory Lending
    const loanScamWords = [
      'loan is approve', 'zero documentation', 'loan application is ready',
      'olyv loan', 'smartcoin loan', 'kreditbee', 'truebalance', 'creditlinks',
      'fast loans', '50% off on proc. fees', '50% off processing fees',
    ];
    if (loanScamWords.any((w) => t.contains(w))) score += 40;

    // General Threat Context
    const authWords = ['otp', 'kyc', 'pin', 'password', 'login', 'verify', 'pan', 'aadhar', 'aadhaar', 'security deposit'];
    const urgentWords = ['blocked', 'suspend', 'freeze', 'lock', 'deactivate', 'terminate', 'expire', 'immediate', 'urgent', 'warning', 'mandatory', 'stoppage of services'];
    const linkWords = ['http', 'www', '.in/', '.co/', 'click', 'link'];

    final hasAuth = authWords.any((w) => t.contains(w));
    final hasUrgent = urgentWords.any((w) => t.contains(w));
    final hasLink = linkWords.any((w) => t.contains(w));
    final isPaymentContext = channel == 'payment' || upiId != null || (amountInr != null && amountInr > 0) || t.contains('upi payment request');

    if (hasAuth && hasUrgent) score += 30;
    if (hasUrgent && hasLink) score += 25;
    if (hasAuth && hasLink) score += 25;
    if (isPaymentContext && (hasAuth || hasUrgent)) score += 55;

    // 2. SAFE / LEGITIMATE CHECKS
    // -------------------------------------------------------------
    // Official TRAI Telecom notifications (e.g. data quota alert without phishing link)
    if (t.contains('daily data quota used') || t.contains('data quota as per plan')) {
      if (!t.contains('withdraw') && !t.contains('bonus') && !t.contains('kyc')) {
        score = 5;
      }
    }

    // Official Missed Call Alerts
    if (t.contains('you have a missed call from') && t.contains('thankyou, team jio')) {
      score = 0;
    }

    // Safe Transactional Banking
    if ((t.contains('debited') || t.contains('credited') || t.contains('spent on')) &&
        !hasLink && !hasUrgent && !isOtpTheft &&
        !t.contains('withdraw now') && !t.contains('bonus is credited to your wallet')) {
      score = 5;
    }

    final finalScore = score.clamp(0, 100);
    final level = _levelForScore(finalScore);

    return _RiskResult(
      score: finalScore,
      level: level,
      explanations: _generateExplanations(t, level),
    );
  }

  static List<String> _generateExplanations(String text, String level) {
    final explanations = <String>[];
    final t = text.toLowerCase();

    if (t.contains('apple') && (t.contains('winning') || t.contains('parcel') || t.contains('1 crore'))) {
      explanations.add('High-risk international parcel / lottery advance-fee scam lure.');
    }
    if (t.contains('wallet') && (t.contains('added') || t.contains('bonus') || t.contains('withdraw'))) {
      explanations.add('Fake wallet credit lure attempting to steal bank credentials.');
    }
    if (t.contains('bank manager') || (t.contains('debit card') && t.contains('expire'))) {
      explanations.add('Fake bank officer impersonation to harvest debit card / CVV details.');
    }
    if (t.contains('rummy') || t.contains('millionaire') || t.contains('special5500')) {
      explanations.add('Unsolicited gambling/rummy cash bonus phishing attempt.');
    }
    if (t.contains('amazon') && t.contains('part-time')) {
      explanations.add('Part-time job task scam asking for private WhatsApp contact.');
    }
    if (t.contains('loan') && (t.contains('approve') || t.contains('zero documentation'))) {
      explanations.add('Unsolicited predatory loan message with unverified links.');
    }
    if (t.contains('kyc') && (t.contains('expire') || t.contains('block') || t.contains('suspend'))) {
      explanations.add('Fake KYC suspension panic message pushing malicious verification.');
    }
    if (t.contains('otp') && (t.contains('tell') || t.contains('share') || t.contains('sollunga') || t.contains('batao'))) {
      explanations.add('Direct OTP theft attempt. OTP must never be shared.');
    }
    if (t.contains('anydesk') || t.contains('teamviewer') || t.contains('quicksupport')) {
      explanations.add('Remote access app installation request.');
    }
    if (explanations.isEmpty) {
      if (level == 'critical' || level == 'high') {
        explanations.add('Multiple urgency and credential harvesting signals detected.');
      } else if (level == 'medium' || level == 'low') {
        explanations.add('Promotional / marketing message with unverified external links.');
      } else {
        explanations.add('Routine transactional alert with no threat indicators.');
      }
    }
    return explanations;
  }

  static ScamEvent _createScamEvent({
    required String channel,
    required String sender,
    required String text,
    required _RiskResult risk,
    required DateTime timestamp,
  }) {
    String headline;
    final threatInput = MultilingualPipeline.process(text);
    final deobf = threatInput.deobfuscatedText;
    final english = threatInput.canonicalEnglishText.toLowerCase();
    final t = '${deobf.toLowerCase()} $english';

    if ((t.contains('apple') || t.contains('iphone')) && (t.contains('winning') || t.contains('1 crore') || t.contains('parcel') || t.contains('fund'))) {
      headline = 'International Parcel / Prize Scam';
    } else if (t.contains('winning') || t.contains('prize') || t.contains('award') || t.contains('lottery')) {
      headline = 'Lottery / Prize Scam';
    } else if (t.contains('wallet') && (t.contains('withdraw') || t.contains('bonus') || t.contains('added'))) {
      headline = 'Fake Wallet Cash Lure';
    } else if (t.contains('bank manager') || (t.contains('debit card') && t.contains('expire'))) {
      headline = 'Bank Card Expiry Impersonation';
    } else if (t.contains('rummy') || t.contains('special5500') || t.contains('bonus')) {
      headline = 'Rummy / Betting Lure Phishing';
    } else if (t.contains('part-time') || (t.contains('earn') && t.contains('day'))) {
      headline = 'Fake Part-Time Job Scam';
    } else if (t.contains('loan') || t.contains('credit card limit') || t.contains('zero documentation')) {
      headline = 'Predatory Loan Scam';
    } else if (t.contains('otp') && (t.contains('tell') || t.contains('share') || t.contains('sollunga') || t.contains('bhejo') || t.contains('batao'))) {
      headline = 'Critical OTP Theft Attempt';
    } else if (t.contains('kyc') && (t.contains('expire') || t.contains('block') || t.contains('pending'))) {
      headline = 'Fake KYC Suspension Risk';
    } else if (t.contains('anydesk') || t.contains('teamviewer')) {
      headline = 'Remote Access Control Risk';
    } else {
      headline = risk.level == 'safe' ? 'Verified Safe Message' : 'Suspicious Message Alert';
    }

    Intervention intervention;
    switch (risk.level) {
      case 'critical':
        intervention = const Intervention(
          action: 'STOP',
          title: 'Critical Scam Detected',
          message: 'This message has high-severity scam indicators. Stop and do not click links or share details.',
          buttons: ['STOP & VERIFY', 'REPORT SCAM', 'ASK FAMILY'],
        );
        break;
      case 'high':
        intervention = const Intervention(
          action: 'CONFIRM',
          title: 'Possible Fraud Warning',
          message: 'This interaction looks risky. Do not transfer funds or share private OTPs.',
          buttons: ['I UNDERSTAND', 'VERIFY SENDER', 'SEE REASON'],
        );
        break;
      case 'medium':
        intervention = const Intervention(
          action: 'WARN',
          title: 'Be Careful',
          message: 'This message contains promotional or unverified links.',
          buttons: ['OK'],
        );
        break;
      default:
        intervention = const Intervention(action: 'NONE', title: '', message: '', buttons: []);
    }

    return ScamEvent(
      id: 'evt_${timestamp.millisecondsSinceEpoch}',
      channel: channel,
      timestamp: timestamp,
      sender: sender,
      text: text,
      normalized: threatInput.canonicalEnglishText,
      language: threatInput.language.languageName,
      verdict: risk.level.toUpperCase(),
      headline: headline,
      risk: RiskResult(
        score: risk.score,
        level: risk.level,
        explanations: risk.explanations,
      ),
      campaign: CampaignInfo(
        campaignId: 'CAMP-${sender.replaceAll(RegExp(r'[^0-9]'), '')}-${timestamp.millisecondsSinceEpoch}',
        riskScore: risk.score,
        riskLevel: risk.level,
        exposure: Exposure(
          moneyInr: 0.0,
          credentialRisk: risk.level == 'critical' || risk.level == 'high' ? 'high' : 'low',
          otpRequested: text.toLowerCase().contains('otp'),
          description: risk.level == 'critical' || risk.level == 'high' ? 'High financial threat' : 'Low risk',
        ),
        eventCount: 1,
        channels: [channel],
      ),
      intervention: intervention,
      familyAlert: const FamilyAlertDecision(alertSent: false),
    );
  }
}

class _RiskResult {
  final int score;
  final String level;
  final List<String> explanations;

  _RiskResult({
    required this.score,
    required this.level,
    required this.explanations,
  });
}
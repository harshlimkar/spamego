// Dart port of the unified risk engine from Python
import 'dart:math';
import 'dart:convert';

import '../models/scam_event.dart';
import '../models/scam_event.dart';

class RiskEngine {
  static const Map<String, int> _intentPoints = {
    'otp_disclosure': 28,
    'credential_phishing': 24,
    'remote_access': 24,
    'payment_request': 22,
    'threat_blackmail': 28,
    'otp_request': 18,
    'bank_impersonation': 14,
    'government_impersonation': 14,
    'family_emergency': 16,
    'kyc_verification': 12,
    'prize_lottery': 14,
    'investment': 14,
    'malware_link': 16,
    'delivery_request': 10,
    'information_phishing': 12,
    'loan_offer': 8,
    'marketing': 2,
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

  static const Map<String, int> _mlLabelPoints = {
    'SAFE': 0,
    'SPAM': 18,
    'SCAM': 34,
    'UNKNOWN': 8,
    'ERROR': 8,
  };

  static int _clamp(int v, {int lo = 0, int hi = 100}) => max(lo, min(hi, v));

  static String _levelForScore(int score) {
    if (score >= 85) return 'critical';
    if (score >= 70) return 'high';
    if (score >= 50) return 'medium';
    if (score >= 30) return 'low';
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
    // Content score: blend ML and heuristic
    final content = (0.5 * contentScore + 0.5 * heuristicScore).round();
    
    // Intent points
    final topIntent = intents.isNotEmpty ? intents.first.name : 'unknown';
    final intentPts = _intentPoints[topIntent] ?? 0;
    
    // Stage points
    final stagePts = _stagePoints[stage.stage] ?? 0;
    
    // OTP extra
    int otpExtra = 0;
    if (otp.isRisky) {
      otpExtra = 15;
    } else if (otp.context != 'none' && otp.context != 'received_legitimate_like') {
      otpExtra = 6;
    }
    
    // Link extra
    int linkExtra = 0;
    for (final link in links) {
      if (link.isSuspicious) {
        linkExtra += 12;
      } else if (link.matchesTrusted) {
        linkExtra -= 15;
      }
    }
    linkExtra = _clamp(linkExtra, lo: -15, hi: 20);
    
    // Amounts extra
    int amountsExtra = 0;
    if (amounts.isNotEmpty) {
      amountsExtra = min(8, amounts.length * 3);
    }
    
    // Gross score
    double gross = 0.4 * content + intentPts + stagePts + otpExtra + linkExtra + amountsExtra;
    
    // Sender modifier
    final senderMod = verification?.riskModifier ?? 0;
    int score = _clamp((gross + senderMod).round());
    String level = _levelForScore(score);
    
    // Legitimate signal check
    bool isLegit = verification != null && 
        ['VERIFIED_OFFICIAL', 'TRUSTED_CONTACT', 'VERIFIED_SENDER_ID', 'VERIFIED_DOMAIN'].contains(verification.status);
    
    if (isLegit && score > 40) {
      score = _clamp(score - 20);
      level = _levelForScore(score);
    }
    
    // Confidence
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
      edgeScore: _clamp(edgeScore),
      confidence: confidence.clamp(0.0, 1.0),
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
    final legit = verification != null && 
        ['VERIFIED_OFFICIAL', 'TRUSTED_CONTACT', 'VERIFIED_SENDER_ID', 'VERIFIED_DOMAIN'].contains(verification.status);
    
    if (legit) {
      lines.add('The ${verification.status != "VERIFIED_DOMAIN" ? "sender" : "link"} was verified against an official source.');
    }
    
    if (amounts.isNotEmpty && !['safe', 'low'].contains(level)) {
      lines.add('Money involved: ₹${amounts.first.toInt()}.');
    }
    
    if (intent == 'bank_impersonation') {
      lines.add('The message pretends to be from a bank or payment service.');
    } else if (intent == 'government_impersonation') {
      lines.add('The message pretends to be from a government authority.');
    } else if (intent == 'customer_care_impersonation') {
      lines.add('The message pretends to be customer care or tech support.');
    }
    
    if (intent == 'otp_request' || intent == 'otp_disclosure') {
      lines.add('It is asking for an OTP, which is a private secret and should never be shared.');
    }
    if (intent == 'payment_request') {
      lines.add('It is pushing you to send money.');
    }
    if (intent == 'remote_access') {
      lines.add('It is asking you to install a remote-control application.');
    }
    if (intent == 'credential_phishing') {
      lines.add('It is asking for a password, PIN or card details.');
    }
    if (intent == 'prize_lottery') {
      lines.add('It claims you have won a prize or lottery.');
    }
    if (intent == 'investment') {
      lines.add('It promises unusually high investment returns.');
    }
    if (intent == 'threat_blackmail' || intent == 'family_emergency') {
      lines.add('It uses fear to pressure you into acting fast.');
    }
    if (stage.stage == 'urgency') {
      lines.add('A strong time pressure was used to rush a decision.');
    }
    if (stage.stage == 'isolation') {
      lines.add('It tries to stop you from talking to family or the bank.');
    }
    if (stage.stage == 'credential_harvesting') {
      lines.add('The goal appears to be stealing your private credentials.');
    }
    if (stage.stage == 'exploitation') {
      lines.add('The message appears to be moving towards taking money or access.');
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
  
  // Static method for offline/local analysis fallback
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
    final risk = _analyzeOffline(text);
    final event = _createScamEvent(
      channel: channel,
      sender: sender,
      text: text,
      risk: risk,
      timestamp: timestamp,
    );
    return event;
  }
  
  static _RiskResult _analyzeOffline(String text) {
    var score = 0;
    final t = text.toLowerCase();
    
    // Credentials & Auth
    const authWords = ['otp', 'kyc', 'pin', 'password', 'login', 'verify', 'update kyc', 'pan', 'aadhar', 'aadhaar'];
    if (authWords.any((w) => t.contains(w))) score += 30;
    
    // Financial Context
    const financeWords = ['bank', 'account', 'sbi', 'hdfc', 'icici', 'axis', 'pnb', 'loan', 'credit card', 'debit card', 'upi', 'payment', 'rupees', 'rs.', 'amount', 'transfer', 'paytm', 'phonepe', 'gpay', 'google pay'];
    if (financeWords.any((w) => t.contains(w))) score += 20;
    
    // Urgency & Threats
    const urgentWords = ['block', 'suspend', 'freeze', 'lock', 'deactivate', 'terminate', 'expire', 'immediate', 'urgent', 'now', 'warning', 'alert', 'attention', 'fail', 'cancel', 'udane', 'turant'];
    if (urgentWords.any((w) => t.contains(w))) score += 20;
    
    // Scams, Lures, and Links
    const lureWords = ['lottery', 'prize', 'won', 'winner', 'gift', 'cashback', 'reward', 'offer', 'free', 'job', 'salary', 'work from home', 'earn', 'lucky draw', 'jio alert'];
    if (lureWords.any((w) => t.contains(w))) score += 40;
    
    const linkWords = ['click', 'http', 'www', '.com', '.in', 'link', 'download', 'apk'];
    if (linkWords.any((w) => t.contains(w))) score += 20;
    
    // Base score
    score += 10;
    
    // Combinations
    final hasAuth = authWords.any((w) => t.contains(w));
    final hasUrgent = urgentWords.any((w) => t.contains(w));
    final hasLink = linkWords.any((w) => t.contains(w));
    
    if (hasAuth && hasUrgent) score += 30;
    if (hasUrgent && hasLink) score += 30;
    if (hasAuth && hasLink) score += 30;
    
    final finalScore = score.clamp(0, 100);
    final level = _levelForScore(finalScore);
    
    return _RiskResult(
      score: finalScore,
      level: level,
      explanations: _generateExplanations(t, level),
    );
  }
  
  // Duplicate _levelForScore removed
  
  static List<String> _generateExplanations(String text, String level) {
    final explanations = <String>[];
    final t = text.toLowerCase();
    
    if (t.contains('bank') || t.contains('sbi') || t.contains('hdfc')) {
      explanations.add('The message pretends to be from a bank or payment service.');
    }
    if (t.contains('otp') && (t.contains('tell') || t.contains('share') || t.contains('sollunga') || t.contains('दे') || t.contains('दें'))) {
      explanations.add('It is asking for an OTP, which is a private secret and should never be shared.');
    }
    if (t.contains('payment') || t.contains('pay') || t.contains('transfer')) {
      explanations.add('It is pushing you to send money.');
    }
    if (t.contains('anydesk') || t.contains('teamviewer') || t.contains('remote')) {
      explanations.add('It is asking you to install a remote-control application.');
    }
    if (['block', 'suspend', 'freeze', 'urgent', 'immediate', 'now'].any((w) => t.contains(w))) {
      explanations.add('A strong time pressure was used to rush a decision.');
    }
    if (explanations.isEmpty) {
      explanations.add('Routine message with no strong scam signals.');
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
    final t = text.toLowerCase();
    if (t.contains('bank') || t.contains('sbi') || t.contains('hdfc')) headline = 'Possible Bank Impersonation';
    else if (t.contains('income tax') || t.contains('government') || t.contains('police')) headline = 'Possible Government Impersonation';
    else if (t.contains('otp') && (t.contains('tell') || t.contains('share') || t.contains('sollunga'))) headline = 'OTP Request Scam';
    else if (t.contains('payment') || t.contains('pay') || t.contains('transfer') || t.contains('upi')) headline = 'Payment Request Risk';
    else if (t.contains('anydesk') || t.contains('teamviewer') || t.contains('remote')) headline = 'Remote Access Risk';
    else if (t.contains('prize') || t.contains('lottery') || t.contains('won')) headline = 'Prize / Lottery Scam';
    else headline = 'Routine Check';
    
    Intervention intervention;
    switch (risk.level) {
      case 'critical':
        intervention = Intervention(
          action: 'STOP',
          title: 'Critical Scam Detected',
          message: 'This interaction has very strong scam indicators. Stop and verify before doing anything.',
          buttons: ['STOP & VERIFY', 'REPORT SCAM', 'ASK FAMILY'],
        );
        break;
      case 'high':
        intervention = Intervention(
          action: 'CONFIRM',
          title: 'Possible Scam',
          message: 'This interaction looks risky. Do not share OTP, PIN or passwords.',
          buttons: ['I UNDERSTAND', 'VERIFY NUMBER', 'SEE REASON'],
        );
        break;
      case 'medium':
        intervention = Intervention(
          action: 'WARN',
          title: 'Be Careful',
          message: 'This message shows some suspicious signals. Check before replying or clicking links.',
          buttons: ['OK'],
        );
        break;
      default:
        intervention = Intervention(action: 'NONE', title: '', message: '', buttons: []);
    }
    
    return ScamEvent(
      id: 'evt_${timestamp.millisecondsSinceEpoch}',
      channel: channel,
      timestamp: timestamp,
      sender: sender,
      text: text,
      normalized: text.toLowerCase(),
      language: 'en',
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
          description: risk.level == 'critical' || risk.level == 'high' 
              ? 'Potential financial risk' 
              : 'Low risk',
        ),
        eventCount: 1,
        channels: [channel],
      ),
      intervention: intervention,
      familyAlert: FamilyAlertDecision(alertSent: false),
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
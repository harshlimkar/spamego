// Threat Event Normalizer — Safe content extraction, entity parsing, OTP masking, and De-obfuscation

import '../models/notification_event.dart';

class ThreatNormalizedEvent {
  final String id;
  final String channel; // 'sms', 'whatsapp', 'snapchat', 'banking', 'payment', 'social', 'call', 'other'
  final String sourceApp;
  final String packageName;
  final String sender;
  final String rawText;
  final String sanitizedText; // OTP-masked
  final String normalizedText;
  final DateTime timestamp;
  final List<String> extractedUrls;
  final List<String> extractedUpiIds;
  final List<double> extractedAmountsInr;
  final bool hasOtpContext;
  final bool isOtpTheftAttempt;
  final bool isSafeBankingAlert;
  final bool hasUrgencySignals;

  const ThreatNormalizedEvent({
    required this.id,
    required this.channel,
    required this.sourceApp,
    required this.packageName,
    required this.sender,
    required this.rawText,
    required this.sanitizedText,
    required this.normalizedText,
    required this.timestamp,
    required this.extractedUrls,
    required this.extractedUpiIds,
    required this.extractedAmountsInr,
    required this.hasOtpContext,
    required this.isOtpTheftAttempt,
    required this.isSafeBankingAlert,
    required this.hasUrgencySignals,
  });
}

class ThreatEventNormalizer {
  static final RegExp _urlRegex = RegExp(
    r'(https?:\/\/[^\s]+|www\.[^\s]+|(?:[a-zA-Z0-9-]+\.)+(?:xyz|top|click|online|live|info|club|site|cc|im|in|co|to|me|link|co\.in|org|net|com|app|gl|ly|be)\/[^\s]*)',
    caseSensitive: false,
  );

  static final RegExp _upiRegex = RegExp(
    r'([a-zA-Z0-9_.\-]+@[a-zA-Z]{2,})',
    caseSensitive: false,
  );

  static final RegExp _amountRegex = RegExp(
    r'(?:Rs\.?|INR|₹)\s*([\d,O]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _otpRegex = RegExp(
    r'\b(\d{4,8})\b',
  );

  static final List<String> _urgencyKeywords = [
    'immediate',
    'urgently',
    'immediately',
    'blocked',
    'suspended',
    'expired',
    'expire',
    'today',
    'within 24 hours',
    'deactivated',
    'freeze',
    'frozen',
    'legal action',
    'arrest',
    'police',
    'electricity cut',
    'power cut',
    'last warning',
    'avoid stoppage of services',
    'disconnection',
    'turant',
    'udane',
  ];

  static final List<String> _otpTheftKeywords = [
    'tell me the otp',
    'share the otp',
    'share otp',
    'send otp',
    'give me otp',
    'otp number',
    'tell otp',
    'forward otp',
    'provide otp',
    'verify otp over phone',
    'otp sollu',
    'otp kudu',
    'otp batao',
    'otp dijiye',
  ];

  /// De-obfuscates deliberate character swaps common in Indian SMS spam (e.g. "t0", "B0nus", "Rs.38,OOO", "L0AN")
  static String deobfuscate(String text) {
    var result = text;
    result = result.replaceAll(RegExp(r'\bt0\b', caseSensitive: false), 'to');
    result = result.replaceAll(RegExp(r'\b0n\b', caseSensitive: false), 'on');
    result = result.replaceAll(RegExp(r'\bB0nus\b', caseSensitive: false), 'Bonus');
    result = result.replaceAll(RegExp(r'\bY0u\b', caseSensitive: false), 'You');
    result = result.replaceAll(RegExp(r'\bY0ur\b', caseSensitive: false), 'Your');
    result = result.replaceAll(RegExp(r'\bL0an\b', caseSensitive: false), 'Loan');
    result = result.replaceAll(RegExp(r'\bN0\b', caseSensitive: false), 'No');
    result = result.replaceAll(RegExp(r'\bAcc\b', caseSensitive: false), 'Account');
    result = result.replaceAllMapped(RegExp(r'(Rs\.?|INR|₹|\b)(\d+[, ]*[O0]{2,6})\b', caseSensitive: false), (m) {
      final prefix = m.group(1)!;
      final digits = m.group(2)!.replaceAll('O', '0').replaceAll('o', '0');
      return '$prefix$digits';
    });
    return result;
  }

  static ThreatNormalizedEvent normalizeNotification(NotificationEvent event) {
    final channel = event.source.name;
    final text = event.fullContent;
    final sender = event.sender ?? event.appName;

    return _processContent(
      id: event.id,
      channel: channel,
      sourceApp: event.appName,
      packageName: event.packageName,
      sender: sender,
      content: text,
      timestamp: event.timestamp,
    );
  }

  static ThreatNormalizedEvent normalizeSms({
    required String sender,
    required String text,
    DateTime? timestamp,
  }) {
    return _processContent(
      id: 'sms_${DateTime.now().millisecondsSinceEpoch}',
      channel: 'sms',
      sourceApp: 'SMS',
      packageName: 'com.android.mms',
      sender: sender,
      content: text,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static ThreatNormalizedEvent _processContent({
    required String id,
    required String channel,
    required String sourceApp,
    required String packageName,
    required String sender,
    required String content,
    required DateTime timestamp,
  }) {
    final deobf = deobfuscate(content);
    final lower = deobf.toLowerCase();

    // 1. Extract URLs
    final urls = <String>[];
    for (final match in _urlRegex.allMatches(content)) {
      final url = match.group(0);
      if (url != null && !urls.contains(url)) {
        urls.add(url);
      }
    }
    // Also check de-obfuscated content for URLs
    for (final match in _urlRegex.allMatches(deobf)) {
      final url = match.group(0);
      if (url != null && !urls.contains(url)) {
        urls.add(url);
      }
    }

    // 2. Extract UPI IDs
    final upiIds = <String>[];
    for (final match in _upiRegex.allMatches(content)) {
      final upi = match.group(1);
      if (upi != null && !upiIds.contains(upi)) {
        if (!upi.endsWith('.com') && !upi.endsWith('.net') && !upi.endsWith('.org')) {
          upiIds.add(upi);
        }
      }
    }

    // 3. Extract Amounts
    final amounts = <double>[];
    for (final match in _amountRegex.allMatches(deobf)) {
      final rawAmt = match.group(1)?.replaceAll(',', '').replaceAll('O', '0').replaceAll('o', '0');
      if (rawAmt != null) {
        final amt = double.tryParse(rawAmt);
        if (amt != null && !amounts.contains(amt)) {
          amounts.add(amt);
        }
      }
    }

    // 4. OTP Context & Theft Analysis
    bool isOtpContext = lower.contains('otp') || lower.contains('one time password') || lower.contains('verification code');
    bool isOtpTheft = false;
    for (final kw in _otpTheftKeywords) {
      if (lower.contains(kw)) {
        isOtpTheft = true;
        break;
      }
    }

    // 5. Urgency Signals
    bool hasUrgency = false;
    for (final kw in _urgencyKeywords) {
      if (lower.contains(kw)) {
        hasUrgency = true;
        break;
      }
    }

    // 6. Safe Banking Alert Heuristic
    // A legitimate bank alert has: "debited", "credited", "spent at", "balance", but NO suspicious URLs and NO urgency threats.
    bool isSafeBanking = false;
    if (channel == 'banking' || lower.contains('debited') || lower.contains('credited') || lower.contains('acct') || lower.contains('a/c')) {
      if ((lower.contains('debited') || lower.contains('credited') || lower.contains('withdrawn')) &&
          urls.isEmpty &&
          !hasUrgency &&
          !isOtpTheft &&
          !lower.contains('blocked') &&
          !lower.contains('kyc expire') &&
          !lower.contains('withdraw now') &&
          !lower.contains('bonus is credited to your wallet')) {
        isSafeBanking = true;
      }
    }

    // 7. Privacy: Mask raw OTP in sanitized content
    String sanitized = content;
    if (isOtpContext) {
      sanitized = sanitized.replaceAllMapped(_otpRegex, (m) {
        final digits = m.group(1);
        if (digits != null && digits.length >= 4 && digits.length <= 8) {
          return '******';
        }
        return m.group(0)!;
      });
    }

    return ThreatNormalizedEvent(
      id: id,
      channel: channel,
      sourceApp: sourceApp,
      packageName: packageName,
      sender: sender,
      rawText: content,
      sanitizedText: sanitized,
      normalizedText: lower,
      timestamp: timestamp,
      extractedUrls: urls,
      extractedUpiIds: upiIds,
      extractedAmountsInr: amounts,
      hasOtpContext: isOtpContext,
      isOtpTheftAttempt: isOtpTheft,
      isSafeBankingAlert: isSafeBanking,
      hasUrgencySignals: hasUrgency,
    );
  }
}

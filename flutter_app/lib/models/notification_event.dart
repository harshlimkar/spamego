// Centralized Notification Event Model and App Source Registry

enum NotificationSource {
  sms,
  whatsapp,
  snapchat,
  banking,
  payment,
  messaging,
  social,
  other,
}

class NotificationEvent {
  final String id;
  final String packageName;
  final String appName;
  final String title;
  final String text;
  final String subText;
  final DateTime timestamp;
  final NotificationSource source;
  final String? sender;
  final Map<String, dynamic>? metadata;

  const NotificationEvent({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.title,
    required this.text,
    this.subText = '',
    required this.timestamp,
    required this.source,
    this.sender,
    this.metadata,
  });

  factory NotificationEvent.fromMap(Map<String, dynamic> map) {
    final packageName = map['packageName'] as String? ?? '';
    final appName = map['appName'] as String? ?? packageName;
    final title = map['title'] as String? ?? '';
    final text = map['text'] as String? ?? '';
    final subText = map['subText'] as String? ?? '';
    final tsRaw = map['timestamp'];
    final timestamp = tsRaw is int
        ? DateTime.fromMillisecondsSinceEpoch(tsRaw)
        : (tsRaw is String ? DateTime.tryParse(tsRaw) ?? DateTime.now() : DateTime.now());

    final source = AppSourceRegistry.getSourceForPackage(packageName);
    final sender = AppSourceRegistry.extractSender(title, packageName, source);

    return NotificationEvent(
      id: map['id'] as String? ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      packageName: packageName,
      appName: appName,
      title: title,
      text: text,
      subText: subText,
      timestamp: timestamp,
      source: source,
      sender: sender,
      metadata: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'title': title,
      'text': text,
      'subText': subText,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source.name,
      'sender': sender,
      'metadata': metadata,
    };
  }

  String get fullContent {
    if (title.isNotEmpty && text.isNotEmpty) {
      return '$title: $text';
    }
    return text.isNotEmpty ? text : title;
  }
}

/// Centralized registry for classifying applications by package name.
class AppSourceRegistry {
  static const Map<String, String> _knownApps = {
    // WhatsApp
    'com.whatsapp': 'WhatsApp',
    'com.whatsapp.w4b': 'WhatsApp Business',

    // Snapchat
    'com.snapchat.android': 'Snapchat',

    // SMS & Messaging
    'com.google.android.apps.messaging': 'Google Messages',
    'com.samsung.android.messaging': 'Samsung Messages',
    'com.android.mms': 'SMS Messages',
    'org.telegram.messenger': 'Telegram',
    'org.telegram.plus': 'Telegram Plus',
    'org.thoughtcrime.securesms': 'Signal',
    'com.facebook.orca': 'Messenger',

    // Banking Applications (India & Global)
    'com.sbi.lotusintouch': 'YONO SBI',
    'com.sbi.upi': 'BHIM SBI Pay',
    'com.hdfcbank.netbanking': 'HDFC MobileBanking',
    'com.icicibank.mobile': 'iMobile ICICI',
    'com.axis.mobile': 'Axis Mobile',
    'com.pnb.pnbone': 'PNB ONE',
    'com.bankofbaroda.mconnect': 'bob World',
    'com.canarabank.ai1': 'Canara ai1',
    'com.unionbank.ecommerce.mobile.banking': 'Union Bank Vyom',
    'com.kotak.kotakbank': 'Kotak 811',
    'com.indusind.mobile': 'IndusMobile',
    'com.idfcfirstbank.optimus': 'IDFC FIRST Bank',
    'com.rblbank.mobank': 'RBL MoBank',
    'com.yesbank': 'YES Mobile',

    // Payments & UPI
    'net.one97.paytm': 'Paytm',
    'com.phonepe.app': 'PhonePe',
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'in.org.npci.upiapp': 'BHIM UPI',
    'com.amazon.mShop.android.shopping': 'Amazon Pay',
    'com.freecharge.android': 'Freecharge',
    'com.mobikwik_new': 'MobiKwik',

    // Social Media
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.twitter.android': 'X / Twitter',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.linkedin.android': 'LinkedIn',
  };

  static NotificationSource getSourceForPackage(String packageName) {
    final lower = packageName.toLowerCase();

    if (lower.contains('whatsapp')) {
      return NotificationSource.whatsapp;
    }
    if (lower.contains('snapchat')) {
      return NotificationSource.snapchat;
    }
    if (lower.contains('messaging') || lower.contains('mms') || lower.contains('sms')) {
      return NotificationSource.sms;
    }
    if (lower.contains('telegram') || lower.contains('signal') || lower.contains('orca')) {
      return NotificationSource.messaging;
    }
    if (lower.contains('sbi') ||
        lower.contains('hdfc') ||
        lower.contains('icici') ||
        lower.contains('axis') ||
        lower.contains('pnb') ||
        lower.contains('bank') ||
        lower.contains('kotak') ||
        lower.contains('canara')) {
      return NotificationSource.banking;
    }
    if (lower.contains('paytm') ||
        lower.contains('phonepe') ||
        lower.contains('paisa') ||
        lower.contains('upi') ||
        lower.contains('mobikwik') ||
        lower.contains('freecharge')) {
      return NotificationSource.payment;
    }
    if (lower.contains('instagram') ||
        lower.contains('facebook') ||
        lower.contains('twitter') ||
        lower.contains('linkedin')) {
      return NotificationSource.social;
    }

    return NotificationSource.other;
  }

  static String getAppName(String packageName, [String? fallback]) {
    return _knownApps[packageName] ?? fallback ?? packageName;
  }

  static String? extractSender(String title, String packageName, NotificationSource source) {
    if (title.isEmpty) return null;
    // In messaging apps, the title is usually the sender/contact name
    if (source == NotificationSource.whatsapp ||
        source == NotificationSource.messaging ||
        source == NotificationSource.snapchat ||
        source == NotificationSource.social) {
      return title;
    }
    // In SMS, title could be sender number / DLT header (e.g. "VK-HDFCBK" or "+919876543210")
    if (source == NotificationSource.sms) {
      return title;
    }
    return getAppName(packageName, title);
  }
}

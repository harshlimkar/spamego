// Code-Mixed Normalizer: Transforms Romanized Tanglish/Hinglish & Indic text into Canonical English

import 'language_detector.dart';

class CodeMixedNormalizer {
  static const Map<String, String> _tamilMap = {
    'உங்கள்': 'your',
    'உங்களுடைய': 'your',
    'கணக்கு': 'account',
    'முடக்கப்படும்': 'will be blocked',
    'முடக்கம்': 'blocked',
    'காலாவதியாகும்': 'will expire',
    'சொல்லுங்கள்': 'tell / provide',
    'சொல்லு': 'tell',
    'வங்கி': 'bank',
    'உடனடியாக': 'immediately',
    'உடனே': 'immediately',
    'இன்று': 'today',
    'வீட்டிற்கு': 'to home',
    'வந்துவிட்டாயா': 'did you reach',
  };

  static const Map<String, String> _hindiMap = {
    'आपका': 'your',
    'खाता': 'account',
    'ब्लॉक': 'blocked',
    'हो जाएगा': 'will be',
    'कर दिया जाएगा': 'will be blocked',
    'केवाईसी': 'KYC',
    'ओटीपी': 'OTP',
    'भेजें': 'send',
    'बताओ': 'tell',
    'तुरंत': 'immediately',
    'बैंक': 'bank',
    'पैसे': 'money',
  };

  static final List<MapEntry<RegExp, String>> _tanglishPhrases = [
    MapEntry(RegExp(r'\bunga account block aagum\b', caseSensitive: false), 'your account will be blocked'),
    MapEntry(RegExp(r'\bunga account block aagidum\b', caseSensitive: false), 'your account will be blocked'),
    MapEntry(RegExp(r'\bunga kyc expire aagiduchu\b', caseSensitive: false), 'your KYC has expired'),
    MapEntry(RegExp(r'\bdebit card expire aagiduchu\b', caseSensitive: false), 'debit card has expired'),
    MapEntry(RegExp(r'\botp sollunga\b', caseSensitive: false), 'tell me the OTP'),
    MapEntry(RegExp(r'\botp sollu\b', caseSensitive: false), 'tell the OTP'),
    MapEntry(RegExp(r'\botp kudunga\b', caseSensitive: false), 'give the OTP'),
    MapEntry(RegExp(r'\bveetuku vandhutiya\b', caseSensitive: false), 'did you reach home?'),
    MapEntry(RegExp(r'\bepdi irukinga\b', caseSensitive: false), 'how are you?'),
    MapEntry(RegExp(r'\bnalla irukken\b', caseSensitive: false), 'I am fine.'),
  ];

  static const Map<String, String> _tanglishWords = {
    'unga': 'your',
    'ungal': 'your',
    'sollunga': 'tell',
    'sollu': 'tell',
    'kudunga': 'give',
    'aagiduchu': 'expired',
    'aagum': 'will happen',
    'aagidum': 'will happen',
    'pannunga': 'do',
    'irundhu': 'from',
    'udane': 'immediately',
    'veetuku': 'home',
    'vandhutiya': 'did you reach',
  };

  static final List<MapEntry<RegExp, String>> _hinglishPhrases = [
    MapEntry(RegExp(r'\baapka account block ho jayega\b', caseSensitive: false), 'your account will be blocked'),
    MapEntry(RegExp(r'\bapka account block ho jayega\b', caseSensitive: false), 'your account will be blocked'),
    MapEntry(RegExp(r'\baapka kyc pending hai\b', caseSensitive: false), 'your KYC is pending'),
    MapEntry(RegExp(r'\baccount 2 ghante me block ho jayega\b', caseSensitive: false), 'account will be blocked in 2 hours'),
    MapEntry(RegExp(r'\bturant update kare\b', caseSensitive: false), 'update immediately'),
    MapEntry(RegExp(r'\botp bhejo\b', caseSensitive: false), 'send the OTP'),
    MapEntry(RegExp(r'\botp batao\b', caseSensitive: false), 'tell the OTP'),
    MapEntry(RegExp(r'\bpaise transfer karo\b', caseSensitive: false), 'transfer the money'),
    MapEntry(RegExp(r'\bbeta ghar aa gaya hoon\b', caseSensitive: false), 'Son, I have arrived home.'),
    MapEntry(RegExp(r'\bkya haal hai\b', caseSensitive: false), 'How are you?'),
  ];

  static const Map<String, String> _hinglishWords = {
    'aapka': 'your',
    'apka': 'your',
    'tumhara': 'your',
    'khata': 'account',
    'bhejo': 'send',
    'batao': 'tell',
    'turant': 'immediately',
    'jaldi': 'urgently',
    'paise': 'money',
    'ghar': 'home',
  };

  static String normalizeToEnglish(String text, LanguageDetectionResult lang) {
    if (text.trim().isEmpty) return text;
    if (lang.languageCode == 'en' && !lang.isCodeMixed) return text;

    String result = text;

    // 1. Native Tamil
    if (lang.primaryScript == 'Tamil') {
      for (final entry in _tamilMap.entries) {
        result = result.replaceAll(entry.key, entry.value);
      }
      return result.trim();
    }

    // 2. Native Hindi
    if (lang.primaryScript == 'Devanagari') {
      for (final entry in _hindiMap.entries) {
        result = result.replaceAll(entry.key, entry.value);
      }
      return result.trim();
    }

    // 3. Tanglish
    if (lang.languageCode == 'ta-en' || lang.dialect == 'Tanglish') {
      for (final entry in _tanglishPhrases) {
        result = result.replaceAll(entry.key, entry.value);
      }
      final words = result.split(' ');
      final translated = words.map((w) {
        final clean = w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        if (_tanglishWords.containsKey(clean)) {
          return w.toLowerCase().replaceAll(clean, _tanglishWords[clean]!);
        }
        return w;
      }).join(' ');
      return translated.trim();
    }

    // 4. Hinglish
    if (lang.languageCode == 'hi-en' || lang.dialect == 'Hinglish') {
      for (final entry in _hinglishPhrases) {
        result = result.replaceAll(entry.key, entry.value);
      }
      final words = result.split(' ');
      final translated = words.map((w) {
        final clean = w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        if (_hinglishWords.containsKey(clean)) {
          return w.toLowerCase().replaceAll(clean, _hinglishWords[clean]!);
        }
        return w;
      }).join(' ');
      return translated.trim();
    }

    return result;
  }
}

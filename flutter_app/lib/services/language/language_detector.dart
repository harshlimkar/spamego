// Language and Script Detector for Flutter on-device intelligence

class LanguageDetectionResult {
  final String languageCode;
  final String languageName;
  final String primaryScript;
  final bool isCodeMixed;
  final double confidence;
  final String? dialect;

  const LanguageDetectionResult({
    required this.languageCode,
    required this.languageName,
    required this.primaryScript,
    required this.isCodeMixed,
    required this.confidence,
    this.dialect,
  });
}

class LanguageDetector {
  static const Map<String, List<int>> _scriptRanges = {
    'Tamil': [0x0B80, 0x0BFF],
    'Devanagari': [0x0900, 0x097F],
    'Telugu': [0x0C00, 0x0C7F],
    'Malayalam': [0x0D00, 0x0D7F],
    'Kannada': [0x0C80, 0x0CFF],
  };

  static const List<String> _tanglishMarkers = [
    'unga', 'ungal', 'sollunga', 'sollu', 'aagiduchu', 'aagum', 'aagidum',
    'pannunga', 'irundhu', 'kudunga', 'veetuku', 'vandhutiya', 'epdi',
    'irukinga', 'nalla', 'ippo', 'theva', 'enakku', 'mudivu'
  ];

  static const List<String> _hinglishMarkers = [
    'aapka', 'apka', 'tumhara', 'khata', 'bhejo', 'batao', 'karein', 'kijiye',
    'karo', 'hoga', 'jayega', 'turant', 'jaldi', 'abhi', 'paise', 'hai', 'hain'
  ];

  static LanguageDetectionResult detect(String text) {
    if (text.trim().isEmpty) {
      return const LanguageDetectionResult(
        languageCode: 'en',
        languageName: 'English',
        primaryScript: 'Latin',
        isCodeMixed: false,
        confidence: 1.0,
      );
    }

    final scriptCounts = <String, int>{};
    for (final entry in _scriptRanges.entries) {
      scriptCounts[entry.key] = 0;
    }
    int latinCount = 0;

    for (final rune in text.runes) {
      if ((rune >= 0x0041 && rune <= 0x005A) || (rune >= 0x0061 && rune <= 0x007A)) {
        latinCount++;
      }
      for (final entry in _scriptRanges.entries) {
        if (rune >= entry.value[0] && rune <= entry.value[1]) {
          scriptCounts[entry.key] = (scriptCounts[entry.key] ?? 0) + 1;
        }
      }
    }

    // 1. Native Indic Scripts
    if ((scriptCounts['Tamil'] ?? 0) > 0) {
      return LanguageDetectionResult(
        languageCode: 'ta',
        languageName: 'Tamil',
        primaryScript: 'Tamil',
        isCodeMixed: latinCount > 0,
        confidence: 0.98,
      );
    }
    if ((scriptCounts['Devanagari'] ?? 0) > 0) {
      return LanguageDetectionResult(
        languageCode: 'hi',
        languageName: 'Hindi',
        primaryScript: 'Devanagari',
        isCodeMixed: latinCount > 0,
        confidence: 0.98,
      );
    }

    // 2. Romanized Latin Code-Mixed
    final lowered = text.toLowerCase();
    final words = RegExp(r'\b[a-z]+\b').allMatches(lowered).map((m) => m.group(0)!).toList();

    int tanglishScore = 0;
    for (final w in words) {
      if (_tanglishMarkers.contains(w)) tanglishScore++;
    }

    int hinglishScore = 0;
    for (final w in words) {
      if (_hinglishMarkers.contains(w)) hinglishScore++;
    }

    if (tanglishScore >= 1 && tanglishScore >= hinglishScore) {
      return LanguageDetectionResult(
        languageCode: 'ta-en',
        languageName: 'Tamil-English mixed (Tanglish)',
        primaryScript: 'Latin',
        isCodeMixed: true,
        confidence: (0.7 + (tanglishScore * 0.1)).clamp(0.0, 0.95),
        dialect: 'Tanglish',
      );
    } else if (hinglishScore >= 1) {
      return LanguageDetectionResult(
        languageCode: 'hi-en',
        languageName: 'Hindi-English mixed (Hinglish)',
        primaryScript: 'Latin',
        isCodeMixed: true,
        confidence: (0.7 + (hinglishScore * 0.1)).clamp(0.0, 0.95),
        dialect: 'Hinglish',
      );
    }

    return const LanguageDetectionResult(
      languageCode: 'en',
      languageName: 'English',
      primaryScript: 'Latin',
      isCodeMixed: false,
      confidence: 0.95,
    );
  }
}

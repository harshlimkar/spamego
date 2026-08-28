// Multilingual Pipeline orchestrator for Flutter Client

import 'language_detector.dart';
import 'code_mixed_normalizer.dart';
import '../threat_event_normalizer.dart';

class LocalUnifiedThreatInput {
  final String originalText;
  final String deobfuscatedText;
  final String canonicalEnglishText;
  final LanguageDetectionResult language;

  const LocalUnifiedThreatInput({
    required this.originalText,
    required this.deobfuscatedText,
    required this.canonicalEnglishText,
    required this.language,
  });
}

class MultilingualPipeline {
  static LocalUnifiedThreatInput process(String rawText) {
    final deobfuscated = ThreatEventNormalizer.deobfuscate(rawText);
    final lang = LanguageDetector.detect(deobfuscated);
    final canonicalEnglish = CodeMixedNormalizer.normalizeToEnglish(deobfuscated, lang);

    return LocalUnifiedThreatInput(
      originalText: rawText,
      deobfuscatedText: deobfuscated,
      canonicalEnglishText: canonicalEnglish,
      language: lang,
    );
  }
}

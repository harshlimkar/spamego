# Language Pipeline for ScameGo: Transforms raw multilingual events into UnifiedThreatInput

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any

from .script_detector import ScriptDetector
from .language_detector import LanguageDetector
from .normalization_service import NormalizationService
from .translation_service import TranslationService

@dataclass
class UnifiedThreatInput:
    event_id: str
    channel: str
    source_application: str
    sender_or_caller: str
    timestamp: str
    
    # Language & Representation
    original_content: str
    detected_language: str
    detected_script: str
    is_code_mixed: bool
    
    # Transliterated and Normalized representations
    transliterated_content: str
    normalized_content: str
    english_content: str  # Canonical English representation
    
    translation_confidence: float
    translation_status: str
    
    # Preserved original signals & entities
    protected_tokens: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)

class LanguagePipeline:
    def __init__(self):
        self.script_detector = ScriptDetector()
        self.language_detector = LanguageDetector()
        self.normalizer = NormalizationService()
        self.translator = TranslationService()

    def process(
        self,
        text: str,
        channel: str = "sms",
        source_app: str = "SMS",
        sender: str = "",
        event_id: str = "",
        timestamp: str = ""
    ) -> UnifiedThreatInput:
        raw_text = text or ""
        
        # 1. De-obfuscation & character normalization
        deobfuscated = self.normalizer.deobfuscate(raw_text)
        
        # 2. Extract preserved scam tokens from original
        protected_tokens = self.normalizer.extract_protected_tokens(raw_text)
        
        # 3. Script detection
        script_info = self.script_detector.detect_scripts(deobfuscated)
        primary_script = script_info.get("primary_script", "Latin")
        
        # 4. Language & Code-mixed detection
        lang_info = self.language_detector.detect(deobfuscated)
        lang_name = lang_info.get("language_name", "English")
        is_code_mixed = lang_info.get("is_code_mixed", False)
        
        # 5. Semantic Translation to Canonical English
        trans_result = self.translator.translate_to_english(deobfuscated, lang_info)
        english_content = trans_result.get("english_text", deobfuscated)
        trans_conf = trans_result.get("confidence", 1.0)
        trans_status = trans_result.get("status", "success")
        
        return UnifiedThreatInput(
            event_id=event_id or f"evt_{id(raw_text)}",
            channel=channel,
            source_application=source_app,
            sender_or_caller=sender,
            timestamp=timestamp,
            original_content=raw_text,
            detected_language=lang_name,
            detected_script=primary_script,
            is_code_mixed=is_code_mixed,
            transliterated_content=deobfuscated,
            normalized_content=deobfuscated,
            english_content=english_content,
            translation_confidence=trans_conf,
            translation_status=trans_status,
            protected_tokens=protected_tokens,
            metadata={
                "script_info": script_info,
                "language_info": lang_info,
            }
        )

# Global singleton
language_pipeline = LanguagePipeline()

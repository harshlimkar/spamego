from core.models import NormalizedMessage, ScamAnalysisResult, RiskLevel
from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.context_analyzer import ContextAnalyzer
from core.risk_engine import UniversalRiskEngine

class UniversalScamEngine:
    """
    The central universal intelligence brain for ScameGo.
    Takes a NormalizedMessage from ANY source (SMS, WhatsApp, Instagram, Snapchat, Email, Call, etc.)
    and returns an explainable ScamAnalysisResult.
    """
    def __init__(self):
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.context_analyzer = ContextAnalyzer()
        self.risk_engine = UniversalRiskEngine()
        self._language_pipeline = None

    def _get_language_pipeline(self):
        if self._language_pipeline is None:
            try:
                from firewall.language import language_pipeline
                self._language_pipeline = language_pipeline
            except Exception:
                self._language_pipeline = None
        return self._language_pipeline

    def analyze(self, message: NormalizedMessage) -> ScamAnalysisResult:
        raw_text = message.message or ""
        
        # 1. Multilingual Normalization & Translation (if regional / code-mixed)
        lang_pipeline = self._get_language_pipeline()
        canonical_text = raw_text
        detected_lang = "English"
        if lang_pipeline:
            threat_input = lang_pipeline.process(
                text=raw_text,
                channel=message.source.lower(),
                sender=message.sender,
                event_id=message.metadata.get("id", "")
            )
            canonical_text = threat_input.english_content
            detected_lang = threat_input.detected_language

        # 2. Update Multi-message Conversation Context
        context_data = self.context_analyzer.update_and_get_context(message)
        
        # 3. Extract Universal Keywords from both original and translated representations
        kw_raw = self.keyword_engine.analyze_text(raw_text)
        kw_canon = self.keyword_engine.analyze_text(canonical_text) if canonical_text != raw_text else kw_raw

        # Merge signals
        merged_domains = list(set(kw_raw.get("domains", []) + kw_canon.get("domains", [])))
        merged_scam_types = list(set(kw_raw.get("scam_types", []) + kw_canon.get("scam_types", [])))
        merged_behaviors = list(set(kw_raw.get("behaviors", []) + kw_canon.get("behaviors", [])))
        merged_categories = list(set(kw_raw.get("categories", []) + kw_canon.get("categories", [])))
        merged_keywords = list(set(kw_raw.get("keywords_detected", []) + kw_canon.get("keywords_detected", [])))
        merged_weight = max(kw_raw.get("keyword_weight", 0), kw_canon.get("keyword_weight", 0))

        kw_result = {
            "domains": merged_domains,
            "scam_types": merged_scam_types,
            "behaviors": merged_behaviors,
            "categories": merged_categories,
            "keywords_detected": merged_keywords,
            "keyword_weight": merged_weight,
            "detected_language": detected_lang,
        }
        
        # 4. Evaluate Behavioral Combinatory Rules
        rule_result = self.rule_engine.evaluate_behavioral_rules(
            kw_result=kw_result,
            context_data=context_data
        )
        
        # 5. Calculate Structured Risk Score, Explanations, and Actionable Guidance
        result = self.risk_engine.calculate_risk(
            kw_result=kw_result,
            rule_result=rule_result,
            context_data=context_data,
            message=message
        )
        
        return result

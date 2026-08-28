from core.models import NormalizedMessage, ScamAnalysisResult, RiskLevel
from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.context_analyzer import ContextAnalyzer
from core.risk_engine import UniversalRiskEngine

class UniversalScamEngine:
    """
    The central intelligence brain for ScameGo.
    Takes a NormalizedMessage from ANY source and returns a ScamAnalysisResult.
    """
    def __init__(self):
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.context_analyzer = ContextAnalyzer()
        self.risk_engine = UniversalRiskEngine()

    def analyze(self, message: NormalizedMessage) -> ScamAnalysisResult:
        # 1. Update Context (if part of conversation)
        context_data = self.context_analyzer.update_and_get_context(message)
        
        # 2. Extract Keywords (Behaviors, Requests, Domains, Threats)
        kw_result = self.keyword_engine.analyze_text(message.message)
        
        # 3. Evaluate Behavioral Rules combinations
        rule_result = self.rule_engine.evaluate_behavioral_rules(
            kw_result=kw_result,
            context_data=context_data
        )
        
        # 4. Generate Final Risk Score and Explanation
        result = self.risk_engine.calculate_risk(
            kw_result=kw_result,
            rule_result=rule_result,
            context_data=context_data,
            message=message
        )
        
        return result

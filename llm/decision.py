from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum

from llm.schemas import (
    RiskLevel, AgentAction, ScamStage, AttackerIntent, 
    ExposureAssessment, LegitimacyAssessment, RecoveryAction
)
from llm.config import config


class InterventionLevel(str, Enum):
    NONE = "NONE"
    LOG = "LOG"
    WARNING = "WARNING"
    STRONG_WARNING = "STRONG_WARNING"
    HIGH_RISK = "HIGH_RISK"
    CRITICAL = "CRITICAL"


@dataclass
class DecisionContext:
    risk_score: int
    risk_level: RiskLevel
    confidence: float
    stage: ScamStage
    intent: List[AttackerIntent]
    exposure: ExposureAssessment
    legitimacy: LegitimacyAssessment
    campaign_risk: int
    campaign_status: str
    progression_velocity: str
    user_preferences: Dict[str, Any]


class AgentDecisionEngine:
    def __init__(self):
        self.risk_thresholds = {
            RiskLevel.SAFE: (0, config.risk_threshold_medium - 1),
            RiskLevel.LOW: (config.risk_threshold_medium, config.risk_threshold_high - 1),
            RiskLevel.MEDIUM: (config.risk_threshold_high, config.risk_threshold_critical - 1),
            RiskLevel.HIGH: (config.risk_threshold_critical, 95),
            RiskLevel.CRITICAL: (96, 100),
        }
        
        self.action_policies = self._build_action_policies()

    def _build_action_policies(self) -> Dict[RiskLevel, List[AgentAction]]:
        return {
            RiskLevel.SAFE: [AgentAction.LOG],
            RiskLevel.LOW: [AgentAction.LOG, AgentAction.USER_WARNING],
            RiskLevel.MEDIUM: [AgentAction.LOG, AgentAction.USER_WARNING, AgentAction.STRONG_WARNING],
            RiskLevel.HIGH: [AgentAction.LOG, AgentAction.HIGH_RISK_ALERT, AgentAction.REQUEST_CONFIRMATION],
            RiskLevel.CRITICAL: [
                AgentAction.LOG, 
                AgentAction.CRITICAL_ALERT, 
                AgentAction.NOTIFY_TRUSTED_CONTACT, 
                AgentAction.TRIGGER_RECOVERY,
                AgentAction.MARK_CAMPAIGN_CRITICAL
            ],
        }

    def determine_risk_level(self, score: int) -> RiskLevel:
        for level, (min_score, max_score) in self.risk_thresholds.items():
            if min_score <= score <= max_score:
                return level
        return RiskLevel.SAFE

    def calculate_final_risk(self, context: DecisionContext) -> int:
        """Calculate final risk score combining all factors."""
        # Base risk from ML + rules
        base_risk = context.risk_score
        
        # Legitimacy modifier
        if context.legitimacy.verified:
            base_risk = max(0, base_risk - 30)
        elif context.legitimacy.confidence < 0.3:
            base_risk = min(100, base_risk + 15)
        
        # Campaign risk factor
        if context.campaign_risk > base_risk:
            base_risk = (base_risk + context.campaign_risk) // 2
        
        # Progression velocity
        if context.progression_velocity == "RAPID":
            base_risk = min(100, base_risk + 15)
        elif context.progression_velocity == "MODERATE":
            base_risk = min(100, base_risk + 5)
        
        # Exposure factor
        exposure_boost = 0
        if context.exposure.money_exposure > 10000:
            exposure_boost += 10
        if context.exposure.money_exposure > 50000:
            exposure_boost += 15
        if context.exposure.credential_exposure:
            exposure_boost += 10
        if context.exposure.otp_exposure:
            exposure_boost += 15
        if context.exposure.device_access_exposure:
            exposure_boost += 20
        
        base_risk = min(100, base_risk + exposure_boost)
        
        # Intent factor
        high_risk_intents = [
            AttackerIntent.SHARE_OTP, AttackerIntent.SHARE_PIN,
            AttackerIntent.ENABLE_REMOTE_ACCESS, AttackerIntent.SCREEN_SHARE,
            AttackerIntent.APPROVE_PAYMENT, AttackerIntent.SEND_MONEY
        ]
        if any(i in high_risk_intents for i in context.intent):
            base_risk = min(100, base_risk + 10)
        
        # Stage factor
        stage_risk = {
            ScamStage.DELIVERY: 0,
            ScamStage.PRETEXTING: 5,
            ScamStage.URGENCY: 10,
            ScamStage.ISOLATION: 15,
            ScamStage.CREDENTIAL_HARVESTING: 20,
            ScamStage.EXPLOITATION: 25,
            ScamStage.OBJECTIVE_COMPLETION: 30,
            ScamStage.BENIGN: -20,
            ScamStage.UNKNOWN: 0,
        }
        base_risk = min(100, max(0, base_risk + stage_risk.get(context.stage, 0)))
        
        return base_risk

    def determine_actions(self, context: DecisionContext, final_risk: int) -> List[AgentAction]:
        """Determine actions based on final risk and context."""
        risk_level = self.determine_risk_level(final_risk)
        base_actions = self.action_policies.get(risk_level, [AgentAction.LOG])
        
        actions = list(base_actions)
        
        # Add trusted contact notification for critical with consent
        if (risk_level == RiskLevel.CRITICAL and 
            context.user_preferences.get("trusted_contact_consent", False) and
            AgentAction.NOTIFY_TRUSTED_CONTACT not in actions):
            actions.append(AgentAction.NOTIFY_TRUSTED_CONTACT)
        
        # Add recovery for high exposure
        if context.exposure.money_exposure > 0 or context.exposure.credential_exposure:
            if AgentAction.TRIGGER_RECOVERY not in actions:
                actions.append(AgentAction.TRIGGER_RECOVERY)
        
        # Mark campaign critical if high risk campaign
        if context.campaign_status in ["CRITICAL", "HIGH_RISK"]:
            if AgentAction.MARK_CAMPAIGN_CRITICAL not in actions:
                actions.append(AgentAction.MARK_CAMPAIGN_CRITICAL)
        
        return actions

    def determine_intervention_level(self, final_risk: int) -> InterventionLevel:
        if final_risk >= config.risk_threshold_critical:
            return InterventionLevel.CRITICAL
        elif final_risk >= config.risk_threshold_high:
            return InterventionLevel.HIGH_RISK
        elif final_risk >= config.risk_threshold_medium:
            return InterventionLevel.STRONG_WARNING
        elif final_risk >= config.risk_threshold_low if hasattr(config, 'risk_threshold_low') else 31:
            return InterventionLevel.WARNING
        else:
            return InterventionLevel.LOG

    def recommend_recovery_actions(self, context: DecisionContext) -> List[RecoveryAction]:
        """Recommend recovery actions based on exposure and context."""
        actions = []
        
        if context.exposure.money_exposure > 0:
            actions.extend([
                RecoveryAction.CONTACT_BANK,
                RecoveryAction.FREEZE_ACCOUNT,
                RecoveryAction.CALL_1930,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
        
        if context.exposure.credential_exposure or context.exposure.otp_exposure:
            actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.CONTACT_BANK
            ])
        
        if context.exposure.device_access_exposure:
            actions.append(RecoveryAction.REVOKE_REMOTE_ACCESS)
        
        if context.exposure.personal_info_exposure:
            actions.extend([
                RecoveryAction.CHANGE_CREDENTIALS,
                RecoveryAction.REPORT_CYBER_FRAUD
            ])
        
        # Always recommend preserving evidence
        actions.append(RecoveryAction.PRESERVE_EVIDENCE)
        
        # Contact trusted family if consent exists
        if context.user_preferences.get("trusted_contact_consent", False):
            actions.append(RecoveryAction.CONTACT_TRUSTED_FAMILY)
        
        # Deduplicate while preserving order
        seen = set()
        unique_actions = []
        for a in actions:
            if a not in seen:
                seen.add(a)
                unique_actions.append(a)
        
        return unique_actions

    def make_decision(self, context: DecisionContext) -> Dict[str, Any]:
        """Main decision making function."""
        final_risk = self.calculate_final_risk(context)
        risk_level = self.determine_risk_level(final_risk)
        actions = self.determine_actions(context, final_risk)
        intervention_level = self.determine_intervention_level(final_risk)
        recovery_actions = self.recommend_recovery_actions(context)
        
        notify_trusted = AgentAction.NOTIFY_TRUSTED_CONTACT in actions
        recovery_required = AgentAction.TRIGGER_RECOVERY in actions
        
        # Determine recommended action string
        action_map = {
            RiskLevel.SAFE: "NO_ACTION",
            RiskLevel.LOW: "MONITOR",
            RiskLevel.MEDIUM: "WARN_USER",
            RiskLevel.HIGH: "STRONG_WARNING",
            RiskLevel.CRITICAL: "STOP_AND_VERIFY",
        }
        recommended_action = action_map.get(risk_level, "MONITOR")
        
        return {
            "final_risk_score": final_risk,
            "risk_level": risk_level,
            "actions": actions,
            "intervention_level": intervention_level,
            "recommended_action": recommended_action,
            "notify_trusted_contact": notify_trusted,
            "recovery_required": recovery_required,
            "recovery_actions": recovery_actions
        }


decision_engine = AgentDecisionEngine()
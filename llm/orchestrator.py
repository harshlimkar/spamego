import uuid
import logging
from datetime import datetime
from typing import Dict, Any, Optional, List
from dataclasses import dataclass
import sys
import os

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

from core.keyword_engine import KeywordEngine
from core.rule_engine import RuleEngine
from core.risk_engine import RiskEngine
from backend.app.services.ml_analysis_service import ml_service

from llm.schemas import (
    AgentEventInput, AgentDecision, AgentAnalysisResult,
    ExposureAssessment, LegitimacyAssessment, ScamStage,
    AttackerIntent, RiskLevel, AgentAction, AgentAlert, AlertType
)
from llm.config import config
from llm.database import AgentDatabaseService
from llm.groq_client import groq_client
from llm.extraction import intent_extractor, stage_extractor, exposure_extractor
from llm.campaign import CampaignCorrelator
from llm.verification import LegitimacyChecker
from llm.decision import decision_engine, DecisionContext, InterventionLevel

logger = logging.getLogger(__name__)


@dataclass
class PipelineResult:
    event: AgentEventInput
    analysis: AgentAnalysisResult
    campaign_id: Optional[str]
    decision: AgentDecision
    alerts: List[AgentAlert]


class ScameGoAgent:
    def __init__(self, db_session):
        self.db = AgentDatabaseService(db_session)
        self.keyword_engine = KeywordEngine()
        self.rule_engine = RuleEngine()
        self.risk_engine = RiskEngine()
        self.campaign_correlator = CampaignCorrelator(self.db)
        self.legitimacy_checker = LegitimacyChecker()
        self.audit_steps = []

    def _audit(self, event_id: str, user_id: int, step: str, details: Dict = None):
        """Log audit trail step."""
        self.audit_steps.append(step)
        self.db.log_audit(type('Audit', (), {
            'event_id': event_id,
            'user_id': user_id,
            'step': step,
            'details': details or {}
        })())

    def process_event(self, event: AgentEventInput) -> PipelineResult:
        """Main event processing pipeline."""
        self.audit_steps = []
        self._audit(event.event_id, event.user_id, "EVENT_RECEIVED", {"event_type": event.event_type.value})
        
        # 1. Validate & Normalize (basic validation)
        if not event.content or not event.content.strip():
            raise ValueError("Event content cannot be empty")
        
        # 2. ML Analysis
        ml_result = ml_service.analyze_text(event.content)
        self._audit(event.event_id, event.user_id, "ML_ANALYZED", ml_result)
        
        # 3. Rule/Keyword Analysis
        kw_result = self.keyword_engine.analyze_text(event.content)
        rule_result = self.rule_engine.evaluate_rules(kw_result["categories"], kw_result["keywords_detected"])
        self._audit(event.event_id, event.user_id, "RULES_EVALUATED", {
            "keywords": kw_result,
            "rules": rule_result
        })
        
        # 4. Verification/Legitimacy Check
        legitimacy = self.legitimacy_checker.check_legitimacy(
            event.sender, event.content, event.metadata
        )
        ver_risk_modifier = self.legitimacy_checker.get_risk_modifier(legitimacy)
        self._audit(event.event_id, event.user_id, "VERIFICATION_COMPLETED", {
            "legitimacy": legitimacy.model_dump(),
            "risk_modifier": ver_risk_modifier
        })
        
        # 5. Calculate base risk
        risk_result = self.risk_engine.calculate_risk(
            kw_result["keyword_weight"],
            rule_result["rule_risk_score"],
            ver_risk_modifier
        )
        
        # 6. Extract Intent
        intent_signals = intent_extractor.extract_intents(event.content)
        intents = [s.intent for s in intent_signals]
        self._audit(event.event_id, event.user_id, "INTENT_EXTRACTED", {
            "intents": [i.value for i in intents],
            "signals": [{"intent": s.intent.value, "confidence": s.confidence} for s in intent_signals]
        })
        
        # 7. Extract Stage (considering campaign context later)
        # For now, extract from current event
        stage, stage_confidence = stage_extractor.extract_stage(event.content)
        self._audit(event.event_id, event.user_id, "STAGE_EXTRACTED", {
            "stage": stage.value,
            "confidence": stage_confidence
        })
        
        # 8. Extract Exposure
        exposure_data = exposure_extractor.extract_exposure(event.content, intents, event.metadata)
        exposure = ExposureAssessment(**exposure_data)
        self._audit(event.event_id, event.user_id, "EXPOSURE_EXTRACTED", exposure.model_dump())
        
        # 9. Campaign Correlation
        event_data_for_campaign = {
            "sender": event.sender,
            "channel": event.channel.value,
            "timestamp": event.timestamp,
            "stage": stage.value,
            "risk_score": risk_result["score"],
            "categories": kw_result["categories"],
            "intent": [i.value for i in intents]
        }
        
        campaign_match = self.campaign_correlator.find_matching_campaign(event.user_id, event_data_for_campaign)
        
        if campaign_match:
            campaign_id = campaign_match.campaign_id
            self._audit(event.event_id, event.user_id, "CAMPAIGN_MATCHED", {
                "campaign_id": campaign_id,
                "confidence": campaign_match.confidence,
                "reasons": campaign_match.match_reasons
            })
        else:
            campaign_id = self.campaign_correlator.create_campaign_id(event_data_for_campaign)
            self._audit(event.event_id, event.user_id, "CAMPAIGN_CREATED", {"campaign_id": campaign_id})
        
        # Get/update campaign
        campaign = self.db.get_or_create_campaign(campaign_id, event.user_id)
        
        # Update campaign with new event
        campaign = self.db.add_campaign_event(campaign_id, event_data_for_campaign)
        
        # Update campaign stage
        if stage != ScamStage.UNKNOWN and stage != ScamStage.BENIGN:
            campaign.current_stage = stage.value
        
        # Calculate progression velocity
        velocity_data = self.campaign_correlator.calculate_progression_velocity(campaign)
        
        # Assess campaign risk
        campaign_risk, campaign_status = self.campaign_correlator.assess_campaign_risk(campaign, risk_result["score"])
        campaign.risk_score = campaign_risk
        campaign.status = campaign_status.value
        self.db.db.commit()
        
        self._audit(event.event_id, event.user_id, "CAMPAIGN_UPDATED", {
            "campaign_risk": campaign_risk,
            "campaign_status": campaign_status.value,
            "velocity": velocity_data["velocity"]
        })
        
        # 10. Build analysis result
        analysis = AgentAnalysisResult(
            classification=ml_result.get("scam_label", "UNKNOWN"),
            risk_score=risk_result["score"],
            confidence=ml_result.get("confidence", 0.0),
            stage=stage,
            intent=intents,
            signals=kw_result["categories"] + rule_result.get("triggered_rules", []),
            ml_result=ml_result,
            rule_result={
                "keyword_weight": kw_result["keyword_weight"],
                "categories": kw_result["categories"],
                "triggered_rules": rule_result.get("triggered_rules", []),
                "rule_risk_score": rule_result.get("rule_risk_score", 0)
            },
            verification_result={
                "status": legitimacy.sender_status,
                "risk_modifier": ver_risk_modifier,
                "legitimacy": legitimacy.model_dump()
            }
        )
        
        # 11. Optional Groq Reasoning
        groq_reasoning = None
        if config.groq_enabled:
            groq_reasoning = self._get_groq_reasoning(analysis, campaign, velocity_data, exposure, legitimacy)
            if groq_reasoning and groq_reasoning.success:
                self._audit(event.event_id, event.user_id, "GROQ_REASONING_COMPLETED", {
                    "stage": groq_reasoning.content.get("stage") if isinstance(groq_reasoning.content, dict) else None,
                    "confidence": groq_reasoning.content.get("confidence") if isinstance(groq_reasoning.content, dict) else None
                })
                
                # Update stage/intent from Groq if high confidence
                try:
                    groq_data = groq_reasoning.content if isinstance(groq_reasoning.content, dict) else {}
                    if groq_data.get("confidence", 0) > 0.8:
                        if groq_data.get("stage"):
                            stage = ScamStage(groq_data["stage"])
                        if groq_data.get("intent"):
                            intents = [AttackerIntent(i) for i in groq_data["intent"] if i in [e.value for e in AttackerIntent]]
                except Exception as e:
                    logger.warning(f"Failed to parse Groq reasoning: {e}")
        
        # 12. Agent Decision
        decision_context = DecisionContext(
            risk_score=risk_result["score"],
            risk_level=RiskLevel(risk_result["level"]),
            confidence=ml_result.get("confidence", 0.0),
            stage=stage,
            intent=intents,
            exposure=exposure,
            legitimacy=legitimacy,
            campaign_risk=campaign_risk,
            campaign_status=campaign_status.value,
            progression_velocity=velocity_data["velocity"],
            user_preferences={
                "trusted_contact_consent": self._check_trusted_contact_consent(event.user_id)
            }
        )
        
        decision_result = decision_engine.make_decision(decision_context)
        
        self._audit(event.event_id, event.user_id, "AGENT_DECISION", decision_result)
        
        # 13. Build final decision object
        decision = AgentDecision(
            event_id=event.event_id,
            campaign_id=campaign_id,
            risk_score=decision_result["final_risk_score"],
            risk_level=decision_result["risk_level"],
            stage=stage,
            intent=intents,
            exposure=exposure,
            legitimacy=legitimacy,
            explanation=groq_reasoning.content.get("explanation", "") if groq_reasoning and groq_reasoning.success and isinstance(groq_reasoning.content, dict) else self._generate_fallback_explanation(analysis, exposure, legitimacy),
            recommended_action=decision_result["recommended_action"],
            intervention_level=decision_result["intervention_level"].value,
            actions=decision_result["actions"],
            notify_trusted_contact=decision_result["notify_trusted_contact"],
            recovery_required=decision_result["recovery_required"],
            recovery_actions=[a.value for a in decision_result["recovery_actions"]],
            audit_trail=self.audit_steps
        )
        
        # 14. Persist
        self.db.save_event(event)
        self.db.save_decision(decision)
        self.db.save_exposure(exposure, event.event_id, campaign_id, event.user_id)
        
        # 15. Generate alerts
        alerts = self._generate_alerts(event, decision, campaign_id)
        for alert in alerts:
            self.db.save_alert(alert)
            self._audit(event.event_id, event.user_id, "ALERT_CREATED", {
                "alert_id": alert.alert_id,
                "type": alert.alert_type.value,
                "severity": alert.severity.value
            })
        
        # 16. Log recovery actions if needed
        if decision.recovery_required:
            for recovery_action in decision_result["recovery_actions"]:
                self.db.log_recovery_action(
                    event.user_id, campaign_id, event.event_id,
                    recovery_action, "RECOMMENDED",
                    {"risk_score": decision.risk_score, "stage": stage.value}
                )
            self._audit(event.event_id, event.user_id, "RECOVERY_RECOMMENDED", {
                "actions": [a.value for a in decision_result["recovery_actions"]]
            })
        
        return PipelineResult(
            event=event,
            analysis=analysis,
            campaign_id=campaign_id,
            decision=decision,
            alerts=alerts
        )

    def _get_groq_reasoning(self, analysis: AgentAnalysisResult, campaign, velocity_data, exposure, legitimacy) -> Optional[Any]:
        """Get contextual reasoning from Groq."""
        try:
            structured_signals = {
                "ml_classification": analysis.classification,
                "ml_confidence": analysis.confidence,
                "ml_risk_score": analysis.risk_score,
                "rule_signals": analysis.rule_result.get("triggered_rules", []),
                "keyword_categories": analysis.rule_result.get("categories", []),
                "triggered_rules": analysis.rule_result.get("triggered_rules", []),
                "sender_verification": legitimacy.sender_status,
                "sender_reputation": "UNKNOWN",
                "campaign_id": campaign.campaign_id if campaign else "NONE",
                "campaign_stage": campaign.current_stage if campaign else "UNKNOWN",
                "campaign_risk": campaign.risk_score if campaign else 0,
                "campaign_event_count": campaign.event_count if campaign else 0,
                "stage_progression": campaign.stage_progression if campaign else [],
                "money_exposure": exposure.money_exposure,
                "credential_exposure": exposure.credential_exposure,
                "otp_exposure": exposure.otp_exposure,
                "device_access_exposure": exposure.device_access_exposure,
                "intent_signals": [i.value for i in analysis.intent],
                "progression_velocity": velocity_data["velocity"]
            }
            
            # This would be async in real usage, but we call sync for simplicity
            import asyncio
            try:
                loop = asyncio.get_event_loop()
            except RuntimeError:
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
            
            return loop.run_until_complete(groq_client.analyze_scam_context(structured_signals))
        except Exception as e:
            logger.error(f"Groq reasoning failed: {e}")
            return None

    def _generate_fallback_explanation(self, analysis: AgentAnalysisResult, exposure: ExposureAssessment, legitimacy: LegitimacyAssessment) -> str:
        """Generate fallback explanation without Groq."""
        parts = []
        
        if analysis.classification == "SCAM":
            parts.append("This appears to be a scam attempt.")
        elif analysis.classification == "SPAM":
            parts.append("This message appears to be spam.")
        else:
            parts.append("This message appears safe.")
        
        if analysis.stage != ScamStage.UNKNOWN and analysis.stage != ScamStage.BENIGN:
            stage_descriptions = {
                ScamStage.PRETEXTING: "The sender is pretending to be from a trusted organization.",
                ScamStage.URGENCY: "The message creates false urgency to pressure you.",
                ScamStage.CREDENTIAL_HARVESTING: "The sender is asking for sensitive information like OTP or passwords.",
                ScamStage.EXPLOITATION: "The sender is trying to get you to send money or grant device access.",
                ScamStage.ISOLATION: "The sender is trying to isolate you from help.",
            }
            if analysis.stage in stage_descriptions:
                parts.append(stage_descriptions[analysis.stage])
        
        if exposure.money_exposure > 0:
            parts.append(f"Potential financial exposure: ₹{exposure.money_exposure:,.0f}.")
        
        if exposure.otp_exposure:
            parts.append("They are requesting your OTP.")
        
        if not legitimacy.verified:
            parts.append("The sender could not be verified as legitimate.")
        
        return " ".join(parts)

    def _check_trusted_contact_consent(self, user_id: int) -> bool:
        """Check if user has trusted contact with consent for alerts."""
        contacts = self.db.get_trusted_contacts(user_id)
        return any(c.consent_status for c in contacts)

    def _generate_alerts(self, event: AgentEventInput, decision: AgentDecision, campaign_id: Optional[str]) -> List[AgentAlert]:
        """Generate appropriate alerts based on decision."""
        alerts = []
        
        risk_level = decision.risk_level
        
        # Determine alert type based on risk level and context
        if risk_level == RiskLevel.CRITICAL:
            alert_type = AlertType.CRITICAL_SCAM
            title = "Critical Scam Alert"
        elif risk_level == RiskLevel.HIGH:
            alert_type = AlertType.HIGH_RISK
            title = "High Risk Detected"
        elif risk_level == RiskLevel.MEDIUM:
            alert_type = AlertType.USER_WARNING
            title = "Suspicious Activity"
        else:
            alert_type = AlertType.USER_WARNING
            title = "Security Notice"
        
        # Channel-specific alerts
        if event.channel.value == "sms" and risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            alert_type = AlertType.SMS_WARNING
        elif event.channel.value == "call" and risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            alert_type = AlertType.CALL_WARNING
        elif event.channel.value == "payment" and risk_level in [RiskLevel.HIGH, RiskLevel.CRITICAL]:
            alert_type = AlertType.PAYMENT_WARNING
        
        alert = AgentAlert(
            user_id=event.user_id,
            event_id=event.event_id,
            campaign_id=campaign_id,
            severity=risk_level,
            alert_type=alert_type,
            title=title,
            plain_language_reason=decision.explanation,
            recommended_action=decision.recommended_action
        )
        alerts.append(alert)
        
        # Trusted contact alert
        if decision.notify_trusted_contact:
            tc_alert = AgentAlert(
                user_id=event.user_id,
                event_id=event.event_id,
                campaign_id=campaign_id,
                severity=RiskLevel.CRITICAL,
                alert_type=AlertType.TRUSTED_CONTACT_ALERT,
                title="Family Alert: Critical Scam Risk",
                plain_language_reason=f"A critical scam risk was detected for your family member. {decision.explanation}",
                recommended_action="Contact them immediately and advise them not to share any information or make payments."
            )
            alerts.append(tc_alert)
        
        # Recovery alert
        if decision.recovery_required:
            rec_alert = AgentAlert(
                user_id=event.user_id,
                event_id=event.event_id,
                campaign_id=campaign_id,
                severity=RiskLevel.CRITICAL,
                alert_type=AlertType.RECOVERY_ALERT,
                title="Recovery Actions Required",
                plain_language_reason="Immediate recovery actions are recommended due to potential exposure.",
                recommended_action="; ".join(decision.recovery_actions)
            )
            alerts.append(rec_alert)
        
        return alerts


def create_agent(db_session) -> ScameGoAgent:
    """Factory function to create agent instance."""
    return ScameGoAgent(db_session)
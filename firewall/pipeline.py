import os
import sys
from datetime import datetime, timezone

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from .messaging import messaging
from .entities import entity_extractor, link_analyzer
from .ml_adapter import ml_analyze
from .intent import intent_classifier
from .otp import otp_intelligence
from .killchain import kill_chain
from .verify import UnifiedVerifier
from .edge_model import edge_model
from .risk import risk_engine
from .campaign_engine import campaign_manager
from .intervention import intervention_engine
from .family import family_alert_service
from .recovery import recovery_plan

VERDICT_BY_LEVEL = {
    "safe": "SAFE",
    "low": "MOSTLY SAFE",
    "medium": "SUSPICIOUS",
    "high": "POSSIBLE SCAM",
    "critical": "SCAM / CRITICAL",
}


def _level_for(score):
    from .risk import level_for_score
    return level_for_score(score)


class ScamFirewall:
    def __init__(self):
        self.verifier = UnifiedVerifier()
        self._heuristic_engine = None

    def heuristic_engine(self):
        if self._heuristic_engine is None:
            from core.keyword_engine import KeywordEngine
            from core.rule_engine import RuleEngine
            from risk_scoring.risk_engine import RiskEngine
            self._heuristic_engine = {
                "keywords": KeywordEngine(),
                "rules": RuleEngine(),
                "risk": RiskEngine(),
            }
        return self._heuristic_engine

    def _normalize_channel(self, channel):
        return (channel or "sms").lower()

    def _build_text(self, event, channel):
        text = event.get("text") or event.get("content") or event.get("transcript") or event.get("call_speech") or ""
        if not text:
            parts = []
            if event.get("amount_inr"):
                parts.append("Payment of Rs %s requested" % event["amount_inr"])
            if event.get("upi_id"):
                parts.append("to UPI %s" % event["upi_id"])
            if event.get("recipient"):
                parts.append("to %s" % event["recipient"])
            elif event.get("url"):
                parts.append("contains link %s" % event["url"])
            text = " ".join(parts)
        return text

    def analyze_event(self, event):
        channel = self._normalize_channel(event.get("channel"))
        text = self._build_text(event, channel)
        sender = event.get("sender") or event.get("number") or ""
        
        # 1. Process via Multilingual Intelligence Pipeline
        from .language import language_pipeline
        threat_input = language_pipeline.process(
            text=text,
            channel=channel,
            sender=sender,
            event_id=event.get("id", ""),
            timestamp=event.get("timestamp", "")
        )
        
        normalized = threat_input.normalized_content
        language = threat_input.detected_language
        translated = threat_input.english_content

        extraction = entity_extractor.extract(text)
        explicit_urls = []
        if event.get("url"):
            explicit_urls.append(event["url"])
        if event.get("upi_id") and event["upi_id"] not in extraction.upi_ids:
            extraction.upi_ids.append(event["upi_id"])
        if event.get("amount_inr"):
            extraction.amounts_inr.append(float(event["amount_inr"]))
        if event.get("recipient"):
            extraction.organization_claims.append(str(event["recipient"]))
        all_urls = list(dict.fromkeys(extraction.urls + explicit_urls))
        link_findings = link_analyzer.analyze_many(all_urls) if all_urls else []

        # Run ML on canonical English translation + original text fusion
        ml_result = ml_analyze(translated)
        ml_label = ml_result.get("scam_label", "UNKNOWN")
        ml_conf = ml_result.get("confidence", 0.0)
        ml_score = ml_result.get("risk_score", 30)

        # Fallback to original text if translation returned benign but original text had raw scam indicators
        if ml_label == "SAFE" and text != translated:
            orig_ml = ml_analyze(text)
            if orig_ml.get("scam_label") in ("SCAM", "SPAM"):
                ml_result = orig_ml
                ml_label = orig_ml["scam_label"]
                ml_conf = orig_ml["confidence"]
                ml_score = orig_ml["risk_score"]

        if channel in ("sms", "social"):
            ver_sender = self.verifier.verify_sender(sender, channel) if sender else None
        else:
            ver_sender = self.verifier.verify_sender(sender, channel) if sender else None
        ver_links = []
        for link in link_findings:
            if link["is_suspicious"] or link["matches_trusted"]:
                ver_links.append(self.verifier.verify_domain(link["domain"], link["url"]))
        primary_verification = ver_sender
        if not primary_verification and ver_links:
            primary_verification = ver_links[0]
        if not primary_verification:
            primary_verification = self.verifier.verify_sender("", channel)

        sender_status = primary_verification.status if primary_verification else ""
        intents = intent_classifier.detect(translated, extraction, ml_label)
        otp_finding = otp_intelligence.analyze(normalized, channel, sender_status)
        stage = kill_chain.detect(translated, intents, otp_finding, extraction)

        edge_score = edge_model.score(translated)
        he = self.heuristic_engine()
        kw = he["keywords"].analyze_text(translated)
        rules = he["rules"].evaluate_rules(kw["categories"], kw)
        heuristic = he["risk"].calculate_risk(kw["keyword_weight"], rules["rule_risk_score"], 0)
        heuristic_score = heuristic["score"]

        risk = risk_engine.calculate(
            content_score=ml_score,
            heuristic_score=heuristic_score,
            edge_score=edge_score,
            ml_label=ml_label,
            ml_confidence=ml_conf,
            intents=intents,
            stage=stage,
            otp=otp_finding,
            verification=primary_verification,
            links=link_findings,
            amounts=extraction.amounts_inr,
        )

        is_payment = channel == "payment" or "payment_request" == (intents[0].name if intents else "")
        event_level = risk.level
        campaign = campaign_manager.process(
            event, stage, risk.score, channel, extraction,
            count_money=is_payment or event_level in ("medium", "high", "critical"),
        )
        if campaign.risk_score > risk.score:
            risk.score = campaign.risk_score
            risk.level = _level_for(campaign.risk_score)

        intervention = intervention_engine.decide(
            risk.level, payment_amount=max(extraction.amounts_inr) if extraction.amounts_inr else None, is_payment=is_payment,
        )
        family = family_alert_service.maybe_alert(risk.level, campaign.exposure, channel)
        if risk.level in ("high", "critical"):
            recovery = recovery_plan()
        else:
            recovery = None
        support_sms = None
        if risk.level in ("high", "critical"):
            support_sms = self._support_sms(risk, extraction, intents, otp_finding)

        return {
            "channel": channel,
            "timestamp": event.get("timestamp") or datetime.now(timezone.utc).isoformat(),
            "sender": sender,
            "language": language,
            "detected_script": threat_input.detected_script,
            "is_code_mixed": threat_input.is_code_mixed,
            "english_content": translated,
            "translation_confidence": threat_input.translation_confidence,
            "translation_status": threat_input.translation_status,
            "protected_tokens": threat_input.protected_tokens,
            "text": text,
            "normalized": normalized,
            "translated_signal_text": translated,
            "regional_signals": threat_input.protected_tokens,
            "verification": _as_obj(primary_verification),
            "link_findings": link_findings,
            "otp": _as_obj(otp_finding),
            "entities": _as_obj(extraction),
            "ml": ml_result,
            "edge_score": risk.edge_score,
            "intents": [_as_obj(i) for i in intents],
            "stage": _as_obj(stage),
            "risk": _as_obj(risk),
            "campaign": _as_obj(campaign),
            "intervention": _as_obj(intervention),
            "family_alert": _as_obj(family),
            "recovery": recovery,
            "support_sms": support_sms,
            "verdict": VERDICT_BY_LEVEL.get(risk.level, "UNKNOWN"),
            "headline": self._headline(risk, intents),
        }

    def _support_sms(self, risk, extraction, intents, otp):
        parts = ["SCAM ALERT: This interaction appears to impersonate a service and requests sensitive action."]
        if intents and intents[0].name in ("otp_request", "otp_disclosure"):
            parts.append("Do not share the OTP.")
        if extraction.amounts_inr:
            parts.append("Money involved: Rs %s." % int(extraction.amounts_inr[0]))
        return " ".join(parts)

    def _headline(self, risk, intents):
        if intents and intents[0].name == "bank_impersonation":
            return "Possible Bank Impersonation"
        if intents and intents[0].name == "government_impersonation":
            return "Possible Government Impersonation"
        if intents and intents[0].name in ("otp_request", "otp_disclosure"):
            return "OTP Request Scam"
        if intents and intents[0].name == "payment_request":
            return "Payment Request Risk"
        if intents and intents[0].name == "remote_access":
            return "Remote Access Risk"
        if intents and intents[0].name == "prize_lottery":
            return "Prize / Lottery Scam"
        if risk.level in ("high", "critical"):
            return "High-Risk Interaction"
        return "Routine Check"


def _as_obj(value):
    import dataclasses
    if dataclasses.is_dataclass(value):
        return dataclasses.asdict(value)
    return value


firewall = ScamFirewall()
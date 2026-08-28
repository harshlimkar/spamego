from .schema import (
    RiskLevel,
    KILL_CHAIN_STAGES,
    INTENT_TAXONOMY,
    Intent,
    ScamStage,
    LinkFinding,
    OtpFinding,
    EntityExtraction,
    Verification,
    RiskResult,
    Exposure,
    CampaignInfo,
    Intervention,
    FamilyAlertDecision,
    to_dict,
)
from .pipeline import firewall, ScamFirewall
from .campaign_engine import campaign_manager, load_history
from .edge_model import edge_model
from .recovery import recovery_plan, reporting_plan, VERIFIED_CONTACTS
from .verify import UnifiedVerifier

analyze = firewall.analyze_event
verifier = firewall.verifier


def analyze_event(event):
    return firewall.analyze_event(event)


__all__ = [
    "RiskLevel",
    "KILL_CHAIN_STAGES",
    "INTENT_TAXONOMY",
    "Intent",
    "ScamStage",
    "LinkFinding",
    "OtpFinding",
    "EntityExtraction",
    "Verification",
    "RiskResult",
    "Exposure",
    "CampaignInfo",
    "Intervention",
    "FamilyAlertDecision",
    "to_dict",
    "firewall",
    "ScamFirewall",
    "campaign_manager",
    "load_history",
    "edge_model",
    "recovery_plan",
    "reporting_plan",
    "VERIFIED_CONTACTS",
    "UnifiedVerifier",
    "analyze",
    "analyze_event",
    "verifier",
]
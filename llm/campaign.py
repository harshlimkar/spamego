from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass

from llm.schemas import ScamStage, CampaignStatus, EventType, EventChannel
from llm.config import config


@dataclass
class CampaignMatch:
    campaign_id: str
    confidence: float
    match_reasons: List[str]


class CampaignCorrelator:
    def __init__(self, db_service, window_hours: int = None):
        self.db_service = db_service
        self.window_hours = window_hours or config.campaign_window_hours

    def find_matching_campaign(self, user_id: int, event_data: Dict[str, Any]) -> Optional[CampaignMatch]:
        """Find an existing campaign that matches the new event."""
        sender = event_data.get("sender")
        channels = event_data.get("channel")
        timestamp = event_data.get("timestamp", datetime.utcnow())
        
        if isinstance(timestamp, str):
            timestamp = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        
        cutoff = timestamp - timedelta(hours=self.window_hours)
        
        # Get recent campaigns for user
        campaigns = self.db_service.get_user_campaigns(user_id)
        
        best_match = None
        best_score = 0.0
        
        for campaign in campaigns:
            if campaign.status in [CampaignStatus.RESOLVED, CampaignStatus.DISMISSED]:
                continue
                
            # Check time proximity
            last_activity = campaign.last_activity
            if isinstance(last_activity, str):
                last_activity = datetime.fromisoformat(last_activity.replace('Z', '+00:00'))
            
            if last_activity < cutoff:
                continue
            
            score = 0.0
            reasons = []
            
            # Sender match
            if sender and campaign.sender_numbers:
                if sender in campaign.sender_numbers:
                    score += 0.5
                    reasons.append("same_sender")
            
            # Channel overlap
            if channels and campaign.channels:
                if channels in campaign.channels:
                    score += 0.2
                    reasons.append("same_channel")
            
            # Stage progression compatibility
            current_stage = event_data.get("stage", ScamStage.UNKNOWN)
            if self._is_valid_progression(campaign.current_stage, current_stage):
                score += 0.2
                reasons.append("valid_stage_progression")
            
            # Content similarity (simplified - could use embeddings)
            # For now, just check if similar categories
            if event_data.get("categories") and campaign.stage_progression:
                recent_cats = self._extract_categories(campaign.stage_progression[-3:])
                new_cats = set(event_data.get("categories", []))
                if recent_cats and new_cats:
                    overlap = len(recent_cats & new_cats) / len(recent_cats | new_cats)
                    score += overlap * 0.1
                    if overlap > 0:
                        reasons.append("category_overlap")
            
            if score > best_score:
                best_score = score
                best_match = CampaignMatch(campaign.campaign_id, score, reasons)
        
        # Only return match if confidence is reasonable
        if best_match and best_match.confidence >= 0.3:
            return best_match
        
        return None

    def _is_valid_progression(self, from_stage: str, to_stage: str) -> bool:
        """Check if stage progression is valid."""
        valid_progressions = {
            "DELIVERY": ["PRETEXTING", "URGENCY", "BENIGN", "UNKNOWN"],
            "PRETEXTING": ["URGENCY", "ISOLATION", "CREDENTIAL_HARVESTING", "BENIGN", "UNKNOWN"],
            "URGENCY": ["ISOLATION", "CREDENTIAL_HARVESTING", "EXPLOITATION", "BENIGN", "UNKNOWN"],
            "ISOLATION": ["CREDENTIAL_HARVESTING", "EXPLOITATION", "BENIGN", "UNKNOWN"],
            "CREDENTIAL_HARVESTING": ["EXPLOITATION", "OBJECTIVE_COMPLETION", "BENIGN", "UNKNOWN"],
            "EXPLOITATION": ["OBJECTIVE_COMPLETION", "BENIGN", "UNKNOWN"],
            "OBJECTIVE_COMPLETION": ["BENIGN", "UNKNOWN"],
            "BENIGN": ["BENIGN", "UNKNOWN"],
            "UNKNOWN": list(ScamStage.__members__.keys()),
        }
        
        valid_next = valid_progressions.get(from_stage, list(ScamStage.__members__.keys()))
        return to_stage in valid_next

    def _extract_categories(self, progression: List[Dict]) -> set:
        cats = set()
        for event in progression:
            if event.get("categories"):
                cats.update(event["categories"])
        return cats

    def create_campaign_id(self, event_data: Dict[str, Any]) -> str:
        """Generate a new campaign ID."""
        sender = event_data.get("sender", "unknown")
        timestamp = event_data.get("timestamp", datetime.utcnow())
        if isinstance(timestamp, datetime):
            ts_str = timestamp.strftime("%Y%m%d%H%M%S")
        else:
            ts_str = "unknown"
        return f"CAMP-{sender.replace('+', '').replace('-', '')}-{ts_str}"

    def calculate_progression_velocity(self, campaign) -> Dict[str, Any]:
        """Calculate how quickly the campaign is progressing through stages."""
        progression = campaign.stage_progression or []
        
        if len(progression) < 2:
            return {
                "velocity": "UNKNOWN",
                "stage_transitions": [],
                "avg_transition_seconds": None
            }
        
        transitions = []
        for i in range(1, len(progression)):
            prev = progression[i-1]
            curr = progression[i]
            
            prev_time = prev.get("timestamp")
            curr_time = curr.get("timestamp")
            
            if prev_time and curr_time:
                if isinstance(prev_time, str):
                    prev_time = datetime.fromisoformat(prev_time.replace('Z', '+00:00'))
                if isinstance(curr_time, str):
                    curr_time = datetime.fromisoformat(curr_time.replace('Z', '+00:00'))
                
                delta = (curr_time - prev_time).total_seconds()
                
                transitions.append({
                    "from": prev.get("stage", "UNKNOWN"),
                    "to": curr.get("stage", "UNKNOWN"),
                    "time_seconds": delta
                })
        
        if not transitions:
            return {"velocity": "UNKNOWN", "stage_transitions": [], "avg_transition_seconds": None}
        
        avg_seconds = sum(t["time_seconds"] for t in transitions) / len(transitions)
        
        if avg_seconds < 300:  # 5 minutes
            velocity = "RAPID"
        elif avg_seconds < 3600:  # 1 hour
            velocity = "MODERATE"
        else:
            velocity = "SLOW"
        
        return {
            "velocity": velocity,
            "stage_transitions": transitions,
            "avg_transition_seconds": avg_seconds
        }

    def assess_campaign_risk(self, campaign, new_event_risk: int) -> Tuple[int, CampaignStatus]:
        """Assess overall campaign risk based on history and new event."""
        base_risk = campaign.risk_score
        
        # Increase risk for repeated interactions
        event_factor = min(campaign.event_count * 5, 30)
        
        # Velocity factor
        velocity_data = self.calculate_progression_velocity(campaign)
        velocity = velocity_data.get("velocity", "UNKNOWN")
        
        velocity_factor = 0
        if velocity == "RAPID":
            velocity_factor = 20
        elif velocity == "MODERATE":
            velocity_factor = 10
        
        # Stage factor - later stages are riskier
        stage_risk = {
            "DELIVERY": 0,
            "PRETEXTING": 10,
            "URGENCY": 20,
            "ISOLATION": 25,
            "CREDENTIAL_HARVESTING": 35,
            "EXPLOITATION": 45,
            "OBJECTIVE_COMPLETION": 50,
            "BENIGN": -20,
            "UNKNOWN": 0,
        }
        stage_factor = stage_risk.get(campaign.current_stage, 0)
        
        # New event risk contribution
        new_event_factor = new_event_risk // 3
        
        total_risk = min(100, base_risk + event_factor + velocity_factor + stage_factor + new_event_factor)
        
        # Determine status
        if total_risk >= 90:
            status = CampaignStatus.CRITICAL
        elif total_risk >= 70:
            status = CampaignStatus.HIGH_RISK
        elif total_risk >= 40:
            status = CampaignStatus.ACTIVE
        else:
            status = CampaignStatus.ACTIVE
        
        return total_risk, status
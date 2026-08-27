import uuid
import datetime
from database.repository import CampaignRepository, EventRepository

class CampaignEngine:
    def __init__(self):
        self.campaign_repo = CampaignRepository()
        self.event_repo = EventRepository()

    def process_event(self, sender_number, event_risk, categories, event_type, content):
        # A simple correlation strategy for the hackathon:
        # Group by sender_number for now. If a campaign exists for this sender, add to it.
        # In a real app, you'd check time proximity and shared keywords across unknown numbers.
        
        # We will use the sender_number as a pseudo-campaign-id for this demo, 
        # or generate a UUID if it's the first time we see it.
        # To keep it simple: campaign_id = "CAMP-" + sender_number
        campaign_id = f"CAMP-{sender_number.replace('+', '')}"
        
        campaign = self.campaign_repo.get_campaign(campaign_id)
        
        now = datetime.datetime.now().isoformat()
        
        if not campaign:
            # Create new campaign
            self.campaign_repo.create_or_update(
                campaign_id, now, event_risk["score"], event_risk["level"], ",".join(categories)
            )
            final_risk_score = event_risk["score"]
            final_risk_level = event_risk["level"]
        else:
            # Update existing campaign
            existing_cats = set(campaign["categories"].split(",")) if campaign["categories"] else set()
            new_cats = existing_cats.union(set(categories))
            
            # Increase risk because it's a repeated interaction
            new_score = min(100, campaign["risk_score"] + event_risk["score"] // 2)
            
            # Determine new level
            level = "SAFE"
            if new_score >= 85:
                level = "CRITICAL"
            elif new_score >= 70:
                level = "HIGH"
            elif new_score >= 50:
                level = "MEDIUM"
            elif new_score >= 30:
                level = "LOW"
                
            self.campaign_repo.create_or_update(
                campaign_id, now, new_score, level, ",".join(new_cats)
            )
            final_risk_score = new_score
            final_risk_level = level

        # Log the event
        self.event_repo.log_event(
            event_type, sender_number, now, content, event_risk["score"], campaign_id
        )

        return {
            "campaign_id": campaign_id,
            "campaign_risk_score": final_risk_score,
            "campaign_risk_level": final_risk_level
        }

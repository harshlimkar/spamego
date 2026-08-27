from sqlalchemy.orm import Session
from app.models.moderation import ModerationResult, Violation, Alert
from app.database.base import engine, Base
from app.models import user, instagram, content, moderation

# Ensure tables are created
Base.metadata.create_all(bind=engine)

class DatabaseService:
    @staticmethod
    def save_analysis_result(db: Session, text: str, content_type: str, content_id: int, ml_result: dict, user_id: int):
        # 1. Save Moderation Result
        mod_result = ModerationResult(
            content_type=content_type,
            content_id=content_id,
            scam_label=ml_result["scam_label"],
            risk_score=ml_result["risk_score"],
            risk_level="CRITICAL" if ml_result["risk_score"] >= 80 else ("HIGH" if ml_result["risk_score"] >= 60 else "SAFE"),
            confidence=ml_result["confidence"]
        )
        db.add(mod_result)
        
        # 2. If it's a SCAM, generate an Alert and Violation
        if ml_result["scam_label"] == "SCAM":
            violation = Violation(
                user_identifier="Unknown Sender",
                violation_type="SCAM_MESSAGE",
                severity="CRITICAL" if ml_result["risk_score"] >= 80 else "HIGH"
            )
            db.add(violation)
            
            alert = Alert(
                user_id=user_id,
                alert_type="Scam Detected",
                severity="CRITICAL" if ml_result["risk_score"] >= 80 else "HIGH",
                content_preview=text[:100]
            )
            db.add(alert)
            
        db.commit()
        db.refresh(mod_result)
        return mod_result

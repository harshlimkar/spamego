"""
Scam/Spam Analysis Pipeline for ScameGo
Called after collector stores content.
Runs: ML analysis -> violation tracking -> alert generation
"""
import logging
from sqlalchemy.orm import Session
from app.services.ml_analysis_service import ml_service
from app.services.database_service import DatabaseService
from app.models.moderation import ModerationResult, Violation, Alert
from app.models.user import User

logger = logging.getLogger(__name__)

def analyze_content(
    user_id: int,
    content_type: str,  # "comment" or "message"
    content_id: int,
    text: str,
    author: str,
) -> dict:
    if not text or not text.strip():
        return {}

    from app.database.base import SessionLocal
    db = SessionLocal()

    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return {}

        # 1. Run ML Analysis using existing scam classifier
        ml_result = ml_service.analyze_text(text)
        
        if ml_result.get("scam_label") == "ERROR":
            logger.error(f"ML Analysis error: {ml_result.get('error')}")
            return {}

        scam_label = ml_result["scam_label"]
        risk_score = ml_result["risk_score"]
        confidence = ml_result["confidence"]

        # 2. Determine severity level based on risk score
        if risk_score >= 80:
            severity_level = "CRITICAL_SCAM"
        elif risk_score >= 60:
            severity_level = "HIGH_RISK"
        elif risk_score >= 40:
            severity_level = "SUSPICIOUS"
        else:
            severity_level = "SAFE"

        # 3. Store moderation result
        result = ModerationResult(
            content_type=content_type,
            content_id=content_id,
            scam_label=scam_label,
            risk_score=risk_score,
            risk_level=severity_level,
            confidence=confidence,
        )
        db.add(result)

        # 4. Track violations for SCAM and SPAM
        if scam_label in ("SCAM", "SPAM") and risk_score > 30:
            violation = Violation(
                user_identifier=author,
                violation_type=scam_label,
                severity=severity_level,
            )
            db.add(violation)

        # 5. Create alert for SCAM messages
        if scam_label == "SCAM":
            alert = Alert(
                user_id=user.id,
                alert_type="Scam Detected",
                severity=severity_level,
                content_preview=text[:200],
                status="unread",
            )
            db.add(alert)
        elif scam_label == "SPAM" and risk_score >= 60:
            alert = Alert(
                user_id=user.id,
                alert_type="Spam Detected",
                severity=severity_level,
                content_preview=text[:200],
                status="unread",
            )
            db.add(alert)

        db.commit()

        return {
            "scam_label": scam_label,
            "risk_score": risk_score,
            "severity": severity_level,
            "confidence": confidence,
        }
    finally:
        db.close()
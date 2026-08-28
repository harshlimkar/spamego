from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.services.ml_analysis_service import ml_service
from app.services.database_service import DatabaseService
from app.database.base import get_db

import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../")))
from core.models import NormalizedMessage
from core.universal_engine import UniversalScamEngine

router = APIRouter()
universal_engine = UniversalScamEngine()

class TextAnalysisPayload(BaseModel):
    user_id: int = 1  
    text: str
    content_type: str = "sms"
    content_id: int = 0
    conversation_id: str = None
    sender: str = "unknown"

@router.post("/analyze")
async def analyze_text(payload: TextAnalysisPayload, db: Session = Depends(get_db)):
    # 1. Run Offline Universal Engine
    norm_msg = NormalizedMessage(
        source=payload.content_type.upper(),
        sender=payload.sender,
        message=payload.text,
        conversation_id=payload.conversation_id
    )
    universal_result = universal_engine.analyze(norm_msg)
    
    # 2. Run ML Analysis (existing)
    ml_result = ml_service.analyze_text(payload.text)
    
    # 3. Combine results (Trust whichever is higher risk)
    final_risk_score = max(universal_result.risk_score, ml_result.get("scam_score", 0))
    
    combined_result = {
        "universal_analysis": universal_result.dict(),
        "ml_analysis": ml_result,
        "final_risk_score": final_risk_score,
        "scam_label": ml_result.get("scam_label", "SAFE") if final_risk_score < 70 else "SCAM"
    }
    # 4. Save result to Moderation DB
    if ml_result.get("scam_label") != "ERROR":
        saved_record = DatabaseService.save_analysis_result(
            db=db,
            text=payload.text,
            content_type=payload.content_type,
            content_id=payload.content_id,
            ml_result=combined_result,
            user_id=payload.user_id
        )
    
    return combined_result

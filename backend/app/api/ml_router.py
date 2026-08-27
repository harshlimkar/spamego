from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.services.ml_analysis_service import ml_service
from app.services.database_service import DatabaseService
from app.database.base import get_db

router = APIRouter()

class TextAnalysisPayload(BaseModel):
    user_id: int = 1  # Default to 1 for simplicity in ScameGo context
    text: str
    content_type: str = "sms"
    content_id: int = 0

@router.post("/analyze")
async def analyze_text(payload: TextAnalysisPayload, db: Session = Depends(get_db)):
    # 1. Run ML Analysis
    result = ml_service.analyze_text(payload.text)
    
    # 2. Save result to Moderation DB
    if result.get("scam_label") != "ERROR":
        saved_record = DatabaseService.save_analysis_result(
            db=db,
            text=payload.text,
            content_type=payload.content_type,
            content_id=payload.content_id,
            ml_result=result,
            user_id=payload.user_id
        )
    
    return result

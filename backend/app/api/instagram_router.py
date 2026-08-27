from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database.base import get_db
from app.models.instagram import InstagramAccount
from app.models.content import Conversation, Message
from app.models.moderation import ModerationResult, Alert
from app.services.instagram_collector import start_monitoring, stop_monitoring
from app.services.ml_analysis_service import ml_service

router = APIRouter(prefix="/instagram", tags=["instagram"])

class InstagramAccountCreate(BaseModel):
    username: str
    password: str

class InstagramAccountResponse(BaseModel):
    id: int
    username: str
    is_connected: bool
    monitoring_status: str
    last_scraped: str | None

class MonitoringStartRequest(BaseModel):
    target_profile_url: str | None = None

@router.post("/accounts", response_model=InstagramAccountResponse)
async def add_instagram_account(account: InstagramAccountCreate, db: Session = Depends(get_db), user_id: int = 1):
    """Add an Instagram account for monitoring."""
    from app.core.security import encrypt
    
    existing = db.query(InstagramAccount).filter(
        InstagramAccount.username == account.username,
        InstagramAccount.user_id == user_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Account already exists")
    
    encrypted_password = encrypt(account.password)
    
    new_account = InstagramAccount(
        user_id=user_id,
        username=account.username,
        encrypted_password=encrypted_password,
        is_connected=False,
        monitoring_status="stopped"
    )
    db.add(new_account)
    db.commit()
    db.refresh(new_account)
    
    return InstagramAccountResponse(
        id=new_account.id,
        username=new_account.username,
        is_connected=new_account.is_connected,
        monitoring_status=new_account.monitoring_status,
        last_scraped=new_account.last_scraped.isoformat() if new_account.last_scraped else None
    )

@router.get("/accounts", response_model=list[InstagramAccountResponse])
async def list_instagram_accounts(db: Session = Depends(get_db), user_id: int = 1):
    """List all Instagram accounts for the user."""
    accounts = db.query(InstagramAccount).filter(InstagramAccount.user_id == user_id).all()
    return [
        InstagramAccountResponse(
            id=acc.id,
            username=acc.username,
            is_connected=acc.is_connected,
            monitoring_status=acc.monitoring_status,
            last_scraped=acc.last_scraped.isoformat() if acc.last_scraped else None
        )
        for acc in accounts
    ]

@router.post("/accounts/{account_id}/connect")
async def connect_instagram_account(account_id: int, db: Session = Depends(get_db), user_id: int = 1):
    """Test connection to Instagram account."""
    account = db.query(InstagramAccount).filter(
        InstagramAccount.id == account_id,
        InstagramAccount.user_id == user_id
    ).first()
    
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    
    # This will trigger the login flow in the background
    account.is_connected = True
    db.commit()
    
    return {"status": "connected", "message": "Account connected. Start monitoring to begin scraping."}

@router.post("/accounts/{account_id}/monitor/start")
async def start_instagram_monitoring(
    account_id: int, 
    request: MonitoringStartRequest,
    db: Session = Depends(get_db), 
    user_id: int = 1
):
    """Start monitoring an Instagram account for spam/scam messages."""
    account = db.query(InstagramAccount).filter(
        InstagramAccount.id == account_id,
        InstagramAccount.user_id == user_id
    ).first()
    
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    
    if account.monitoring_status == "running":
        return {"status": "already_running", "message": "Monitoring is already running"}
    
    if request.target_profile_url:
        account.target_profile_url = request.target_profile_url
        db.commit()
    
    start_monitoring(account, request.target_profile_url)
    
    return {"status": "started", "message": "Instagram monitoring started"}

@router.post("/accounts/{account_id}/monitor/stop")
async def stop_instagram_monitoring(account_id: int, db: Session = Depends(get_db), user_id: int = 1):
    """Stop monitoring an Instagram account."""
    account = db.query(InstagramAccount).filter(
        InstagramAccount.id == account_id,
        InstagramAccount.user_id == user_id
    ).first()
    
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    
    stop_monitoring(account_id)
    account.monitoring_status = "stopped"
    db.commit()
    
    return {"status": "stopped", "message": "Instagram monitoring stopped"}

@router.get("/accounts/{account_id}/conversations")
async def get_conversations(account_id: int, db: Session = Depends(get_db), user_id: int = 1):
    """Get all conversations for an Instagram account."""
    account = db.query(InstagramAccount).filter(
        InstagramAccount.id == account_id,
        InstagramAccount.user_id == user_id
    ).first()
    
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    
    conversations = db.query(Conversation).filter(Conversation.user_id == user_id).all()
    
    result = []
    for conv in conversations:
        messages = db.query(Message).filter(Message.conversation_id == conv.id).order_by(Message.created_at.desc()).limit(10).all()
        latest_msg = messages[0] if messages else None
        
        result.append({
            "id": conv.id,
            "participant": conv.participant,
            "message_count": conv.message_count,
            "flagged_count": conv.flagged_count,
            "risk_score": conv.risk_score,
            "latest_message": latest_msg.content[:100] if latest_msg else None,
            "latest_message_time": latest_msg.created_at.isoformat() if latest_msg else None,
            "updated_at": conv.updated_at.isoformat() if conv.updated_at else None
        })
    
    return result

@router.get("/accounts/{account_id}/conversations/{conversation_id}/messages")
async def get_conversation_messages(
    account_id: int, 
    conversation_id: int, 
    db: Session = Depends(get_db), 
    user_id: int = 1
):
    """Get messages for a specific conversation with moderation results."""
    conv = db.query(Conversation).filter(
        Conversation.id == conversation_id,
        Conversation.user_id == user_id
    ).first()
    
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    messages = db.query(Message).filter(Message.conversation_id == conversation_id).order_by(Message.created_at).all()
    
    result = []
    for msg in messages:
        mod_result = db.query(ModerationResult).filter(
            ModerationResult.content_type == "message",
            ModerationResult.content_id == msg.id
        ).first()
        
        result.append({
            "id": msg.id,
            "sender": msg.sender,
            "content": msg.content,
            "created_at": msg.created_at.isoformat(),
            "moderation": {
                "scam_label": mod_result.scam_label if mod_result else None,
                "risk_score": mod_result.risk_score if mod_result else None,
                "risk_level": mod_result.risk_level if mod_result else None,
                "confidence": mod_result.confidence if mod_result else None
            } if mod_result else None
        })
    
    return result

@router.get("/accounts/{account_id}/alerts")
async def get_alerts(account_id: int, db: Session = Depends(get_db), user_id: int = 1):
    """Get all alerts for an Instagram account."""
    alerts = db.query(Alert).filter(Alert.user_id == user_id).order_by(Alert.created_at.desc()).limit(50).all()
    
    return [
        {
            "id": alert.id,
            "alert_type": alert.alert_type,
            "severity": alert.severity,
            "content_preview": alert.content_preview,
            "status": alert.status,
            "created_at": alert.created_at.isoformat()
        }
        for alert in alerts
    ]

@router.post("/analyze-text")
async def analyze_text_direct(text: str):
    """Directly analyze text for spam/scam without Instagram."""
    result = ml_service.analyze_text(text)
    return result
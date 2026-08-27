from fastapi import APIRouter
from pydantic import BaseModel
from server.verification.number_verification import ServerNumberVerification
from server.detection.server_analysis import ServerAnalysis

router = APIRouter()

class SMSWebhookPayload(BaseModel):
    sender: str
    body: str

@router.post("/sms_webhook")
async def receive_sms(payload: SMSWebhookPayload):
    # Phase 8: Create server response generator
    body = payload.body
    parts = body.split("|")
    
    # Expected format: SCG|CHECK|REQ12345|+919876543210|KYC,OTP,URGENCY
    if len(parts) >= 5 and parts[0] == "SCG" and parts[1] == "CHECK":
        request_id = parts[2]
        sender_number = parts[3]
        categories_str = parts[4]
        
        # 1. Verification
        ver_result = ServerNumberVerification.verify_number(sender_number)
        number_status = ver_result["status"]
        
        # 2. Risk Analysis
        risk_result = ServerAnalysis.calculate_risk(number_status, categories_str)
        
        # 3. Build response: SCG|RESULT|REQ12345|HIGH|UNVERIFIED|KYC_OTP|88
        risk_level = risk_result["level"]
        risk_score = risk_result["score"]
        
        # Simplify category string for SMS
        cat_short = categories_str.replace("Credential Theft", "CRED").replace("Bank Impersonation", "BANK")
        
        response_sms = f"SCG|RESULT|{request_id}|{risk_level}|{number_status}|{cat_short}|{risk_score}|SERVER_VERIFIED"
        print(f"[SERVER] Generated SMS response: {response_sms}")
        
        return {"response_sms": response_sms}
        
    return {"error": "Invalid protocol"}

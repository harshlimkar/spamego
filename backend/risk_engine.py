import os
import httpx
import logging

logger = logging.getLogger(__name__)

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:1.5b")

# Keep a running transcript for each call
call_transcripts = {}

_WARNINGS = {
    "CRITICAL": "🚨 HIGH RISK SCAM DETECTED! Do NOT share OTP, password, or money. Hang up immediately!",
    "SUSPICIOUS": "⚠️ Suspicious call. Be careful — do not share any personal or banking details.",
    "SAFE": "✅ Call appears safe so far.",
}

async def process_transcript_chunk(call_sid: str, chunk: str) -> dict:
    """
    Appends the new chunk to the call's running transcript,
    then evaluates the risk of the conversation so far using Ollama Qwen.
    """
    if call_sid not in call_transcripts:
        call_transcripts[call_sid] = ""
    
    call_transcripts[call_sid] += " " + chunk.strip()
    full_transcript = call_transcripts[call_sid]

    prompt = f"""
You are a live scam detection AI. Read this phone call transcript (in English or Tamil) and decide if it is a scam.
Focus on urgency, claims of authority (bank, police), and requests for sensitive info (OTP, passwords, money).
If they ask for an OTP or PIN, it is CRITICAL.

Transcript:
"{full_transcript}"

Reply with exactly ONE word: SAFE, SUSPICIOUS, or CRITICAL.
"""

    qwen_score = 0.0
    intent_label = "SAFE"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                OLLAMA_URL,
                json={
                    "model": OLLAMA_MODEL,
                    "prompt": prompt,
                    "stream": False
                },
                timeout=10.0
            )
            
            if response.status_code == 200:
                result = response.json().get("response", "").strip().upper()
                if "CRITICAL" in result:
                    qwen_score = 1.0
                    intent_label = "CRITICAL"
                elif "SUSPICIOUS" in result:
                    qwen_score = 0.5
                    intent_label = "SUSPICIOUS"
                else:
                    qwen_score = 0.0
                    intent_label = "SAFE"
            else:
                logger.error(f"Ollama error: {response.text}")
    except Exception as e:
        logger.error(f"Failed to connect to Ollama: {e}")

    # Simple ML placeholder (could be replaced by a real ML model API call)
    has_critical_words = any(word in chunk.lower() for word in ["otp", "password", "bank", "police", "arrest", "urgent", "pin", "cvv"])
    ml_score = 1.0 if has_critical_words else 0.0

    # Fusion (weighted average). If OTP/critical words are present, ensure score is at least > 60
    final_risk = (qwen_score * 0.7) + (ml_score * 0.3)
    if has_critical_words and final_risk < 0.65:
        final_risk = 0.85  # Force high score (85%) if critical words are found
        intent_label = "CRITICAL"
    
    logger.info(f"[RISK] {intent_label} | Score: {final_risk:.2f} | Chunk: {chunk}")
    
    # Return everything needed by both storage.py and main.py
    return {
        "final_risk": final_risk,
        "qwen_score": qwen_score,
        "ml_score": ml_score,
        "intent_label": intent_label,
        # For main.py WS broadcasting
        "is_scam": intent_label in ("SUSPICIOUS", "CRITICAL"),
        "risk_score": int(final_risk * 100),
        "threat_type": intent_label,
        "warning_message": _WARNINGS.get(intent_label, "✅ Call appears safe so far.")
    }

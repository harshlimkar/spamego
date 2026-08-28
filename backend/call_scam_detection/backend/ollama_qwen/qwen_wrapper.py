import os
import httpx
import logging
import asyncio

logger = logging.getLogger(__name__)

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen")

async def analyze_transcript(transcript: str) -> float:
    """
    Returns a risk score between 0.0 and 1.0 based on Qwen's analysis of the running transcript.
    """
    prompt = f"""
You are a live scam detection engine. Read the following phone call transcript and decide if it is a scam.
Focus on urgency, claims of authority (bank, police), and requests for sensitive info (OTP, passwords, money).

Transcript:
"{transcript}"

Reply with exactly ONE word: SAFE, SUSPICIOUS, or CRITICAL.
"""

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
                    return 1.0
                elif "SUSPICIOUS" in result:
                    return 0.5
                else:
                    return 0.0
            else:
                logger.error(f"Ollama error: {response.text}")
    except Exception as e:
        logger.error(f"Failed to connect to Ollama: {e}")

    # Fallback if Ollama is unreachable
    return 0.0

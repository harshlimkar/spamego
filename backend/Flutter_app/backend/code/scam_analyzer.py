import os
import io
import json
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def transcribe_audio_chunk(audio_bytes: bytes) -> str:
    """Transcribes an audio buffer using Groq Whisper."""
    try:
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = "audio.wav"
        
        transcription = groq_client.audio.transcriptions.create(
            file=(audio_file.name, audio_file.read()),
            model="whisper-large-v3",
            prompt="Transcribe Indian phone call conversation in Hindi, Hinglish, or English.",
            language="hi",
            temperature=0.0
        )
        return transcription.text.strip()
    except Exception as e:
        print(f"[STT Error]: {e}")
        return ""

def analyze_scam_intent(transcript: str) -> dict:
    """Analyzes transcript for urgency, OTP requests, impersonation, and calculates a risk score."""
    if not transcript or len(transcript) < 4:
        return {"is_scam": False, "risk_score": 0, "reason": "No speech detected"}

    system_prompt = """
    You are an elite cyber fraud detection AI specializing in Indian scam patterns (Jamtara, fake KYC, SBI YONO, FedEx customs, electricity bill disconnection, TRAI police impersonation).
    Analyze the incoming phone conversation transcript and output strictly valid JSON with this exact structure:
    {
      "is_scam": true/false,
      "risk_score": <integer from 0 to 100>,
      "threat_type": "<e.g., Bank KYC / OTP Theft / Remote Access / Safe>",
      "urgency_detected": true/false,
      "warning_message": "<Short 1-sentence warning for a senior citizen in simple language>"
    }
    """

    try:
        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Transcript to evaluate: \"{transcript}\""}
            ],
            response_format={"type": "json_object"},
            temperature=0.1
        )
        return json.loads(response.choices[0].message.content)
    except Exception as e:
        print(f"[Scam Analysis Error]: {e}")
        return {"is_scam": False, "risk_score": 0, "reason": "Analysis failed"}
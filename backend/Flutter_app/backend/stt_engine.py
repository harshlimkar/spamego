"""
stt_engine.py
─────────────
Groq Whisper STT integration.
Receives raw PCM audio bytes, wraps them in a WAV container in-memory,
and sends them to Groq's whisper-large-v3 for fast multilingual transcription
(English, Hindi, Hinglish).
"""

import io
import os
import wave
import logging
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

# Sample rate used by LiveKit (opus decoded to 48kHz mono by default)
SAMPLE_RATE = 48000
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit PCM


def transcribe_audio_chunk(audio_bytes: bytes) -> str:
    """
    Transcribes a raw PCM audio chunk using Groq Whisper.

    Args:
        audio_bytes: Raw 16-bit PCM audio bytes (48kHz, mono).

    Returns:
        Transcribed text string, or "" on error/silence.
    """
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        logger.warning("GROQ_API_KEY not set — returning empty transcript.")
        return ""

    if not audio_bytes or len(audio_bytes) < 1024:
        return ""  # Too short to transcribe meaningfully

    try:
        client = Groq(api_key=api_key)

        # Wrap raw PCM into a WAV file in memory (Groq expects a file format)
        wav_buffer = io.BytesIO()
        with wave.open(wav_buffer, "wb") as wf:
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(SAMPLE_WIDTH)
            wf.setframerate(SAMPLE_RATE)
            wf.writeframes(audio_bytes)
        wav_buffer.seek(0)

        transcription = client.audio.transcriptions.create(
            file=("audio.wav", wav_buffer, "audio/wav"),
            model="whisper-large-v3",
            response_format="text",
            language="hi",   # Accepts Hindi/Hinglish/English
            temperature=0.0,
            prompt=(
                "This is a live phone call. Listen for scam indicators: "
                "OTP requests, bank impersonation, urgency, arrest threats, "
                "remote-access requests, money transfer demands."
            ),
        )
        result = transcription.strip() if isinstance(transcription, str) else ""
        if result:
            logger.info(f"[STT] Transcribed: {result}")
        return result

    except Exception as e:
        logger.error(f"Groq STT error: {e}")
        return ""

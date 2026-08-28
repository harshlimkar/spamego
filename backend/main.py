"""
main.py - Scam Detection Backend (Mic Streaming via WebSocket)
==============================================================
Flutter streams raw 16-bit PCM audio → Groq Whisper STT → Risk Engine → Flutter alerts
No Twilio, no GSM, pure WiFi/internet.
"""
import io
import json
import logging
import os
import time
import wave
from collections import defaultdict

from dotenv import load_dotenv
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from risk_engine import process_transcript_chunk
from storage import save_risk_score

load_dotenv()
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")

app = FastAPI(title="Scam Detection - Mic Mode", version="4.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# session_id → alert WebSocket clients
alert_connections: dict[str, list[WebSocket]] = defaultdict(list)


async def broadcast(session_id: str, payload: dict):
    dead = []
    for ws in alert_connections.get(session_id, []):
        try:
            await ws.send_text(json.dumps(payload))
        except Exception:
            dead.append(ws)
    for ws in dead:
        if ws in alert_connections[session_id]:
            alert_connections[session_id].remove(ws)


def transcribe_pcm(pcm_bytes: bytes, sample_rate: int = 16000) -> str:
    """Send raw 16-bit mono PCM to Groq Whisper. Returns transcript."""
    if not GROQ_API_KEY or not pcm_bytes:
        return ""
    try:
        from groq import Groq
        client = Groq(api_key=GROQ_API_KEY)

        wav_buf = io.BytesIO()
        with wave.open(wav_buf, "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)          # 16-bit
            wf.setframerate(sample_rate)
            wf.writeframes(pcm_bytes)
        wav_buf.seek(0)

        result = client.audio.transcriptions.create(
            file=("audio.wav", wav_buf, "audio/wav"),
            model="whisper-large-v3",
            response_format="text",
            temperature=0.0,
            language="en"
        )
        return (result or "").strip()
    except Exception as e:
        logger.error(f"Groq error: {e}")
        return ""


@app.get("/health")
async def health():
    return {"status": "ok", "mode": "mic_streaming", "groq_ready": bool(GROQ_API_KEY)}


@app.websocket("/ws/audio/{session_id}")
async def audio_stream(websocket: WebSocket, session_id: str):
    """
    Flutter connects here and sends binary PCM frames.
    Every ~3 seconds of audio is flushed to Groq Whisper for transcription.
    """
    await websocket.accept()
    logger.info(f"[{session_id}] 🎙️ Audio stream connected.")

    SAMPLE_RATE   = 16000
    BUFFER_LIMIT  = SAMPLE_RATE * 2 * 5  # 5 sec × 16kHz × 2 bytes
    pcm_buffer    = bytearray()

    await broadcast(session_id, {
        "type": "connected",
        "message": "🎙️ Microphone active. AI is listening live...",
    })

    async def flush_and_analyze(data: bytes):
        if not data:
            return
            
        import audioop
        try:
            rms = audioop.rms(data, 2)
            if rms < 300:  # Silence threshold
                logger.info(f"[{session_id}] Skipping silent audio chunk (RMS: {rms})")
                return
        except Exception as e:
            pass

        import asyncio
        transcript = await asyncio.get_event_loop().run_in_executor(
            None, transcribe_pcm, data, SAMPLE_RATE
        )
        if not transcript:
            return
        logger.info(f"[{session_id}] TRANSCRIPT: {transcript}")
        risk = await process_transcript_chunk(session_id, transcript)
        save_risk_score(session_id, transcript, risk)
        await broadcast(session_id, {
            "type": "analysis",
            "transcript": transcript,
            "is_scam": risk.get("is_scam", False),
            "risk_score": risk.get("risk_score", 0),
            "threat_type": risk.get("threat_type", "SAFE"),
            "warning_message": risk.get("warning_message", ""),
            "timestamp": time.time(),
        })

    try:
        while True:
            msg = await websocket.receive()

            if "text" in msg:
                if msg["text"].strip().lower() == "stop":
                    logger.info(f"[{session_id}] Stop signal received.")
                    break

            elif "bytes" in msg:
                pcm_buffer.extend(msg["bytes"])
                if len(pcm_buffer) >= BUFFER_LIMIT:
                    chunk = bytes(pcm_buffer)
                    pcm_buffer.clear()
                    import asyncio
                    asyncio.create_task(flush_and_analyze(chunk))

    except WebSocketDisconnect:
        logger.info(f"[{session_id}] Disconnected.")
    except Exception as e:
        logger.error(f"[{session_id}] Error: {e}")
    finally:
        if pcm_buffer:
            await flush_and_analyze(bytes(pcm_buffer))
        await broadcast(session_id, {"type": "call_ended", "message": "📴 Session ended."})
        logger.info(f"[{session_id}] Stream closed.")


@app.websocket("/ws/alerts/{session_id}")
async def alert_stream(websocket: WebSocket, session_id: str):
    """Flutter subscribes here to receive live analysis results."""
    await websocket.accept()
    alert_connections[session_id].append(websocket)
    logger.info(f"[{session_id}] Flutter alert client connected.")
    await websocket.send_text(json.dumps({
        "type": "connected",
        "room": session_id,
        "message": "🔒 Scam detection active. Tap 'Start Analysis' to begin.",
    }))
    try:
        while True:
            msg = await websocket.receive_text()
            if msg == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
    except WebSocketDisconnect:
        if websocket in alert_connections[session_id]:
            alert_connections[session_id].remove(websocket)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")

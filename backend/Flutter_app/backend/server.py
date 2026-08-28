"""
server.py
─────────
FastAPI backend for the VoIP Scam Detection system.

Endpoints:
  POST /api/get-token                 → generates a LiveKit JWT access token
  POST /api/start-monitoring/{room}   → starts a background LiveKit audio listener
  WS   /ws/alerts/{room}              → streams live transcript + risk events to Flutter

Flow:
  Flutter joins LiveKit room (WebRTC audio) ──►
  Backend worker subscribes to same room ──►
  Buffers 3s of PCM audio ──►
  Groq Whisper transcription ──►
  ML scam classification ──►
  Broadcasts JSON over WebSocket to Flutter
"""

import asyncio
import json
import logging
import os
import struct
import time
from collections import defaultdict
from typing import Optional

from dotenv import load_dotenv
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from stt_engine import transcribe_audio_chunk
from ml_hook import predict_scam_intent

# LiveKit imports
try:
    from livekit import api as lk_api
    from livekit import rtc
    LIVEKIT_AVAILABLE = True
except ImportError:
    LIVEKIT_AVAILABLE = False
    logging.warning("LiveKit SDK not installed. Audio monitoring will be simulated.")

load_dotenv()
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title="VoIP Scam Detection API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── In-memory state ──────────────────────────────────────────
# room_name → list of connected WebSocket clients
active_connections: dict[str, list[WebSocket]] = defaultdict(list)
# room_name → monitoring task
monitoring_tasks: dict[str, asyncio.Task] = {}


# ── Pydantic models ──────────────────────────────────────────
class TokenRequest(BaseModel):
    room_name: str
    participant_name: str


# ── Helpers ──────────────────────────────────────────────────
async def broadcast(room_name: str, payload: dict):
    """Send a JSON payload to all WebSocket clients in a room."""
    dead = []
    for ws in active_connections[room_name]:
        try:
            await ws.send_text(json.dumps(payload))
        except Exception:
            dead.append(ws)
    for ws in dead:
        active_connections[room_name].remove(ws)


# ── Endpoints ────────────────────────────────────────────────

@app.post("/api/get-token")
async def get_token(req: TokenRequest):
    """
    Generate a LiveKit access token for a participant to join a room.
    """
    livekit_url    = os.getenv("LIVEKIT_URL", "")
    api_key        = os.getenv("LIVEKIT_API_KEY", "")
    api_secret     = os.getenv("LIVEKIT_API_SECRET", "")

    if not all([livekit_url, api_key, api_secret]):
        return JSONResponse(
            status_code=500,
            content={"error": "LiveKit credentials not configured in .env"},
        )

    try:
        token = (
            lk_api.AccessToken(api_key, api_secret)
            .with_identity(req.participant_name)
            .with_name(req.participant_name)
            .with_grants(
                lk_api.VideoGrants(
                    room_join=True,
                    room=req.room_name,
                    can_publish=True,
                    can_subscribe=True,
                )
            )
            .to_jwt()
        )
        logger.info(f"Token generated for {req.participant_name} in room {req.room_name}")
        return {"token": token, "livekit_url": livekit_url}
    except Exception as e:
        logger.error(f"Token generation error: {e}")
        return JSONResponse(status_code=500, content={"error": str(e)})


@app.post("/api/start-monitoring/{room_name}")
async def start_monitoring(room_name: str):
    """
    Spawns an async background worker that connects to the LiveKit room,
    subscribes to audio tracks, buffers 3s of PCM, transcribes via Groq,
    classifies via ML model, and broadcasts results over WebSocket.
    """
    if room_name in monitoring_tasks and not monitoring_tasks[room_name].done():
        return {"status": "already_monitoring", "room": room_name}

    task = asyncio.create_task(_monitor_room(room_name))
    monitoring_tasks[room_name] = task
    logger.info(f"Started monitoring task for room: {room_name}")
    return {"status": "monitoring_started", "room": room_name}


@app.websocket("/ws/alerts/{room_name}")
async def websocket_alerts(websocket: WebSocket, room_name: str):
    """
    Flutter connects here to receive live transcript and risk alerts.
    """
    await websocket.accept()
    active_connections[room_name].append(websocket)
    logger.info(f"Flutter client connected to room: {room_name}. "
                f"Total clients: {len(active_connections[room_name])}")

    await websocket.send_text(json.dumps({
        "type": "connected",
        "room": room_name,
        "message": "🔒 Scam detection active. Call is being monitored."
    }))

    try:
        while True:
            # Keep-alive: wait for incoming messages (Flutter ping or disconnect)
            data = await websocket.receive_text()
            if data == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
    except WebSocketDisconnect:
        active_connections[room_name].remove(websocket)
        logger.info(f"Flutter client disconnected from room: {room_name}")


# ── Background Worker ────────────────────────────────────────

async def _monitor_room(room_name: str):
    """
    Background task: connects to LiveKit room as a silent listener,
    captures audio, runs STT + ML, and broadcasts results.
    """
    livekit_url = os.getenv("LIVEKIT_URL", "")
    api_key     = os.getenv("LIVEKIT_API_KEY", "")
    api_secret  = os.getenv("LIVEKIT_API_SECRET", "")

    if not LIVEKIT_AVAILABLE or not all([livekit_url, api_key, api_secret]):
        logger.warning(f"[{room_name}] LiveKit not available. Running demo simulation.")
        await _simulate_monitoring(room_name)
        return

    try:
        # Generate a monitor token (bot participant)
        token = (
            lk_api.AccessToken(api_key, api_secret)
            .with_identity("scam-monitor-bot")
            .with_name("ScamDetect AI")
            .with_grants(lk_api.VideoGrants(
                room_join=True,
                room=room_name,
                can_subscribe=True,
                can_publish=False,
                hidden=True,
            ))
            .to_jwt()
        )

        room = rtc.Room()
        pcm_buffer: list[bytes] = []
        BUFFER_SECONDS = 3
        SAMPLE_RATE = 48000
        CHANNELS = 1
        BYTES_PER_SAMPLE = 2
        BUFFER_LIMIT = SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE * BUFFER_SECONDS

        @room.on("track_subscribed")
        def on_track(track, publication, participant):
            if track.kind == rtc.TrackKind.KIND_AUDIO:
                logger.info(f"[{room_name}] Subscribed to audio from {participant.identity}")
                asyncio.create_task(_capture_audio(track, pcm_buffer, BUFFER_LIMIT, room_name))

        await room.connect(livekit_url, token, options=rtc.RoomOptions(auto_subscribe=True))
        logger.info(f"[{room_name}] Monitor bot connected to room.")

        # Keep the task alive while the room is active
        while room.connection_state == rtc.ConnectionState.CONN_CONNECTED:
            await asyncio.sleep(1)

    except asyncio.CancelledError:
        pass
    except Exception as e:
        logger.error(f"[{room_name}] Monitor error: {e}")


async def _capture_audio(track, pcm_buffer: list, buffer_limit: int, room_name: str):
    """
    Reads audio frames from the LiveKit audio track,
    accumulates them, and flushes to STT+ML every ~3 seconds.
    """
    audio_stream = rtc.AudioStream(track)
    accumulated = bytearray()

    async for frame_event in audio_stream:
        frame = frame_event.frame
        # frame.data is raw int16 PCM
        accumulated.extend(bytes(frame.data))

        if len(accumulated) >= buffer_limit:
            chunk = bytes(accumulated)
            accumulated.clear()
            asyncio.create_task(_process_chunk(chunk, room_name))


async def _process_chunk(audio_bytes: bytes, room_name: str):
    """
    Runs the STT → ML pipeline on a single audio chunk and broadcasts results.
    """
    loop = asyncio.get_event_loop()

    # Run blocking Groq call in thread pool
    transcript = await loop.run_in_executor(None, transcribe_audio_chunk, audio_bytes)
    if not transcript:
        return

    # Run ML classification
    result = predict_scam_intent(transcript)

    payload = {
        "type": "analysis",
        "timestamp": time.time(),
        "transcript": transcript,
        **result,
    }

    logger.info(
        f"[{room_name}] BROADCAST → is_scam={result['is_scam']} "
        f"risk={result['risk_score']} text='{transcript[:60]}'"
    )
    await broadcast(room_name, payload)


async def _simulate_monitoring(room_name: str):
    """
    Demo simulation when LiveKit SDK is unavailable.
    Sends progressive scam scenario events to test the Flutter UI.
    """
    logger.info(f"[{room_name}] Starting demo simulation...")
    await asyncio.sleep(3)

    demo_script = [
        ("Hello, am I speaking with you? This is a call from State Bank of India.", False, 5, "SAFE"),
        ("We have noticed some suspicious transactions on your account recently.", False, 20, "BANK_IMPERSONATION"),
        ("Your account will be blocked in the next 30 minutes if not verified. This is urgent!", True, 55, "BANK_IMPERSONATION"),
        ("Please do not share this with anyone. Your OTP is required for KYC verification.", True, 85, "OTP_REQUEST"),
        ("If you don't transfer the amount immediately, we will file a case. Police will come.", True, 95, "AUTHORITY_IMPERSONATION"),
    ]

    for (text, is_scam, risk, threat) in demo_script:
        result = predict_scam_intent(text)
        payload = {
            "type": "analysis",
            "timestamp": time.time(),
            "transcript": text,
            "is_scam": result["is_scam"],
            "risk_score": result["risk_score"],
            "threat_type": result["threat_type"],
            "warning_message": result["warning_message"],
        }
        await broadcast(room_name, payload)
        logger.info(f"[DEMO] Sent: {text[:50]}...")
        await asyncio.sleep(5)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001, log_level="info")

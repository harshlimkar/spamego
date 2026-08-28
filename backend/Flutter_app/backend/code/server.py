import os
import json
import asyncio
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from livekit import api, rtc
from dotenv import load_dotenv

from scam_analyzer import transcribe_audio_chunk, analyze_scam_intent

load_dotenv()

app = FastAPI(title="Sārathi Scam Detection Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

LIVEKIT_URL = os.getenv("LIVEKIT_URL")
LIVEKIT_API_KEY = os.getenv("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.getenv("LIVEKIT_API_SECRET")

class TokenRequest(BaseModel):
    room_name: str
    participant_name: str

connected_alert_sockets = {}

@app.post("/api/get-token")
def get_livekit_token(req: TokenRequest):
    """Generates access tokens for Flutter caller and receiver."""
    try:
        token = api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET) \
            .with_identity(req.participant_name) \
            .with_name(req.participant_name) \
            .with_grants(api.VideoGrants(
                room_join=True,
                room=req.room_name,
                can_publish=True,
                can_subscribe=True
            ))
        return {"token": token.to_jwt(), "url": LIVEKIT_URL}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws/alerts/{room_name}")
async def websocket_alerts(websocket: WebSocket, room_name: str):
    """Streams real-time transcriptions and scam alerts to the Flutter app."""
    await websocket.accept()
    connected_alert_sockets[room_name] = websocket
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        connected_alert_sockets.pop(room_name, None)

async def broadcast_alert(room_name: str, payload: dict):
    if room_name in connected_alert_sockets:
        try:
            await connected_alert_sockets[room_name].send_text(json.dumps(payload))
        except Exception as e:
            print(f"[WS Broadcast Error]: {e}")

# LiveKit Room Background Audio Listener
async def monitor_room_audio(room_name: str):
    room = rtc.Room()
    
    token = api.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET) \
        .with_identity(f"ai-sentinel-{room_name}") \
        .with_grants(api.VideoGrants(room_join=True, room=room_name)) \
        .to_jwt()

    @room.on("track_subscribed")
    def on_track_subscribed(track: rtc.Track, publication: rtc.TrackPublication, participant: rtc.RemoteParticipant):
        if track.kind == rtc.TrackKind.KIND_AUDIO:
            asyncio.create_task(process_audio_stream(track, room_name))

    await room.connect(LIVEKIT_URL, token)
    print(f"✅ AI Monitor active for room: {room_name}")

async def process_audio_stream(track: rtc.Track, room_name: str):
    audio_stream = rtc.AudioStream(track)
    buffer = bytearray()
    
    async for frame in audio_stream:
        buffer.extend(frame.data.tobytes())
        # Process every ~3 seconds of 48kHz 16-bit mono audio (approx 288,000 bytes)
        if len(buffer) >= 288000:
            chunk = bytes(buffer)
            buffer.clear()
            
            # 1. Transcribe with Groq Whisper
            transcript = transcribe_audio_chunk(chunk)
            if transcript:
                print(f"🗣️ [{room_name}] Transcript: {transcript}")
                
                # 2. Analyze Scam Intent with Groq Llama 3
                analysis = analyze_scam_intent(transcript)
                
                # 3. Push real-time result to Flutter
                await broadcast_alert(room_name, {
                    "transcript": transcript,
                    "analysis": analysis
                })

@app.post("/api/start-monitoring/{room_name}")
async def start_monitoring(room_name: str):
    asyncio.create_task(monitor_room_audio(room_name))
    return {"status": "Monitoring initialized"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
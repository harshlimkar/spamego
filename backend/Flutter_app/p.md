Act as a Principal Full-Stack & AI Systems Engineer. Build a complete, production-ready, modular project for a real-time VoIP calling application with live scam detection. 

In this architecture, Groq is used EXCLUSIVELY for Speech-to-Text (STT) via Whisper. The scam classification must be wired to invoke a pre-existing custom Python ML model function (`predict_scam_intent(transcript: str) -> dict`) rather than an external LLM.

### System Overview & Tech Stack
1. Frontend: Flutter (Dart) using `livekit_client` for WebRTC internet calling, `http` for room token acquisition, and `web_socket_channel` for live scam alert streams.
2. Backend: Python (FastAPI + Uvicorn) with `livekit-api` and `livekit` SDK running an async audio listener that buffers real-time audio streams from active calls.
3. Speech-to-Text (STT): Groq API using `whisper-large-v3` for fast, low-latency multilingual transcription (Tamil ,Hindi, Hinglish, English).
4. Scam Classification: A standalone modular function `predict_scam_intent(transcript: str) -> dict` that represents my existing ML model inference pipeline (no ML training/model code required—just the integration hook returning structured results).
5. Communication: WebSocket endpoint (`/ws/alerts/{room_name}`) broadcasting live transcripts and threat scores to Flutter clients during active calls.

---

### Project Structure to Generate

```text
Flutter_app/
├── backend/
│   ├── .env.example
│   ├── requirements.txt
│   ├── stt_engine.py
│   ├── ml_hook.py
│   └── server.py
└── mobile_app/
    ├── pubspec.yaml
    ├── android/app/src/main/AndroidManifest.xml (with audio/network permissions)
    └── lib/
        └── main.dart (complete Flutter app: dialer + active call screen with live alert banner)



Implementation Requirements
1. Backend (backend/)
requirements.txt: Include fastapi, uvicorn, livekit-api, livekit, groq, python-dotenv, pydantic, requests.

.env.example: Placeholders for GROQ_API_KEY, LIVEKIT_URL, LIVEKIT_API_KEY, and LIVEKIT_API_SECRET.

stt_engine.py:

Implements transcribe_audio_chunk(audio_bytes: bytes) -> str using Groq SDK (whisper-large-v3).

ml_hook.py:

Contains a clean integration wrapper predict_scam_intent(transcript: str) -> dict.

(Provide the interface returning {"is_scam": bool, "risk_score": int, "threat_type": str, "warning_message": str} so my existing model can be plugged in directly).

server.py:

POST /api/get-token: Generates LiveKit access tokens for caller & receiver given room_name and participant_name.

POST /api/start-monitoring/{room_name}: Spawns an async LiveKit background worker that subscribes to room audio, buffers ~3 seconds of PCM audio frames, calls stt_engine.py, evaluates the output with ml_hook.py, and broadcasts the JSON payload.

WebSocket /ws/alerts/{room_name}: Pushes live transcripts and risk evaluations to the mobile app in real-time.

2. Mobile App (mobile_app/)
pubspec.yaml: Dependencies for flutter, livekit_client, http, web_socket_channel, permission_handler.

AndroidManifest.xml: Configured with permissions for RECORD_AUDIO, INTERNET, and MODIFY_AUDIO_SETTINGS.

lib/main.dart:

Dialer Screen: Inputs for Room ID and User Name, microphone permission checks, and a "Connect Call" action.

Active Call Screen:

Establishes LiveKit WebRTC connection and WebSocket listener.

Top Status Banner: Displays green ("Call Protected") by default, immediately transitions to bright red ("THREAT DETECTED - Risk: X%") with custom warning text upon receiving is_scam: true.

Live Transcription Box: Displays scrolling real-time text from Groq Whisper.

End Call FAB: Cleanly closes WebSockets, disconnects WebRTC audio tracks, and returns to the home screen.        
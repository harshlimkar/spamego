# Build Prompt — Live Call Scam Detection Module (Flutter)

Paste this into your coding tool (Claude Code, Cursor, etc.) as the project brief.

---

## WHAT THIS PROJECT IS

This is **Module 2 (scoped down)** of a larger multi-channel Digital Scam Protection Platform for senior citizens (PS5 Challenge 04). The full platform has separate modules for offline SMS/IVR protection, in-app SMS scanning, and UPI fraud detection — built by other teammates. **This module does one thing only: detect scams live, during a phone call, by listening to the conversation as it happens and raising an alert before the user gets scammed.**

It must be **built to plug into the rest of the platform easily**: it exposes its risk output (`call_context_risk`) as a simple API/event that the shared unified risk engine can consume, and it does not assume ownership of SMS, UPI, or offline logic — those stay out of scope and out of this folder.

## WHY A CUSTOM PHONE APP (not just default-dialer)

Android's standard `CallScreeningService` / default-dialer role gives call **metadata** (number, block/allow) but does **not** reliably give an app raw, continuous audio access for live transcription during a normal carrier call — OS-level restrictions block this for regular calls. So instead of fighting that restriction, build a **self-contained calling app** (VoIP-style, using something like Twilio Voice free tier, Agora free tier, or WebRTC) that *is* the call itself — since the app owns the audio stream end-to-end, it can legally and technically pipe that live audio straight into ElevenLabs for transcription. This app lives in its own folder, fully separable from the risk-scoring backend.

## PROJECT SCOPE

Build **two things, each in its own folder**:
1. `phone/` — a custom calling app (own audio stream, not reliant on Android's restricted default-dialer audio access) that streams live call audio into ElevenLabs STT
2. `call_scam_detection/` — the risk-scoring pipeline (reporting layer, ML model, Qwen, event engine, fusion) that consumes the live transcript from `phone/` and produces the risk score + alerts

Do not build the SMS module, UPI module, or offline/IVR module — those are separate teammates' scope.

## FOLDER STRUCTURE

```
phone/
├── lib/
│   ├── call_engine/            # VoIP call handling (Twilio Voice / Agora / WebRTC — pick one free-tier option)
│   ├── audio_stream/            # captures live call audio, pipes to ElevenLabs STT streaming
│   ├── ui/                       # basic dialer UI (dial pad, in-call screen)
│   └── main.dart
├── README.md                     # documents why this app exists instead of using default-dialer, and how call_scam_detection/ plugs into it

call_scam_detection/
├── app/                      # Flutter risk UI, integrated INTO phone/'s in-call screen
│   ├── lib/
│   │   ├── stt_bridge/          # receives live transcript from phone/'s ElevenLabs stream
│   │   ├── risk/                # risk score UI (live meter, alert banner, vibration/red-light trigger)
│   │   ├── contacts/            # trusted-contact selection + auto-alert SMS/call
│   │   └── main.dart
├── backend/
│   ├── reporting_layer/         # spam-number DB + report ingestion API
│   ├── event_engine/            # call-timeline correlation (repeat calls, SMS/OTP correlation)
│   ├── ml_model/                 # fine-tuned classifier on provided datasets
│   ├── ollama_qwen/               # local Qwen inference wrapper
│   └── risk_fusion/               # combines report score + ML score + Qwen score + event score
├── datasets/
│   ├── spam_dataset/             # provided SMS/scam datasets (real, not synthetic)
│   └── scam_blog_dataset/         # SET/GoPhish/ScamFerret-derived phishing tactic data
└── docs/
    └── architecture.md
```

## TECH STACK (free/open only)

| Component | Tool |
|---|---|
| Calling app | Flutter + VoIP engine (Twilio Voice free tier / Agora free tier / WebRTC) — owns the audio stream so live STT is technically possible |
| Live STT | ElevenLabs STT API (streaming), fed directly from `phone/`'s audio stream |
| ML classifier | Fine-tune a small transformer (DistilBERT/IndicBERT, HuggingFace, free) on `datasets/spam_dataset/` and `datasets/scam_blog_dataset/` — **use only the provided datasets, no synthetic generation** |
| Local LLM | Qwen via Ollama, running locally — second opinion / contextual reasoning pass on the live transcript |
| Backend | FastAPI (Python) |
| Reporting DB | SQLite/Postgres — table of `{number, report_count, last_reported, risk_tag}` |
| Event engine | Simple in-process state machine per contact, tracking call timestamps, pickup/no-pickup, and cross-referenced SMS/OTP timestamps within the same time window |
| Realtime delivery to app | WebSocket (Socket.IO) between backend and Flutter app |
| Trusted-contact alert | SMS via local Android SmsManager (no paid API needed) |

## CORE PIPELINE (build in this order)

**0. Phone App (`phone/`) — build this first, everything depends on it**
- Build the VoIP calling app (Twilio Voice / Agora / WebRTC, whichever free tier is easiest to set up)
- Confirm you can capture the live audio stream from an active call
- Pipe that stream into ElevenLabs STT and confirm you get live transcript chunks back
- Expose the transcript as a simple event/callback (`onTranscriptChunk(text, timestamp)`) that `call_scam_detection/` subscribes to — this is the integration seam, keep it clean so the risk module never needs to know how the audio was captured

**1. Reporting Layer (build first — it's the foundation)**
- API: `POST /report {number}` → increments report count, timestamps it
- API: `GET /check/{number}` → returns `{report_count, base_risk_score}`
- Every incoming call queries this first, before any AI runs — cheapest, fastest signal

**2. Live Call Pipeline**
- On call connect → start ElevenLabs streaming STT → transcript chunks emitted every 1-2 sec
- Each transcript chunk → sent to backend `/analyze_turn`
- Backend runs **both** models on each chunk:
  - ML classifier → intent/risk label (trained on your provided datasets)
  - Qwen (Ollama) → contextual read on the *conversation so far*, not just the last chunk — give it the running transcript, ask it to flag urgency, identity claims, OTP/credential/remote-access/payment requests
- Combine: `turn_risk = f(ml_score, qwen_score)` — simple weighted average to start, tune later

**3. Event Engine**
- Track per-number: call timestamps, pickup/no-pickup pattern, call frequency in short windows (e.g. 3 calls within 30 min = escalation signal)
- Cross-reference with SMS inbox: if an OTP/bank SMS arrives within N minutes of a call from an unreported/unknown number, bump the risk
- This produces a `timeline_risk` score that feeds into the same fusion step as the live call score

**4. Risk Fusion**
```
final_risk = w1*report_layer_score + w2*ml_score + w3*qwen_score + w4*timeline_risk
```
Start with equal weights, adjust after testing on your dataset.

**5. Response Layer**
- Score crosses "Suspicious" threshold → in-app banner warning
- Score crosses "High" threshold → vibration + red overlay on call screen
- Score crosses "Critical" threshold → auto-block guidance (surface a "hang up" prompt) + auto-SMS/alert to the pre-selected trusted contact with the risk summary

## DELIVERABLE FOR DEMO
A scripted call (use two test devices or a call simulator) where the transcript escalates through the scam playbook (identity claim → urgency → OTP request), the live risk meter visibly climbs turn-by-turn, and the app triggers the vibration/red-light warning and trusted-contact alert at the critical threshold. Log and report per-turn latency (target <3–5 sec from speech to risk update).

## BUILD INSTRUCTIONS FOR THE CODING AGENT
- Work only inside `phone/` and `call_scam_detection/`. Do not touch or assume other platform modules (SMS, UPI, offline/IVR) exist.
- Keep `phone/` and `call_scam_detection/` loosely coupled: `phone/` only ever emits transcript chunks + call metadata (number, start time); `call_scam_detection/` only ever consumes those and emits a `call_context_risk` score. This is what makes the module "easy to integrate" into the larger platform later — the unified risk engine only needs to read `call_context_risk` from this module's output, nothing else.
- Wait for the datasets to be placed in `datasets/spam_dataset/` and `datasets/scam_blog_dataset/` before writing the ML training script — do not fabricate placeholder data.
- Build reporting_layer → event_engine → ml_model training script → Ollama/Qwen wrapper → risk_fusion → Flutter app, in that order, and get each working standalone before wiring the next.
- Keep everything free-tier/open-source except ElevenLabs (flag any ElevenLabs usage limits reached and suggest a fallback like Vosk offline STT).

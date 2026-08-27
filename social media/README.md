# CyberShield AI

CyberShield AI is a full-stack social media moderation and monitoring system built around a FastAPI backend and a Next.js dashboard. It is designed to monitor Instagram conversations and comments, run AI-based content moderation, classify abusive behavior, escalate high-risk incidents, and expose a real-time command center for moderation operations.

This project is deliberately built as a practical monitoring dashboard: it stores users, monitored accounts, moderation results, alerts, and emergency reports in a local database by default, and it can scrape Instagram content using Playwright while analyzing the result through a custom classification pipeline.

## Project Summary

At a high level, the app does the following:

- Authenticates and stores users with JWT-based login
- Lets a user register one or more Instagram monitor accounts
- Starts a browser-based monitoring service that visits Instagram pages and threads
- Scrapes comments and DMs from the target account or target profile
- Runs moderation analysis on each piece of content
- Stores violation metadata and alert records
- Provides analytics dashboards showing offender trends, daily violation counts, alert summaries, and conversation intelligence
- Triggers emergency email and PDF report generation for critical incidents
- Pushes live event notifications to the frontend through WebSockets

---

## Architecture Overview

The app is split into two major subsystems:

### Backend
The backend is in [backend/main.py](backend/main.py) and under [backend/app](backend/app).

Main responsibilities:

- API routing
- user auth and JWT validation
- database initialization
- moderation pipeline orchestration
- Playwright-based Instagram monitoring
- emergency response logic
- live WebSocket event broadcasting

### Frontend
The frontend is in [frontend/src](frontend/src). It is a Next.js dashboard with route-based pages for:

- login and registration
- overview and live monitoring controls
- analytics
- alerts
- conversations
- comments
- offenders
- emergency reports

---

## Directory Structure

```text
social media/
├── README.md
├── render.yaml
├── requirements.txt
├── start.ps1
├── start_tunnel.ps1
├── cloudflare_tunnel.sh
├── backend/
│   ├── build.sh
│   ├── main.py
│   ├── requirements.txt
│   ├── sessions/
│   └── app/
│       ├── api/
│       │   ├── alerts/
│       │   ├── analytics/
│       │   ├── auth/
│       │   ├── comments/
│       │   ├── conversations/
│       │   ├── emergency/
│       │   ├── monitoring/
│       │   └── websocket.py
│       ├── core/
│       │   ├── config.py
│       │   └── security.py
│       ├── database/
│       │   └── base.py
│       ├── models/
│       │   ├── content.py
│       │   ├── instagram.py
│       │   ├── moderation.py
│       │   ├── user.py
│       │   └── __init__.py
│       ├── schemas/
│       │   └── auth.py
│       └── services/
│           ├── analysis_pipeline.py
│           ├── collector_service.py
│           ├── emergency_service.py
│           ├── moderation_service.py
│           └── severity_service.py
└── frontend/
    ├── package.json
    ├── next.config.js
    ├── postcss.config.js
    ├── tailwind.config.ts
    ├── tsconfig.json
    ├── vercel.json
    └── src/
        ├── app/
        ├── components/
        ├── hooks/
        └── services/
```

---

## Tech Stack

### Backend

- Python
- FastAPI
- SQLAlchemy
- Pydantic
- JWT / Python-Jose
- Passlib + bcrypt
- Playwright
- Transformers
- SQLite by default
- WebSockets
- SMTP / Resend integration for emergency emails

### Frontend

- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Axios
- js-cookie
- Framer Motion
- Recharts
- Lucide React

---

## Core Backend Flow

### 1. App startup
The application starts in [backend/main.py](backend/main.py).

Important behaviors:

- FastAPI app is created with title "CyberShield AI"
- CORS is enabled for local frontend origins and Vercel / trycloudflare URLs
- routers for auth, monitoring, analytics, alerts, conversations, emergency, and comments are registered under /api
- a WebSocket endpoint is mounted at /ws
- startup event calls init_db() and captures the FastAPI event loop so background monitoring threads can broadcast to the UI safely

### 2. Database initialization
Database setup is in [backend/app/database/base.py](backend/app/database/base.py).

It initializes:

- SQLAlchemy engine
- session factory
- declarative base
- table creation using Base.metadata.create_all()

Default DB URL:

```python
sqlite:///./cybershield.db
```

---

## Data Model

The schema is defined in the model files under [backend/app/models](backend/app/models).

### Users
Defined in [backend/app/models/user.py](backend/app/models/user.py).

Fields include:

- id
- name
- email
- password_hash
- instagram_username
- emergency_contact_email

Relationships:

- instagram_accounts
- alerts
- emergency_reports
- email_logs

### Instagram accounts
Defined in [backend/app/models/instagram.py](backend/app/models/instagram.py).

Tracks:

- username
- encrypted password
- monitoring_status
- session_started_at
- related posts

### Posts
Stored post metadata from Instagram pages including:

- instagram_post_id
- account_id
- post_url

### Comments and messages
Defined in [backend/app/models/content.py](backend/app/models/content.py).

- Comment stores content tied to a Post
- Message stores conversation messages tied to a Conversation
- Conversation tracks risk score, message count, flagged count

### Moderation results and violations
Defined in [backend/app/models/moderation.py](backend/app/models/moderation.py).

The project stores:

- ModerationResult: toxicity score, category, severity, confidence
- Violation: repeated abusive behavior by an author / user_identifier
- Alert: generated moderation alerts for a user
- EmergencyReport: high-risk incident report data
- EmailLog: delivery log of emergency email notifications

---

## Authentication and Security

### Security utilities
User authentication and token generation are implemented in [backend/app/core/security.py](backend/app/core/security.py).

Features include:

- bcrypt hashing via Passlib
- access token creation with JWT
- token decoding and validation
- Fernet-based encryption/decryption for Instagram credentials

### JWT auth flow
The auth router is in [backend/app/api/auth/routes.py](backend/app/api/auth/routes.py).

Endpoints:

- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/profile
- PUT /api/auth/profile

Behavior:

- register creates a user, hashes password, and returns a JWT token
- login verifies credentials and returns a token
- profile and update profile routes require Bearer auth

The frontend saves the token in a cookie named token and sends it on all API requests through [frontend/src/services/api.ts](frontend/src/services/api.ts).

---

## Moderation Pipeline

The classification pipeline is implemented in [backend/app/services/moderation_service.py](backend/app/services/moderation_service.py) and orchestrated by [backend/app/services/analysis_pipeline.py](backend/app/services/analysis_pipeline.py).

### Classification model
The project attempts to load a Hugging Face model:

```python
unitary/toxic-bert
```

If the model cannot be loaded, it falls back to a keyword-based moderation engine.

### Keyword fallback system
The fallback system uses handcrafted categories such as:

- threat
- hate_speech
- harassment
- insult
- profanity
- cyberbullying

It matches whole-word and phrase patterns and calculates a composite toxicity score with category weighting.

### Severity logic
Severity is computed in [backend/app/services/severity_service.py](backend/app/services/severity_service.py).

It produces:

- Safe
- Moderate
- High
- Critical

The score is based on:

- toxicity score
- whether the category is threat-like
- count of prior violations for the same author

---

## Monitoring / Scraping System

The Instagram monitoring logic is in [backend/app/services/collector_service.py](backend/app/services/collector_service.py).

### Overview
The monitor service:

- starts a background thread
- launches Playwright Chromium
- logs into Instagram using stored credentials
- navigates to profile pages and post URLs
- extracts comments from posts
- scrapes direct messages from the inbox
- stores new comments and messages in the database
- runs moderation analysis on them
- updates conversation risk and flagged counts

### Session behavior
The system stores a session_started_at timestamp and expires monitoring after 15 minutes by configuration.

This is controlled by:

- [backend/app/core/config.py](backend/app/core/config.py)
- `INSTAGRAM_SESSION_EXPIRE_MINUTES = 15`

### Monitoring endpoints
Defined in [backend/app/api/monitoring/routes.py](backend/app/api/monitoring/routes.py):

- POST /api/monitor/start
- POST /api/monitor/stop
- GET /api/monitor/status
- POST /api/monitor/ingest

### Manual test mode
The /api/monitor/ingest endpoint allows submitting arbitrary content directly into the moderation pipeline without needing an Instagram session. This is useful for demos and testing.

This is explicitly documented in the code comments as "Manual Testing Mode (Mode 3)".

---

## Analysis Pipeline Orchestration

The central moderation pipeline is in [backend/app/services/analysis_pipeline.py](backend/app/services/analysis_pipeline.py).

It performs the following in sequence:

1. classify the text
2. calculate severity based on toxicity and prior violation history
3. store a ModerationResult record
4. create a Violation record if score exceeds threshold
5. create an Alert if score exceeds threshold
6. broadcast live WebSocket events to the frontend
7. trigger emergency handling if the case is Critical

### WebSocket broadcasting
The project uses a WebSocket broadcast mechanism in [backend/app/api/websocket.py](backend/app/api/websocket.py).

- clients connect to /ws with JWT token in query string
- the backend validates the token
- all clients receive event payloads such as:
  - new_comment
  - new_message
  - new_alert
  - emergency_triggered

The real-time UI uses [frontend/src/hooks/useWebSocket.ts](frontend/src/hooks/useWebSocket.ts) to connect to the backend and update the dashboard in real time.

---

## Emergency Response System

Emergency logic is implemented in [backend/app/services/emergency_service.py](backend/app/services/emergency_service.py).

### What it does
When the analysis pipeline marks content as Critical, the app can:

- send an emergency email to the user's emergency contact
- write an EmergencyReport record
- write an EmailLog record
- generate a PDF report for a specific emergency case

### Email strategy
The system supports multiple fallback methods:

1. SMTP via Outlook/Hotmail
2. SMTP via Gmail
3. Resend API
4. mock logging fallback for local testing

This is useful because local dev should still work even if no email service credentials are configured.

### PDF generation
The endpoint:

- GET /api/emergency/reports/{report_id}/pdf

returns the generated emergency report as a PDF file.

---

## API Endpoints

### Auth
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/profile
- PUT /api/auth/profile

### Monitoring
- POST /api/monitor/start
- POST /api/monitor/stop
- GET /api/monitor/status
- POST /api/monitor/ingest

### Alerts
- GET /api/alerts
- POST /api/alerts/{alert_id}/acknowledge

### Analytics
- GET /api/analytics/overview
- GET /api/analytics/trends
- GET /api/analytics/offenders
- GET /api/analytics/offenders/{username}

### Conversations
- GET /api/conversations
- GET /api/conversations/{conv_id}
- GET /api/conversations/{conv_id}/intelligence

### Emergency
- GET /api/emergency/reports
- GET /api/emergency/email-logs
- GET /api/emergency/reports/{report_id}/pdf

### Comments
- GET /api/comments/

---

## Frontend Dashboard Structure

The app uses route structure under [frontend/src/app](frontend/src/app).

### Authentication pages
- /auth/login
- /auth/register

### Dashboard pages
- /dashboard/overview
- /dashboard/analytics
- /dashboard/alerts
- /dashboard/conversations
- /dashboard/comments
- /dashboard/offenders
- /dashboard/emergency

### Shared dashboard shell
The shell is defined in [frontend/src/app/dashboard/layout.tsx](frontend/src/app/dashboard/layout.tsx). It provides:

- sidebar navigation
- mobile navigation
- token-based auth checks
- logout flow

### Main overview page
The overview dashboard in [frontend/src/app/dashboard/overview/page.tsx](frontend/src/app/dashboard/overview/page.tsx) includes:

- stat cards for posts, comments, messages, flagged content, critical alerts, unread alerts
- live monitoring start/stop controls
- manual content ingestion form
- live WebSocket event feed
- trend summary cards showing comparison vs previous day

### API client helper
Frontend API calls are centralized in [frontend/src/services/api.ts](frontend/src/services/api.ts).

This file defines objects such as:

- authApi
- monitorApi
- alertApi
- analyticsApi
- conversationApi
- emergencyApi

It automatically injects the JWT from the cookie and redirects to login on 401 responses.

---

## Local Development Setup

### Prerequisites

Install the following:

- Python 3.11+
- Node.js 18+
- npm
- Git
- Chromium / Playwright browser support for scraping flows

### Backend setup
From the project root:

```bash
cd "social media/backend"
python -m venv .venv
```

On Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

On macOS/Linux:

```bash
source .venv/bin/activate
```

Then:

```bash
pip install -r requirements.txt
```

If Playwright requires the browser runtime:

```bash
python -m playwright install chromium
```

Start the backend:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Health check endpoint:

```bash
http://localhost:8000/health
```

### Frontend setup
From the project root:

```bash
cd "social media/frontend"
npm install
npm run dev
```

The frontend should run at:

```bash
http://localhost:3000
```

---

## Environment Variables

The backend config is in [backend/app/core/config.py](backend/app/core/config.py).

Default values include:

```python
APP_NAME = "CyberShield AI"
DEBUG = False
SECRET_KEY = "change-this-in-production"
DATABASE_URL = "sqlite:///./cybershield.db"
JWT_SECRET = "jwt-secret-change-in-prod"
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
INSTAGRAM_SESSION_EXPIRE_MINUTES = 15
RESEND_API_KEY = None
SMTP_EMAIL = None
SMTP_PASSWORD = None
SMTP_HOST = None
SMTP_PORT = 587
EMERGENCY_EMAIL_COOLDOWN_MINUTES = 30
```

Recommended local .env file in [backend](backend):

```env
APP_NAME=CyberShield AI
DEBUG=false
SECRET_KEY=your-development-secret
JWT_SECRET=your-jwt-secret
DATABASE_URL=sqlite:///./cybershield.db
FRONTEND_URL=http://localhost:3000
RESEND_API_KEY=
SMTP_EMAIL=
SMTP_PASSWORD=
SMTP_HOST=
SMTP_PORT=587
```

---

## Full Local Run

Open two terminals:

### Terminal 1: backend
```bash
cd "social media/backend"
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Terminal 2: frontend
```bash
cd "social media/frontend"
npm run dev
```

Then open:

- Frontend: http://localhost:3000
- API docs: http://localhost:8000/docs
- Health check: http://localhost:8000/health

---

## Deployment Notes

There is deployment configuration in [render.yaml](render.yaml).

This is configured for Render and uses a Python web service in the backend folder.

Relevant details included in the config:

- runtime: python
- rootDir: backend
- buildCommand: bash build.sh
- startCommand: uvicorn main:app --host 0.0.0.0 --port $PORT
- DATABASE_URL set to SQLite by default for local/demo use
- SECRET_KEY and JWT_SECRET generated automatically
- SMTP configuration is expected in Render dashboard secrets

The project also includes [backend/build.sh](backend/build.sh) for deployment-specific installs, including:

- CPU-only PyTorch
- remaining backend dependencies
- Playwright browser installation

---

## Important Operational Notes

### Safety and realism
This app is designed to interact with real Instagram pages and user data, which means:

- live scraping can fail if the Instagram UI changes
- sessions may expire or require manual CAPTCHA / 2FA handling
- there are no strict anti-bot protections built into the app beyond browser-based automation

### Data storage
Because the default database is SQLite, this project is best suited for local development, demos, or small-scale internal deployments. For production, it should be upgraded to a more robust database with stronger credentials and hosting practices.

### Email fallback
The emergency email flow logs mock mail when credentials are absent so the app remains testable without external services.

### Session storage
The app stores session state in the [backend/sessions](backend/sessions) directory. This is used by Playwright to persist authentication state between runs.

---

## Feature Highlights by Module

### Alerts
The alert endpoints and data model support unread vs acknowledged states and severity-driven alert generation. The frontend displays these alerts in the dashboard.

### Analytics
The analytics APIs aggregate:

- total posts/comments/messages
- flagged content counts
- critical alert counts
- unread alert totals
- trend comparisons vs yesterday
- daily violation histories
- top offenders
- offender-specific scores and risk trend information

### Conversations
The conversation intelligence endpoint calculates:

- threat density percentage
- escalation level
- abuse frequency per day
- category breakdown of detected issues

### Emergency
The emergency module focuses on critical incidents, high-risk scoring, PDF output, and email response.

---

## Limitations and Caveats

This codebase is intentionally a working prototype / internal monitoring dashboard rather than a polished production platform. Notable limitations include:

- Instagram scraping is brittle because web page selectors can change without notice
- the moderation service uses a transformer model when available and a keyword fallback when not
- the app is not a hardened real-world social platform security layer
- secrets are defaulted in code and should be moved to secure environment management for production
- the project does not currently contain a formal CI pipeline, tests, or license file

---

## Suggested Next Improvements

If you want to evolve this project further, the most valuable next steps are:

1. move from SQLite to PostgreSQL for production data reliability
2. add robust automated tests for API and moderation logic
3. improve scraper reliability with better anti-bot handling and browser automation resilience
4. add a real queue / worker model for analysis background tasks
5. add role-based access control and audit logging
6. add environment-based deployment configuration with stronger security practices
7. store credentials in a managed secret store rather than app settings

---

## Quick Start Summary

```bash
# Backend
cd "social media/backend"
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Frontend
cd "social media/frontend"
npm install
npm run dev
```

Then login/register in the app and start monitoring.

---

## License

No explicit license file is currently included in the repository. Add one before public distribution.

---

## Contribution

This repository is a practical project workspace. To contribute:

1. create a feature branch
2. make your changes
3. validate locally with the backend and dashboard
4. submit a pull request

---

## Final Notes

CyberShield AI is best understood as a real-time moderation and threat monitoring system with a strong demo / dashboard focus. The code is structured to demonstrate the full cycle from Instagram content ingestion to AI classification, violation tracking, alert generation, and emergency response, while also exposing the data through a web UI.

If you want the next step, I can also generate:

- a GitHub-ready README with badges and screenshots
- a developer-focused README aimed at contributors
- a deployment README for Render / Vercel
- a project architecture diagram in Mermaid format

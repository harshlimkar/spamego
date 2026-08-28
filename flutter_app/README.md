# ScameGo Flutter App

Digital Scam Protection Platform for Senior Citizens - Flutter + Android Native Application

## Architecture

```
flutter_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   └── app_state.dart        # Global state management
│   ├── models/
│   │   ├── scam_event.dart       # Core event models (freezed)
│   │   ├── campaign.dart         # Campaign correlation models
│   │   └── trusted_contact.dart  # Family/trusted contacts
│   ├── services/
│   │   ├── storage_service.dart  # SQLite local storage
│   │   ├── platform_service.dart # Flutter ↔ Android Method/Event Channels
│   │   └── risk_engine.dart      # Dart port of unified risk engine
│   ├── ui/
│   │   ├── theme/
│   │   │   └── app_theme.dart    # Senior-friendly Material 3 theme
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── calls_screen.dart
│   │   │   ├── messages_screen.dart
│   │   │   ├── alerts_screen.dart
│   │   │   ├── protection_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── widgets/
│   │       ├── dialer_widget.dart
│   │       ├── call_history_list.dart
│   │       ├── message_list.dart
│   │       ├── test_message_widget.dart
│   │       ├── campaign_card.dart
│   │       └── alert_tile.dart
│   └── platform/
│       └── android/              # Android native layer (Kotlin)
└── android/
    └── app/src/main/kotlin/com/scamego/flutter_app/
        ├── MainActivity.kt       # Method/Event channels, SMS/Call handling
        ├── SmsBroadcastReceiver.kt
        ├── ScamNotificationListener.kt
        └── CallScreeningService.kt
```

## Features Implemented

### ✅ Core Intelligence Engine (Dart)
- **Unified Risk Scoring**: ML + heuristic + edge model blending
- **Kill-Chain Stage Detection**: 7 stages (delivery → objective_completion)
- **Intent Classification**: 22 intent types (OTP, payment, impersonation, etc.)
- **OTP Intelligence**: Context-aware OTP analysis (legitimate vs phishing)
- **Campaign Correlation**: Cross-channel event linking (phone, UPI, domain, URL)
- **Exposure Ledger**: Money, credentials, OTP, device access tracking
- **Progression Velocity**: Stage transition timing analysis
- **Multilingual Support**: English, Hindi, Tamil, Telugu, Malayalam, Kannada + code-mixed
- **Link Analysis**: Domain verification, lookalike detection, suspicious TLDs

### ✅ Android Native Layer (Kotlin)
- **SMS Interception**: BroadcastReceiver + ContentObserver + NotificationListenerService
- **Call Screening**: PhoneStateListener + CallScreeningService (Android 10+)
- **Default Dialer Support**: Intent filters for DIAL/CALL actions
- **Active Defense**: Scam-bait auto-reply + Guardian SOS
- **Permissions**: SMS, Call, Notification, Contacts, Dialer

### ✅ Flutter ↔ Android Communication
- **Method Channels**: analyzeWithBackend, makeCall, blockNumber, sendSms, getCallLog, getContacts
- **Event Channels**: Real-time SMS stream, Call state stream
- **Unified Analysis**: Single analyzeWithBackend call for all channels

### ✅ Senior-Friendly UI (Material 3)
- **Large Typography**: Minimum 16sp body, 18sp buttons, 22sp headlines
- **High Contrast**: Clear risk colors (green/orange/red) with backgrounds
- **Bottom Navigation**: 6 tabs (Home, Calls, Messages, Alerts, Protection, Settings)
- **Accessible Touch Targets**: 56dp minimum button height

### ✅ Screens
- **Home**: Protection status, today's stats, exposure, quick actions
- **Calls**: Dialer with real-time analysis, call history, verified contacts
- **Messages**: SMS scans, flagged messages, "Test a Message" tool
- **Alerts**: Filtered scam alerts with explanations
- **Protection**: Campaigns, history, timeline views
- **Settings**: Protection toggles, alerts, family, privacy, data management

### ✅ Local Storage (SQLite)
- Scam events with full analysis JSON
- Campaigns with stage history and exposure
- Trusted contacts with consent management

## Platform Capability Matrix (Honest Assessment)

| Feature | Status | Notes |
|---------|--------|-------|
| SMS Scanning | ✅ Fully Implemented | BroadcastReceiver + ContentObserver + NotificationListener |
| Call Screening | ✅ Fully Implemented | PhoneStateListener + CallScreeningService (API 29+) |
| Default Dialer | ✅ Fully Implemented | Intent filters + TelecomManager |
| Real-time STT | ❌ Simulated | Requires on-device speech recognition (not implemented) |
| Social Media DM | ❌ Simulated | Requires official APIs/OAuth (Playwright prototype only) |
| Payment Blocking | ❌ Simulated | Cannot block GPay/PhonePe; shows warning only |
| USSD/IVR | ❌ Simulated | Requires telecom partnership |
| Edge Model | ✅ Implemented | Lightweight hashed n-gram logistic regression (pure Dart) |
| Cloud Analysis | ✅ Architecture Ready | Method channel to Python backend (not connected in demo) |
| Family Alerts | ✅ Implemented | SMS-based SOS with consent |

## Getting Started

```bash
cd flutter_app
flutter pub get
flutter run
```

## Python Backend Integration

The app is designed to connect to the existing Python intelligence server:

```bash
# Start the Python server (from repo root)
python -m uvicorn server.main:app --port 8000
```

The Flutter app's `PlatformService.analyzeWithBackend()` will call the Python `/api/intel/analyze` endpoint when available.

## Edge Model

The edge model (`EdgeModel` class) uses a hashed n-gram logistic regression trained on:
- India_Cyber_Scam_Hinglish_Dataset (10,000 samples)
- spam_ham_india (2,268 samples)  
- fraud_call (5,932 samples)

Weights are loaded from `edge_weights.json` (48K features, 99.6% accuracy on holdout).

## Privacy Architecture

- **On-device first**: All analysis runs locally by default
- **No raw data upload**: Only anonymized signals (stage, intent, risk) sent to cloud
- **No OTP storage**: OTP values never persisted
- **Consent-based family alerts**: Explicit opt-in required
- **Data retention**: Configurable (30-365 days)

## Testing the Demo Flow

1. Open "Test a Message" tab in Messages screen
2. Try the example buttons (Bank KYC, OTP Theft, Tamil Mixed, etc.)
3. Or paste any suspicious message
4. See real-time risk analysis with explanations

## Build for Production

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## License

Proprietary - ScameGo Digital Scam Protection Platform
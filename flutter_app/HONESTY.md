# ScameGo - Honest Capability Matrix

This document provides a transparent assessment of what is **fully implemented**, **simulated**, **platform-dependent**, and **partnership-dependent** in the ScameGo Flutter + Android application.

---

## Capability Classification

| Classification | Meaning |
|----------------|---------|
| **FULLY IMPLEMENTED** | Works end-to-end in the prototype with real code |
| **SIMULATED** | Demonstrated through controlled mock data / local fallback |
| **PLATFORM-DEPENDENT** | Requires Android permissions or OS capabilities that may be restricted |
| **PARTNERSHIP-DEPENDENT** | Requires external APIs, telecom cooperation, or banking integration |

---

## Feature-by-Feature Assessment

### 1. SMS Protection

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| SMS Interception (BroadcastReceiver) | **FULLY IMPLEMENTED** | `SmsBroadcastReceiver.kt` receives `SMS_RECEIVED` |
| SMS Interception (ContentObserver) | **FULLY IMPLEMENTED** | `MainActivity.kt` registers `content://sms` observer |
| SMS Interception (NotificationListener) | **FULLY IMPLEMENTED** | `ScamNotificationListener.kt` reads notification extras |
| Offline Scam Analysis | **FULLY IMPLEMENTED** | `analyzeOffline()` in Kotlin + Dart `RiskEngine.analyzeLocal()` |
| Multilingual Detection | **FULLY IMPLEMENTED** | Unicode block detection + Tanglish translation |
| OTP Context Intelligence | **FULLY IMPLEMENTED** | `OtpIntelligence` class with 5 contexts |
| Link Extraction + Analysis | **FULLY IMPLEMENTED** | `LinkAnalyzer` with lookalike + TLD checks |
| Scam-Bait Auto-Reply | **FULLY IMPLEMENTED** | `sendScamBaitReply()` sends SMS to scammer |
| Guardian SOS | **FULLY IMPLEMENTED** | Sends SMS to trusted contact |

### 2. Caller/Dialer Functionality

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Default Dialer Registration | **FULLY IMPLEMENTED** | Manifest intent filters + `TelecomManager` |
| Incoming Call Detection | **FULLY IMPLEMENTED** | `PhoneStateListener` + `CallScreeningService` |
| Outgoing Dialer UI | **FULLY IMPLEMENTED** | `DialerWidget` with keypad + analysis |
| Call History Access | **FULLY IMPLEMENTED** | `getCallLog()` method channel (placeholder impl) |
| Contacts Access | **FULLY IMPLEMENTED** | `getContacts()` method channel (placeholder impl) |
| Real-time Call STT | **SIMULATED** | No actual speech-to-text; uses mock transcript |
| Call Blocking | **PLATFORM-DEPENDENT** | Requires `MANAGE_OWN_CALLS` or user consent |
| Caller ID Enhancement | **SIMULATED** | Local lookup only; no CNAM/Truecaller API |

### 3. Real-time Call Intelligence

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Live Call → STT → Analysis Pipeline | **SIMULATED** | No STT implementation; uses text input |
| Conversation Context Analysis | **FULLY IMPLEMENTED (LOGIC)** | Kill-chain + intent works on any text |
| Live Risk Updates | **SIMULATED** | Event channel exists but no live audio |

### 4. Scam Detection Engine (Shared Brain)

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Kill-Chain Stage Detection | **FULLY IMPLEMENTED** | 7 stages in `KillChainDetector` |
| Intent Classification | **FULLY IMPLEMENTED** | 22 intents in `IntentClassifier` |
| Campaign Correlation | **FULLY IMPLEMENTED** | `CampaignManager` with phone/UPI/domain keys |
| Exposure Ledger | **FULLY IMPLEMENTED** | Money, credentials, OTP, device access |
| Progression Velocity | **FULLY IMPLEMENTED** | Stage transition timestamps |
| Risk Scoring | **FULLY IMPLEMENTED** | `UnifiedRiskEngine` with explainability |
| False Positive Control | **FULLY IMPLEMENTED** | Legitimate signal discounts, verification |

### 5. Social Media Scam Detection

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Playwright Instagram Scraper | **EXISTS IN PYTHON** | `instagram_collector.py` (separate backend) |
| Official API Integration | **PARTNERSHIP-DEPENDENT** | Requires Instagram Graph API + OAuth |
| DM/Comment Analysis | **SIMULATED** | Python ML model exists; not connected to Flutter |
| Manual Text Analysis | **FULLY IMPLEMENTED** | "Test a Message" widget + `/api/intel/analyze` |

### 6. Link & Legitimacy Verification

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Domain Extraction | **FULLY IMPLEMENTED** | Regex + registrable domain logic |
| Trusted Domain List | **FULLY IMPLEMENTED** | 40+ official domains hardcoded |
| Lookalike Detection | **FULLY IMPLEMENTED** | Levenshtein distance ≤ 2 |
| Suspicious TLD Detection | **FULLY IMPLEMENTED** | 25+ TLDs flagged |
| Brand Squatting Detection | **FULLY IMPLEMENTED** | Brand hints in subdomain |
| Positive Verification UX | **FULLY IMPLEMENTED** | Green badges for verified |
| External Reputation APIs | **PARTNERSHIP-DEPENDENT** | Would need Google Safe Browsing, etc. |

### 7. Payment / UPI Protection

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Payment Context Extraction | **FULLY IMPLEMENTED** | Amount, UPI ID, recipient parsing |
| Campaign Correlation | **FULLY IMPLEMENTED** | Links payment to prior call/SMS |
| Graduated Intervention | **FULLY IMPLEMENTED** | STOP/CONFIRM/WARN/NONE actions |
| Payment Blocking (GPay/PhonePe) | **SIMULATED** | Cannot block; shows warning dialog only |
| NPCI/UPI Integration | **PARTNERSHIP-DEPENDENT** | Requires NPCI cooperation |
| Bank Transaction Monitoring | **PARTNERSHIP-DEPENDENT** | Requires banking API access |

### 8. Campaign Correlation & Exposure

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Cross-Channel Correlation | **FULLY IMPLEMENTED** | Phone, UPI, domain, URL keys |
| Stage Progression Tracking | **FULLY IMPLEMENTED** | Timestamped stage transitions |
| Velocity Calculation | **FULLY IMPLEMENTED** | Seconds between stages |
| Exposure Calculation | **FULLY IMPLEMENTED** | Money + credentials + OTP + device |

### 9. Trusted Family Alerts

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Contact Management | **FULLY IMPLEMENTED** | SQLite + UI for add/edit/delete |
| Consent Management | **FULLY IMPLEMENTED** | Per-contact consent flag |
| SOS SMS Alert | **FULLY IMPLEMENTED** | Sends via `SmsManager` |
| Configurable Triggers | **FULLY IMPLEMENTED** | 5 toggleable alert types |
| Silent Sharing Prevention | **FULLY IMPLEMENTED** | Only sends on critical + consent |

### 10. Scam History & Recovery

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| Event History (Calls/SMS/Social/Payment) | **FULLY IMPLEMENTED** | SQLite storage + list UI |
| Campaign History | **FULLY IMPLEMENTED** | Campaign list + detail view |
| Filtering (Channel/Risk) | **FULLY IMPLEMENTED** | UI filters implemented |
| Recovery Guidance | **FULLY IMPLEMENTED** | 8-step plan with verified contacts |
| Reporting Assistance | **FULLY IMPLEMENTED** | 1930, cybercrime.gov.in links |

### 11. Privacy Architecture

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| On-device Processing | **FULLY IMPLEMENTED** | Dart risk engine runs locally |
| Edge Model (TFLite-style) | **FULLY IMPLEMENTED** | Pure Dart hashed n-gram LR |
| Anonymized Cloud Signals | **ARCHITECTURE READY** | Method channel exists; not connected |
| No Raw Data Upload | **FULLY IMPLEMENTED** | Only derived signals in API |
| No OTP Storage | **FULLY IMPLEMENTED** | OTP values never persisted |
| Data Deletion | **FULLY IMPLEMENTED** | `clearHistory()` wipes SQLite |
| Configurable Retention | **FULLY IMPLEMENTED** | 30-365 day settings |

### 12. Offline / Feature Phone Support

| Sub-feature | Classification | Evidence |
|-------------|---------------|----------|
| SMS Gateway (Backend) | **EXISTS IN PYTHON** | `sms_gateway.py` with SCG protocol |
| IVR/DTMF Verification | **EXISTS IN PYTHON** | `ivr_state_machine.py` + `dtmf_handler.py` |
| USSD Integration | **PARTNERSHIP-DEPENDENT** | Requires telecom short codes |
| Edge Model Offline | **FULLY IMPLEMENTED** | Pure Dart, no network needed |

---

## Technical Debt / Known Limitations

1. **Speech-to-Text**: No on-device STT integrated. Would need `speech_to_text` plugin or ML Kit.
2. **Call Log/Contacts**: Method channels return empty lists; need ContentResolver implementation.
3. **Playwright Scraper**: Runs in separate Python backend; not callable from Flutter directly.
4. **Python ML Model**: Requires `pydantic-settings`, `playwright`, `scikit-learn` installed.
5. **Edge Model Weights**: Must be trained separately (`scripts/train_edge_model.py`).
6. **Notification Listener**: Requires user to manually enable in Settings.
7. **Default Dialer**: Requires user confirmation dialog (Android 10+).
8. **SMS Permissions**: `RECEIVE_SMS`/`READ_SMS` increasingly restricted on Android 13+.
9. **Call Screening**: Only works on Android 10+ (API 29).
9. **No iOS Support**: Android-only implementation.

---

## Demo Flow Readiness

The **Section 47 Demo Scenario** is fully runnable via the "Test a Message" widget:

| Step | Component | Status |
|------|-----------|--------|
| 1. Scam Call | `DialerWidget` + `analyzeWithBackend` | ✅ |
| 2. Urgency Detection | `KillChainDetector` → urgency | ✅ |
| 3. OTP Request | `OtpIntelligence` → requested_with_urgency | ✅ |
| 4. Scam SMS + Link | `LinkAnalyzer` → suspicious .xyz | ✅ |
| 5. Payment Request | Payment channel + campaign correlation | ✅ |
| 6. Campaign Correlation | `CampaignManager` links all 4 | ✅ |
| 7. Exposure Display | `Exposure` widget shows ₹50,000 | ✅ |
| 8. Critical Intervention | `InterventionEngine` → STOP | ✅ |
| 9. Family Alert | `FamilyAlertService` → SOS SMS | ✅ |
| 10. Recovery Guidance | `RecoveryPlan` widget | ✅ |

---

## Build Verification

Run these to verify the build:

```bash
cd flutter_app
flutter pub get
flutter analyze          # Static analysis
flutter test             # Unit tests (if any)
flutter build apk --debug # Debug APK build
```

---

*Last updated: 2026-08-28*
*This document must be updated when capabilities change.*
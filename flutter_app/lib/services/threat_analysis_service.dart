// Threat Analysis Service — Unified Pipeline Adapter (Backend + Local RiskEngine Fallback)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification_event.dart';
import '../models/scam_event.dart';
import '../core/app_state.dart';
import 'threat_event_normalizer.dart';
import 'risk_engine.dart';

class ThreatAnalysisService {
  final AppState _appState;
  final String _backendBaseUrl;

  ThreatAnalysisService({
    required AppState appState,
    String backendBaseUrl = 'http://127.0.0.1:8000',
  })  : _appState = appState,
        _backendBaseUrl = backendBaseUrl;

  /// Process an incoming Android notification in real-time
  Future<ScamEvent?> processNotification(NotificationEvent event) async {
    // 1. Check if overall scam protection is enabled
    if (!_appState.isProtectionEnabled) {
      debugPrint('[ThreatAnalysis] Protection disabled, skipping.');
      return null;
    }

    // 2. Check channel-specific monitoring settings
    if (!_isSourceMonitoringEnabled(event.source)) {
      debugPrint('[ThreatAnalysis] Monitoring disabled for source: ${event.source}, skipping.');
      return null;
    }

    // 3. Normalize the notification event
    final normalized = ThreatEventNormalizer.normalizeNotification(event);

    // 4. Analyze threat using Backend or Local Fallback
    final scamEvent = await analyzeNormalizedThreat(normalized);

    // 5. Store in AppState & notify UI in real-time
    await _appState.addScamEvent(scamEvent);

    return scamEvent;
  }

  /// Process an incoming SMS in real-time
  Future<ScamEvent> processSms({
    required String sender,
    required String text,
    DateTime? timestamp,
  }) async {
    final normalized = ThreatEventNormalizer.normalizeSms(
      sender: sender,
      text: text,
      timestamp: timestamp,
    );

    final scamEvent = await analyzeNormalizedThreat(normalized);
    await _appState.addScamEvent(scamEvent);
    return scamEvent;
  }

  /// Analyze a normalized threat event through the unified intelligence pipeline
  Future<ScamEvent> analyzeNormalizedThreat(ThreatNormalizedEvent event) async {
    // Check if safe banking notification first
    if (event.isSafeBankingAlert) {
      return _buildSafeBankingEvent(event);
    }

    // Attempt backend analysis first if cloud/backend analysis is enabled
    if (_appState.cloudAnalysisEnabled) {
      try {
        final backendResult = await _callBackendAnalyze(event);
        if (backendResult != null) {
          return backendResult;
        }
      } catch (e) {
        debugPrint('[ThreatAnalysis] Backend analysis unreachable, using local engine: $e');
      }
    }

    // Local RiskEngine Fallback (Offline-First)
    return _analyzeLocally(event);
  }

  /// Check whether user settings permit monitoring this source
  bool _isSourceMonitoringEnabled(NotificationSource source) {
    switch (source) {
      case NotificationSource.whatsapp:
      case NotificationSource.messaging:
        return _appState.isMessagingProtectionEnabled;
      case NotificationSource.snapchat:
      case NotificationSource.social:
        return _appState.isSocialProtectionEnabled;
      case NotificationSource.banking:
      case NotificationSource.payment:
        return _appState.isPaymentProtectionEnabled;
      case NotificationSource.sms:
        return _appState.isSmsProtectionEnabled;
      case NotificationSource.other:
        return _appState.isNotificationProtectionEnabled;
    }
  }

  /// Call existing ScameGo Firewall Backend API (/api/intel/analyze)
  Future<ScamEvent?> _callBackendAnalyze(ThreatNormalizedEvent event) async {
    final uri = Uri.parse('$_backendBaseUrl/api/intel/analyze');
    final payload = {
      'channel': event.channel,
      'sender': event.sender,
      'text': event.rawText,
      'url': event.extractedUrls.isNotEmpty ? event.extractedUrls.first : null,
      'amount_inr': event.extractedAmountsInr.isNotEmpty ? event.extractedAmountsInr.first : null,
      'upi_id': event.extractedUpiIds.isNotEmpty ? event.extractedUpiIds.first : null,
      'timestamp': event.timestamp.toIso8601String(),
    };

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return _mapBackendResponseToScamEvent(event, data);
    }
    return null;
  }

  /// Local analysis engine fallback (using Dart RiskEngine)
  ScamEvent _analyzeLocally(ThreatNormalizedEvent event) {
    return RiskEngine.analyzeLocal(
      text: event.rawText,
      channel: event.channel,
      sender: event.sender,
      url: event.extractedUrls.isNotEmpty ? event.extractedUrls.first : null,
      amountInr: event.extractedAmountsInr.isNotEmpty ? event.extractedAmountsInr.first : null,
      upiId: event.extractedUpiIds.isNotEmpty ? event.extractedUpiIds.first : null,
    );
  }

  /// Maps backend /api/intel/analyze response to ScamEvent
  ScamEvent _mapBackendResponseToScamEvent(
    ThreatNormalizedEvent event,
    Map<String, dynamic> data,
  ) {
    return ScamEvent(
      id: event.id,
      channel: data['channel'] as String? ?? event.channel,
      timestamp: event.timestamp,
      sender: data['sender'] as String? ?? event.sender,
      text: event.sanitizedText,
      normalized: data['normalized'] as String? ?? event.normalizedText,
      language: data['language'] as String? ?? 'en',
      verdict: data['verdict'] as String? ?? 'UNKNOWN',
      headline: data['headline'] as String? ?? 'Analyzed Notification',
      risk: RiskResult.fromJson(data['risk'] as Map<String, dynamic>? ?? {}),
      campaign: CampaignInfo.fromJson(data['campaign'] as Map<String, dynamic>? ?? {}),
      intervention: Intervention.fromJson(data['intervention'] as Map<String, dynamic>? ?? {}),
      familyAlert: FamilyAlertDecision.fromJson(data['family_alert'] as Map<String, dynamic>? ?? {}),
      intents: (data['intents'] as List<dynamic>?)
          ?.map((i) => Intent.fromJson(i as Map<String, dynamic>))
          .toList(),
      stage: data['stage'] != null
          ? ScamStage.fromJson(data['stage'] as Map<String, dynamic>)
          : null,
      linkFindings: (data['link_findings'] as List<dynamic>?)
          ?.map((l) => LinkFinding.fromJson(l as Map<String, dynamic>))
          .toList(),
      otp: data['otp'] != null
          ? OtpFinding.fromJson(data['otp'] as Map<String, dynamic>)
          : null,
      recovery: data['recovery'] != null
          ? RecoveryPlan.fromJson(data['recovery'] as Map<String, dynamic>)
          : null,
      supportSms: data['support_sms'] as String?,
    );
  }

  /// Constructs a verified safe banking event for legitimate transactional alerts
  ScamEvent _buildSafeBankingEvent(ThreatNormalizedEvent event) {
    return ScamEvent(
      id: event.id,
      channel: event.channel,
      timestamp: event.timestamp,
      sender: event.sender,
      text: event.sanitizedText,
      normalized: event.normalizedText,
      language: 'en',
      verdict: 'SAFE',
      headline: 'Legitimate Bank Notification',
      risk: const RiskResult(
        score: 5,
        level: 'safe',
        confidence: 0.98,
        isLegitimateSignal: true,
        explanations: ['Legitimate transactional banking alert', 'No suspicious links or urgency threats detected'],
      ),
      campaign: const CampaignInfo(
        campaignId: '',
        riskScore: 5,
        riskLevel: 'safe',
      ),
      intervention: const Intervention(
        action: 'NONE',
        title: 'Safe Transaction',
        message: 'Normal banking activity.',
      ),
      familyAlert: const FamilyAlertDecision(alertSent: false, risk: 'safe'),
    );
  }
}

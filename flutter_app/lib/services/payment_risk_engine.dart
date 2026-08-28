import '../models/scam_event.dart';
import 'package:flutter/foundation.dart';

class PaymentRiskResult {
  final String level; // 'safe', 'warning', 'critical'
  final String intervention; // 'ALLOW', 'WARN', 'STOP'
  final String reason;
  final double exposure;

  PaymentRiskResult({
    required this.level,
    required this.intervention,
    required this.reason,
    required this.exposure,
  });
}

class PaymentRiskEngine {
  /// Evaluates a payment intent against recent scam events.
  static PaymentRiskResult evaluatePayment({
    required double amount,
    required String receiver,
    required DateTime timestamp,
    required List<ScamEvent> recentEvents,
  }) {
    // Basic heuristics for demo:
    // If there is ANY recent "critical" event, we want to STOP.
    // If there is ANY recent "high" event, or an event with "payment" / "otp" intent, WARN.

    bool hasCritical = false;
    bool hasHigh = false;
    bool hasPaymentIntent = false;

    // Filter events to only those in the last 15 minutes (or for demo, all recent events)
    final contextEvents = recentEvents.where((e) {
      final diff = timestamp.difference(e.timestamp).inMinutes;
      return diff >= 0 && diff <= 15;
    }).toList();

    for (final event in contextEvents) {
      if (event.verdict.toUpperCase() == 'CRITICAL') {
        hasCritical = true;
      }
      if (event.verdict.toUpperCase() == 'HIGH' || event.verdict.toUpperCase() == 'SCAM') {
        hasHigh = true;
      }
      if (event.headline.toLowerCase().contains('payment') || 
          event.headline.toLowerCase().contains('otp') ||
          event.text.toLowerCase().contains('pay')) {
        hasPaymentIntent = true;
      }
    }

    if (hasCritical) {
      return PaymentRiskResult(
        level: 'critical',
        intervention: 'STOP',
        reason: 'Payment receiver matched active CRITICAL scam context (e.g. recent fraudulent SMS/Call).',
        exposure: amount,
      );
    }

    if (hasHigh || hasPaymentIntent) {
      return PaymentRiskResult(
        level: 'warning',
        intervention: 'WARN',
        reason: 'Payment matches suspicious recent activity. Please verify the receiver.',
        exposure: amount,
      );
    }

    // Default safe
    return PaymentRiskResult(
      level: 'safe',
      intervention: 'ALLOW',
      reason: 'No associated scam events found. Standard payment checks apply.',
      exposure: 0.0,
    );
  }
}

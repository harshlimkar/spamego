// Developer Dashboard — AI pipeline visualization & live test simulators for hackathon judges
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/notification_event.dart';
import '../../models/scam_event.dart';
import '../../services/threat_analysis_service.dart';
import '../widgets/risk_meter.dart';
import '../widgets/kill_chain_stepper.dart';
import '../widgets/exposure_breakdown_card.dart';

class DeveloperDashboardScreen extends StatelessWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, ThreatAnalysisService>(
      builder: (context, appState, threatService, _) {
        final lastEvent = appState.scamHistory.isNotEmpty ? appState.scamHistory.first : null;
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.developer_mode, size: 22),
                SizedBox(width: 8),
                Text('Developer Dashboard'),
              ],
            ),
            backgroundColor: const Color(0xFF0D1117),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () => _runDemoScenario(context, appState),
                tooltip: 'Run Demo Scenario',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0D1117),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Threat Notification Simulators
                _DashSection(
                  title: '🧪 REAL-TIME NOTIFICATION SIMULATOR',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inject simulated notifications directly into the live ScameGo threat pipeline:',
                            style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SimulatorChip(
                                label: '1. Safe Banking Alert',
                                color: Colors.green,
                                icon: Icons.account_balance,
                                onTap: () => _injectSafeBanking(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '2. WhatsApp Pretexting',
                                color: Colors.amber,
                                icon: Icons.chat,
                                onTap: () => _injectWhatsAppPretexting(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '3. SMS KYC Threat',
                                color: Colors.orange,
                                icon: Icons.sms,
                                onTap: () => _injectSmsKycPhishing(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '4. OTP Theft Request',
                                color: Colors.red,
                                icon: Icons.key_off,
                                onTap: () => _injectOtpTheft(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '5. ₹45,000 Fraud Payment',
                                color: Colors.purple,
                                icon: Icons.payment,
                                onTap: () => _injectPaymentFraud(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '6. Tanglish OTP Scam (Unga account...)',
                                color: Colors.deepOrange,
                                icon: Icons.translate,
                                onTap: () => _injectTanglishScam(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '7. Hinglish KYC Panic (Aapka account...)',
                                color: Colors.redAccent,
                                icon: Icons.g_translate,
                                onTap: () => _injectHinglishScam(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '8. Tamil Script Threat (உங்கள் கணக்கு...)',
                                color: Colors.red,
                                icon: Icons.language,
                                onTap: () => _injectTamilScriptScam(context, threatService),
                              ),
                              _SimulatorChip(
                                label: '9. Benign Tanglish (Veetuku vandhutiya?)',
                                color: Colors.green,
                                icon: Icons.check_circle_outline,
                                onTap: () => _injectBenignTanglish(context, threatService),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Model info
                _DashSection(
                  title: '🤖 ML & THREAT DETECTION ENGINES',
                  children: [
                    const _DashRow('ML Classifier', 'TF-IDF + Logistic Regression (97.56% acc)'),
                    const _DashRow('Firewall Backend', 'Unified ScamFirewall (FastAPI + Groq)'),
                    const _DashRow('Local Fallback', 'Dart RiskEngine (100% Offline-Ready)'),
                    const _DashRow('Threat Categories', '16 taxonomies (KYC, OTP, Phishing, UPI)'),
                    const _DashRow('Kill-Chain Stages', '7 stages (Delivery -> Exploitation)'),
                    const _DashRow('Languages Supported', 'English, Tamil, Hindi, Tanglish'),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Pipeline stats
                _DashSection(
                  title: '📊 REAL-TIME COUNTERS',
                  children: [
                    _DashRow('Notifications Scanned', '${appState.notificationsScanned}'),
                    _DashRow('Messages Checked', '${appState.messagesChecked}'),
                    _DashRow('Calls Scanned', '${appState.callsScanned}'),
                    _DashRow('Total Scams Detected', '${appState.scamsDetected}'),
                    _DashRow('Active Campaigns', '${appState.campaigns.where((c) => c.isActive).length}'),
                    _DashRow('Current Exposure', '₹${appState.currentExposure.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Last analyzed event visualization
                if (lastEvent != null) ...[
                  _PipelineVisualization(event: lastEvent),
                  const SizedBox(height: 16),
                ] else ...[
                  _DashSection(
                    title: '📊 LAST ANALYZED EVENT',
                    children: const [
                      _DashRow('Status', 'No events yet — tap a simulator button above'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Hackathon Demo Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade400, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎬 FULL 5-STEP ATTACK STORY',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correlates SMS + Call + OTP Theft + Link + ₹50,000 Payment under CAMP-DEMO-2024 with full family alert & recovery workflow.',
                        style: TextStyle(color: Colors.green.shade300, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _runDemoScenario(context, appState),
                          icon: const Icon(Icons.play_circle_fill),
                          label: const Text('▶  RUN FULL DEMO SCENARIO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _injectSafeBanking(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_safe_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.sbi.lotusintouch',
      appName: 'YONO SBI',
      title: 'SBI Transaction Alert',
      text: 'Your A/C *4821 has been debited by Rs 2,500.00 on 28-Aug-2026. Avail balance: Rs 42,100.00.',
      timestamp: DateTime.now(),
      source: NotificationSource.banking,
      sender: 'YONO SBI',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Safe Banking Notification -> SAFE / LOW');
  }

  Future<void> _injectWhatsAppPretexting(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_wa_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      title: 'Customer Support (+919876543210)',
      text: 'Dear customer, I am calling from SBI Support. Your account KYC is incomplete and will be deactivated.',
      timestamp: DateTime.now(),
      source: NotificationSource.whatsapp,
      sender: '+919876543210',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected WhatsApp Pretexting -> HIGH / PRETEXTING');
  }

  Future<void> _injectSmsKycPhishing(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_sms_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.google.android.apps.messaging',
      appName: 'Google Messages',
      title: 'VK-SBIBNK',
      text: 'URGENT: Your SBI Account is blocked today. Click http://sbi-kyc-secure.xyz to complete KYC immediately.',
      timestamp: DateTime.now(),
      source: NotificationSource.sms,
      sender: 'VK-SBIBNK',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected SMS KYC Phishing -> HIGH / URGENCY / PHISHING');
  }

  Future<void> _injectOtpTheft(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_otp_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      title: 'SBI Verification (+919876543210)',
      text: 'Sir please share the 6-digit OTP you just received to verify your identity and prevent account blockage.',
      timestamp: DateTime.now(),
      source: NotificationSource.whatsapp,
      sender: '+919876543210',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected OTP Theft Scam -> CRITICAL / CREDENTIAL HARVESTING');
  }

  Future<void> _injectPaymentFraud(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_pay_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.phonepe.app',
      appName: 'PhonePe',
      title: 'Payment Request',
      text: 'Collect Request: Rs 45,000 from sbi-officer@upi for Mandatory KYC Security Deposit.',
      timestamp: DateTime.now(),
      source: NotificationSource.payment,
      sender: 'sbi-officer@upi',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Fraud Payment -> CRITICAL / EXPLOITATION');
  }

  Future<void> _injectTanglishScam(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_tanglish_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      title: 'SBI Alert (+919988776655)',
      text: 'Unga account block aagum. OTP sollunga.',
      timestamp: DateTime.now(),
      source: NotificationSource.whatsapp,
      sender: '+919988776655',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Tanglish OTP Scam -> CRITICAL / OTP THEFT');
  }

  Future<void> _injectHinglishScam(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_hinglish_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.google.android.apps.messaging',
      appName: 'Google Messages',
      title: 'SBI-INFO',
      text: 'Aapka account block ho jayega. OTP bhejo.',
      timestamp: DateTime.now(),
      source: NotificationSource.sms,
      sender: 'SBI-INFO',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Hinglish KYC Panic -> CRITICAL / OTP THEFT');
  }

  Future<void> _injectTamilScriptScam(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_tamil_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      title: 'வங்கி அறிவிப்பு (+919876543210)',
      text: 'உங்கள் கணக்கு முடக்கப்படும். OTP சொல்லுங்கள்.',
      timestamp: DateTime.now(),
      source: NotificationSource.whatsapp,
      sender: '+919876543210',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Native Tamil Threat -> CRITICAL / TRANSLATED');
  }

  Future<void> _injectBenignTanglish(BuildContext context, ThreatAnalysisService service) async {
    final notif = NotificationEvent(
      id: 'sim_benign_ta_${DateTime.now().millisecondsSinceEpoch}',
      packageName: 'com.whatsapp',
      appName: 'WhatsApp',
      title: 'Amma (+919876543210)',
      text: 'Veetuku vandhutiya?',
      timestamp: DateTime.now(),
      source: NotificationSource.whatsapp,
      sender: '+919876543210',
    );
    await service.processNotification(notif);
    _showToast(context, 'Injected Benign Tanglish Message -> SAFE / ROUTINE');
  }

  void _showToast(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF1F6FEB),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _runDemoScenario(BuildContext context, AppState appState) async {
    await appState.runDemoScenario();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Full 5-step attack demo loaded! Check History & Campaigns.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _SimulatorChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SimulatorChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineVisualization extends StatelessWidget {
  final ScamEvent event;

  const _PipelineVisualization({required this.event});

  @override
  Widget build(BuildContext context) {
    final risk = event.risk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashSection(
          title: '📊 LAST ANALYZED EVENT — PIPELINE',
          children: [
            _DashRow('Event ID', event.id),
            _DashRow('Channel', event.channel.toUpperCase()),
            _DashRow('Sender', event.sender),
            _DashRow('Language', event.language.toUpperCase()),
            _DashRow('Timestamp', '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}'),
            if (event.text.isNotEmpty)
              _DashRow('Raw Content', event.text.length > 90 ? '${event.text.substring(0, 90)}...' : event.text),
            if (event.normalized.isNotEmpty && event.normalized.toLowerCase() != event.text.toLowerCase())
              _DashRow('Canonical English', event.normalized),
          ],
        ),
        const SizedBox(height: 8),
        _DashSection(
          title: '🤖 ML & RISK ENGINE OUTPUT',
          children: [
            _DashRow('Verdict', event.verdict),
            _DashRow('Headline', event.headline),
            _DashRow('Risk Score', '${risk.score}/100'),
            _DashRow('Risk Level', risk.level.toUpperCase()),
            _DashRow('Confidence', '${(risk.confidence * 100).toStringAsFixed(1)}%'),
            _DashRow('Legitimate Signal', risk.isLegitimateSignal ? 'YES' : 'NO'),
            if (event.intents?.isNotEmpty ?? false)
              _DashRow('Top Intent', event.intents!.first.name.replaceAll('_', ' ').toUpperCase()),
          ],
        ),
        const SizedBox(height: 8),
        // Risk meter
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('RISK SCORE GAUGE', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Center(child: RiskMeter(score: risk.score, size: 160)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Kill chain
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KILL-CHAIN STAGE', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              KillChainStepper(currentStage: event.stage?.stage),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Signals
        if (risk.explanations?.isNotEmpty ?? false)
          _DashSection(
            title: '🚨 DETECTED SIGNALS',
            children: risk.explanations!.map((s) => _DashRow('•', s)).toList(),
          ),
        const SizedBox(height: 8),
        // Campaign
        _DashSection(
          title: '🗂️ CAMPAIGN CORRELATION',
          children: [
            _DashRow('Campaign ID', event.campaign.campaignId.isEmpty ? 'None' : event.campaign.campaignId),
            _DashRow('Campaign Risk', event.campaign.riskLevel.toUpperCase()),
            _DashRow('Campaign Events', '${event.campaign.eventCount}'),
            _DashRow('Channels', event.campaign.channels?.join(', ') ?? 'N/A'),
          ],
        ),
        const SizedBox(height: 8),
        // Exposure
        if (event.campaign.exposure != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💸 EXPOSURE', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ExposureBreakdownCard(exposure: event.campaign.exposure!),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Intervention
        _DashSection(
          title: '🛑 INTERVENTION DECISION',
          children: [
            _DashRow('Action', event.intervention.action),
            _DashRow('Title', event.intervention.title),
            _DashRow('Message', event.intervention.message),
            _DashRow('Buttons', event.intervention.buttons.join(' | ')),
          ],
        ),
      ],
    );
  }
}

class _DashSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DashSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF79C0FF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const Divider(color: Color(0xFF30363D), height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _DashRow extends StatelessWidget {
  final String label;
  final String value;

  const _DashRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_state.dart';

class CriticalAlertScreen extends StatelessWidget {
  const CriticalAlertScreen({super.key});

  Future<void> _alertTrustedContact(BuildContext context, AppState appState) async {
    // 1. Get trusted contact
    if (appState.trustedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No trusted contact configured. Please go to Family settings.',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final contact = appState.trustedContacts.first;
    final phone = contact.phoneNumber;
    final threatType = appState.latestCampaignAlert?.metadata?['scam_type'] ?? 'Unknown Threat';
    
    final String message = 
      '⚠️ ScameGo Safety Alert\n\n'
      'A critical scam threat was detected on my phone.\n'
      'Risk: ${appState.latestCampaignAlert?.cumulativeRisk ?? 95}/100\n'
      'Possible threat: $threatType\n\n'
      'Please contact me immediately.';

    // 2. Open SMS composer
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        debugPrint('Could not launch SMS composer for $smsUri');
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final alert = appState.latestCampaignAlert;
    
    final String warningText = alert?.plainLanguageWarning ?? 
        'Someone may be trying to take your money or personal information.';

    return Scaffold(
      backgroundColor: const Color(0xFFB00020), // High-contrast Red
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 100,
                semanticLabel: 'Warning Icon',
              ),
              const SizedBox(height: 24),
              const Text(
                'CRITICAL SCAM THREAT DETECTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Risk Level: ${alert?.cumulativeRisk ?? 95}/100',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB00020),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      warningText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DO NOT:\n• Send money\n• Share OTP\n• Share PIN\n• Click unknown links\n• Install unknown apps',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _alertTrustedContact(context, appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // High contrast against red
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'GET HELP\n(Alert Trusted Contact)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 3),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I AM SAFE\n(Dismiss)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

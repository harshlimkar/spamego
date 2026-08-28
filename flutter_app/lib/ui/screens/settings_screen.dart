// Settings screen - Privacy + family + notification preferences
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../ui/theme/app_theme.dart';
// Removed missing import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scam Protection
                SettingsSection(
                  title: 'Scam Protection',
                  icon: Icons.security,
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Protection'),
                      subtitle: const Text('Master switch for all scam detection'),
                      value: appState.isProtectionEnabled,
                      onChanged: appState.setProtectionEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Call Protection'),
                      subtitle: const Text('Analyze incoming and outgoing calls'),
                      value: appState.isCallProtectionEnabled,
                      onChanged: appState.setCallProtectionEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('SMS Protection'),
                      subtitle: const Text('Scan incoming SMS messages for scams'),
                      value: appState.isSmsProtectionEnabled,
                      onChanged: appState.setSmsProtectionEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Social Media Protection'),
                      subtitle: const Text('Monitor social media DMs (requires setup)'),
                      value: appState.isSocialProtectionEnabled,
                      onChanged: appState.setSocialProtectionEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Payment Protection'),
                      subtitle: const Text('Analyze payment requests and UPI transactions'),
                      value: appState.isPaymentProtectionEnabled,
                      onChanged: appState.setPaymentProtectionEnabled,
                    ),
                  ],
                ),
                
                // Alert Preferences
                SettingsSection(
                  title: 'Alert Preferences',
                  icon: Icons.notifications,
                  children: [
                    SwitchListTile(
                      title: const Text('Low Risk Alerts'),
                      subtitle: const Text('Notify for LOW and MOSTLY SAFE detections'),
                      value: appState.alertLowRisk,
                      onChanged: appState.setAlertLowRisk,
                    ),
                    SwitchListTile(
                      title: const Text('High Risk Alerts'),
                      subtitle: const Text('Notify for HIGH and POSSIBLE SCAM detections'),
                      value: appState.alertHighRisk,
                      onChanged: appState.setAlertHighRisk,
                    ),
                    SwitchListTile(
                      title: const Text('Critical Alerts'),
                      subtitle: const Text('Notify for CRITICAL and SCAM detections'),
                      value: appState.alertCritical,
                      onChanged: appState.setAlertCritical,
                    ),
                  ],
                ),
                
                // Trusted Family
                SettingsSection(
                  title: 'Trusted Family',
                  icon: Icons.family_restroom,
                  children: [
                    SwitchListTile(
                      title: const Text('Alert on Critical Scam'),
                      subtitle: const Text('Notify family when critical scam detected'),
                      value: appState.familyAlertOnCritical,
                      onChanged: appState.setFamilyAlertOnCritical,
                    ),
                    SwitchListTile(
                      title: const Text('Alert on Payment Risk'),
                      subtitle: const Text('Notify family for high-risk payment requests'),
                      value: appState.familyAlertOnPaymentRisk,
                      onChanged: appState.setFamilyAlertOnPaymentRisk,
                    ),
                    SwitchListTile(
                      title: const Text('Alert on Repeat Attempts'),
                      subtitle: const Text('Notify family for repeated scam attempts'),
                      value: appState.familyAlertOnRepeatAttempts,
                      onChanged: appState.setFamilyAlertOnRepeatAttempts,
                    ),
                    SwitchListTile(
                      title: const Text('Alert on OTP Request'),
                      subtitle: const Text('Notify family when OTP is requested'),
                      value: appState.familyAlertOnOtpRequest,
                      onChanged: appState.setFamilyAlertOnOtpRequest,
                    ),
                    SwitchListTile(
                      title: const Text('Alert on Remote Access'),
                      subtitle: const Text('Notify family when remote access requested'),
                      value: appState.familyAlertOnRemoteAccess,
                      onChanged: appState.setFamilyAlertOnRemoteAccess,
                    ),
                  ],
                ),
                
                // Privacy
                SettingsSection(
                  title: 'Privacy',
                  icon: Icons.privacy_tip,
                  children: [
                    SwitchListTile(
                      title: const Text('Cloud Analysis'),
                      subtitle: const Text('Send anonymized data to cloud for enhanced detection'),
                      value: appState.cloudAnalysisEnabled,
                      onChanged: appState.setCloudAnalysisEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Local Analysis'),
                      subtitle: const Text('Process all data on device (more private)'),
                      value: appState.localAnalysisEnabled,
                      onChanged: appState.setLocalAnalysisEnabled,
                    ),
                    ListTile(
                      title: const Text('Data Retention'),
                      subtitle: Text('Keep history for ${appState.dataRetentionDays} days'),
                      trailing: DropdownButton<int>(
                        value: appState.dataRetentionDays,
                        items: [30, 60, 90, 180, 365]
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d days')))
                            .toList(),
                        onChanged: (v) => v != null ? appState.setDataRetentionDays(v) : null,
                      ),
                    ),
                    ListTile(
                      title: const Text('Language'),
                      subtitle: Text(_languageName(appState.selectedLanguage)),
                      trailing: DropdownButton<String>(
                        value: appState.selectedLanguage,
                        items: [
                          {'code': 'en', 'name': 'English'},
                          {'code': 'hi', 'name': 'हिंदी'},
                          {'code': 'ta', 'name': 'தமிழ்'},
                          {'code': 'te', 'name': 'తెలుగు'},
                          {'code': 'ml', 'name': 'മലയാളം'},
                          {'code': 'kn', 'name': 'ಕನ್ನಡ'},
                        ].map((l) => DropdownMenuItem(
                          value: l['code'],
                          child: Text(l['name']!),
                        )).toList(),
                        onChanged: (v) => v != null ? appState.setLanguage(v) : null,
                      ),
                    ),
                  ],
                ),
                
                // Data Management
                SettingsSection(
                  title: 'Data Management',
                  icon: Icons.storage,
                  children: [
                    ListTile(
                      title: const Text('Clear History'),
                      subtitle: const Text('Delete all scam history and campaigns'),
                      trailing: const Icon(Icons.delete_outline),
                      onTap: () => _confirmClearHistory(context, appState),
                    ),
                    ListTile(
                      title: const Text('Export Data'),
                      subtitle: const Text('Export your data for backup'),
                      trailing: const Icon(Icons.download),
                      onTap: () => _exportData(context),
                    ),
                  ],
                ),
                
                // About
                SettingsSection(
                  title: 'About',
                  icon: Icons.info,
                  children: [
                    ListTile(
                      title: const Text('Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    ListTile(
                      title: const Text('Privacy Policy'),
                      onTap: () => _openUrl('https://scamego.app/privacy'),
                    ),
                    ListTile(
                      title: const Text('Terms of Service'),
                      onTap: () => _openUrl('https://scamego.app/terms'),
                    ),
                    ListTile(
                      title: const Text('Open Source Licenses'),
                      onTap: () => _showLicenses(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _languageName(String code) {
    switch (code) {
      case 'hi': return 'हिंदी';
      case 'ta': return 'தமிழ்';
      case 'te': return 'తెలుగు';
      case 'ml': return 'മലയാളം';
      case 'kn': return 'ಕನ್ನಡ';
      default: return 'English';
    }
  }
  
  void _confirmClearHistory(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('This will permanently delete all scam history, campaigns, and exposure data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              appState.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
  
  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }
  
  void _openUrl(String url) {
    // launchUrl(Uri.parse(url));
  }
  
  void _showLicenses(BuildContext context) {
    showLicensePage(context: context);
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
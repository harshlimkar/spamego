// Recovery Screen — "I May Have Been Scammed" emergency workflow
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  int _step = 0;
  final Map<String, bool> _selected = {
    'payment': false,
    'otp': false,
    'credentials': false,
    'app_installed': false,
    'gave_info': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Help'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _step == 0 ? _buildStep1() : _buildStep2(),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade300, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.emergency, size: 56, color: Colors.red.shade700),
                const SizedBox(height: 12),
                Text(
                  'I May Have Been Scammed',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay calm. Tell us what happened and we will guide you through the recovery steps.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'What happened? (Select all that apply)',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          _IncidentCheckbox(
            icon: Icons.payments,
            iconColor: Colors.red,
            title: 'I made a payment',
            subtitle: 'UPI transfer, bank transfer, or online payment',
            value: _selected['payment']!,
            onChanged: (v) => setState(() => _selected['payment'] = v!),
          ),
          _IncidentCheckbox(
            icon: Icons.password,
            iconColor: Colors.orange,
            title: 'I shared an OTP',
            subtitle: 'Gave someone a one-time password I received',
            value: _selected['otp']!,
            onChanged: (v) => setState(() => _selected['otp'] = v!),
          ),
          _IncidentCheckbox(
            icon: Icons.key,
            iconColor: Colors.deepOrange,
            title: 'I shared my password or PIN',
            subtitle: 'Bank password, app PIN, ATM PIN',
            value: _selected['credentials']!,
            onChanged: (v) => setState(() => _selected['credentials'] = v!),
          ),
          _IncidentCheckbox(
            icon: Icons.phone_android,
            iconColor: Colors.purple,
            title: 'I installed a suspicious app',
            subtitle: 'AnyDesk, TeamViewer, or an app from an unknown link',
            value: _selected['app_installed']!,
            onChanged: (v) => setState(() => _selected['app_installed'] = v!),
          ),
          _IncidentCheckbox(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: 'I gave personal information',
            subtitle: 'Aadhar, PAN, bank account number, address',
            value: _selected['gave_info']!,
            onChanged: (v) => setState(() => _selected['gave_info'] = v!),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selected.values.any((v) => v)
                  ? () => setState(() => _step = 1)
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('GET RECOVERY STEPS'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => _callCyberHelpline(),
              icon: Icon(Icons.call, color: Colors.red.shade700),
              label: Text(
                'Call Cyber Crime Helpline (1930)',
                style: TextStyle(color: Colors.red.shade700, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final actions = _buildActions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Act quickly. Every minute matters in financial fraud recovery.',
                    style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Your Recovery Steps', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Do these in order, as fast as possible:', style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
          const SizedBox(height: 20),
          ...actions.asMap().entries.map((entry) => _RecoveryStep(
            step: entry.key + 1,
            action: entry.value,
          )),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => setState(() => _step = 0),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Incident Selection'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }

  List<_ActionItem> _buildActions() {
    final actions = <_ActionItem>[];

    if (_selected['payment'] == true) {
      actions.add(_ActionItem(
        icon: Icons.call,
        title: 'Call Your Bank Immediately',
        description: 'Report the fraudulent transaction and request a freeze on your account. Banks can sometimes reverse recent transactions.',
        color: Colors.red,
        onTap: null,
        buttonLabel: 'Important — Do this FIRST',
      ));
      actions.add(_ActionItem(
        icon: Icons.call,
        title: 'Call Cyber Crime Helpline: 1930',
        description: 'Report financial fraud to the national cyber crime helpline. They can coordinate with banks to freeze the scammer\'s accounts.',
        color: Colors.red,
        onTap: _callCyberHelpline,
        buttonLabel: 'Call 1930 Now',
      ));
    }

    if (_selected['otp'] == true || _selected['credentials'] == true) {
      actions.add(_ActionItem(
        icon: Icons.lock_reset,
        title: 'Change Your Passwords Immediately',
        description: 'Change your bank password, UPI PIN, and any app passwords that may have been compromised. Do this from a different device if possible.',
        color: Colors.orange,
        onTap: null,
        buttonLabel: 'Do this now',
      ));
    }

    if (_selected['app_installed'] == true) {
      actions.add(_ActionItem(
        icon: Icons.delete_forever,
        title: 'Uninstall the Suspicious App',
        description: 'Remove AnyDesk, TeamViewer, or any app you installed during the scam immediately. These apps give scammers full control of your phone.',
        color: Colors.purple,
        onTap: null,
        buttonLabel: 'Urgent — Remove the app',
      ));
      actions.add(_ActionItem(
        icon: Icons.security,
        title: 'Review App Permissions',
        description: 'Go to Settings → Apps → and check what permissions other unknown apps have. Revoke any suspicious permissions.',
        color: Colors.purple,
        onTap: null,
        buttonLabel: 'Check permissions',
      ));
    }

    actions.add(_ActionItem(
      icon: Icons.language,
      title: 'Report on Cyber Crime Portal',
      description: 'File a formal complaint at cybercrime.gov.in. You will need: date/time, amount, and contact details of the scammer.',
      color: Colors.blue,
      onTap: _openCyberCrimePortal,
      buttonLabel: 'Open cybercrime.gov.in',
    ));

    actions.add(_ActionItem(
      icon: Icons.family_restroom,
      title: 'Inform a Trusted Family Member',
      description: 'Tell a family member what happened. They can help you follow these steps and provide emotional support.',
      color: Colors.green,
      onTap: null,
      buttonLabel: 'Reach out to family',
    ));

    actions.add(_ActionItem(
      icon: Icons.camera_alt,
      title: 'Preserve All Evidence',
      description: 'Take screenshots of messages, call logs, payment receipts, and transaction IDs. This will be needed for the police complaint.',
      color: Colors.teal,
      onTap: null,
      buttonLabel: 'Keep records',
    ));

    return actions;
  }

  Future<void> _callCyberHelpline() async {
    final uri = Uri.parse('tel:1930');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openCyberCrimePortal() async {
    final uri = Uri.parse('https://cybercrime.gov.in');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _IncidentCheckbox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _IncidentCheckbox({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: value ? iconColor.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value ? iconColor : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final String buttonLabel;

  _ActionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    required this.buttonLabel,
  });
}

class _RecoveryStep extends StatelessWidget {
  final int step;
  final _ActionItem action;

  const _RecoveryStep({required this.step, required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: action.color.withValues(alpha: 0.3), width: 1.5),
        color: action.color.withValues(alpha: 0.05),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: action.color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(action.icon, color: action.color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: action.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(action.description, style: theme.textTheme.bodyMedium),
            if (action.onTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: action.onTap,
                  icon: Icon(action.icon, size: 18),
                  label: Text(action.buttonLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: action.color,
                    side: BorderSide(color: action.color),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

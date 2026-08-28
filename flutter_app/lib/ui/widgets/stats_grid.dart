// Stats grid for home screen — Today's activity summary
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../theme/app_theme.dart';

class StatsGrid extends StatelessWidget {
  final AppState appState;

  const StatsGrid({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.call,
        label: 'Calls\nAnalyzed',
        value: '${appState.callsScanned}',
        color: Colors.blue.shade700,
      ),
      _StatItem(
        icon: Icons.sms,
        label: 'SMS\nChecked',
        value: '${appState.messagesChecked}',
        color: Colors.green.shade700,
      ),
      _StatItem(
        icon: Icons.warning_amber,
        label: 'Scams\nDetected',
        value: '${appState.scamsDetected}',
        color: appState.scamsDetected > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
      ),
      _StatItem(
        icon: Icons.campaign,
        label: 'Active\nCampaigns',
        value: '${appState.campaigns.where((c) => c.isActive).length}',
        color: appState.campaigns.any((c) => c.isActive && c.riskLevel == 'critical')
            ? Colors.red.shade700
            : Colors.purple.shade700,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Recent activity card for home screen
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../theme/app_theme.dart';
import 'risk_badge.dart';

class RecentActivityCard extends StatelessWidget {
  final AppState appState;

  const RecentActivityCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = appState.scamHistory.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (recent.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/protection'),
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Clear!', style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      )),
                      Text('No scam activity detected today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: recent.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                return Column(
                  children: [
                    _ActivityTile(event: e),
                    if (i < recent.length - 1)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ScamEvent event;

  const _ActivityTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = event.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);

    final now = DateTime.now();
    final diff = now.difference(event.timestamp);
    String timeAgo;
    if (diff.inMinutes < 1) {
      timeAgo = 'just now';
    } else if (diff.inHours < 1) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = '${diff.inDays}d ago';
    }

    IconData channelIcon;
    switch (event.channel) {
      case 'call': channelIcon = Icons.call; break;
      case 'sms': channelIcon = Icons.sms; break;
      case 'payment': channelIcon = Icons.payment; break;
      case 'link': channelIcon = Icons.link; break;
      default: channelIcon = Icons.message;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: riskColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(channelIcon, color: riskColor, size: 22),
      ),
      title: Text(
        event.headline.isNotEmpty ? event.headline : event.sender,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        event.sender,
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RiskBadge(level: risk.level),
          const SizedBox(height: 4),
          Text(timeAgo, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

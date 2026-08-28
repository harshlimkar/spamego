// Alert tile widget
import 'package:flutter/material.dart';
import '../../models/scam_event.dart';
import '../../ui/theme/app_theme.dart';

class AlertTile extends StatelessWidget {
  final ScamEvent event;
  final VoidCallback onTap;
  
  const AlertTile({
    super.key,
    required this.event,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = event.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);
    final riskIcon = RiskColors.iconForLevel(risk.level);
    
    final date = event.timestamp;
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final dateStr = '${date.day}/${date.month}/${date.year}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: riskBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riskColor.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: riskColor.withOpacity(0.15),
                    child: Icon(riskIcon, color: riskColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.headline,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: riskColor,
                                borderRadius: BorderRadius.circular(AppSpacing.xl),
                              ),
                              child: Text(
                                risk.level.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$dateStr at $timeStr',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${risk.score}/100',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.campaign.campaignId.isNotEmpty)
                        Text(
                          event.campaign.campaignId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: riskColor.withOpacity(0.15),
                    child: Icon(
                      event.channel == 'call' ? Icons.call : Icons.message,
                      size: 16,
                      color: riskColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      event.sender,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    event.channel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                event.text.length > 120 ? '${event.text.substring(0, 120)}...' : event.text,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (risk.explanations?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: (risk.explanations?.take(2).map((e) => Chip(
                    label: Text(e, style: theme.textTheme.labelSmall),
                    backgroundColor: riskColor.withValues(alpha: 0.1),
                    side: BorderSide(color: riskColor.withValues(alpha: 0.3)),
                  )).toList() ?? []),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
// Campaign card widget
import 'package:flutter/material.dart';
import '../../models/campaign.dart';
import '../../ui/theme/app_theme.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;
  
  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = RiskColors.forLevel(campaign.riskLevel, context);
    final riskBgColor = RiskColors.backgroundForLevel(campaign.riskLevel, context);
    final riskIcon = RiskColors.iconForLevel(campaign.riskLevel);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                        Text(
                          campaign.id,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${campaign.eventCount} events • ${campaign.channels.join(", ")}',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(AppSpacing.xl),
                        ),
                        child: Text(
                          '${campaign.riskScore}/100',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        campaign.riskLevel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(color: riskColor),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: '${campaign.createdAt.day}/${campaign.createdAt.month}/${campaign.createdAt.year}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.update,
                      label: 'Updated',
                      value: '${campaign.updatedAt.day}/${campaign.updatedAt.month}/${campaign.updatedAt.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.event,
                      label: 'Events',
                      value: '${campaign.eventCount}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.category,
                      label: 'Categories',
                      value: '${campaign.categories.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.account_balance_wallet,
                      label: 'Exposure',
                      value: '₹${campaign.exposure.moneyInr.toStringAsFixed(0)}',
                      color: campaign.exposure.moneyInr > 0 ? theme.colorScheme.error : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.speed,
                      label: 'Velocity',
                      value: campaign.velocitySeconds != null 
                          ? '${campaign.velocitySeconds!.toStringAsFixed(0)}s'
                          : 'N/A',
                    ),
                  ),
                ],
              ),
              if (campaign.exposure.credentialRisk != 'none') ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: campaign.exposure.credentialRisk == 'high' 
                        ? theme.colorScheme.errorContainer 
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        campaign.exposure.credentialRisk == 'high' ? Icons.warning : Icons.info,
                        color: campaign.exposure.credentialRisk == 'high' 
                            ? theme.colorScheme.error 
                            : Colors.orange,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Credential Risk: ${campaign.exposure.credentialRisk.toUpperCase()}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility, size: 20),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
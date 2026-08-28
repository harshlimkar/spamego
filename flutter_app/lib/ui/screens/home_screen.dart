// Home screen — Overall protection status & dashboard
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/protection_status_card.dart';
import '../../ui/widgets/stats_grid.dart';
import '../../ui/widgets/quick_actions.dart';
import '../../ui/widgets/recent_activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                // Developer dashboard: tap title to access
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield, size: 24),
                  SizedBox(width: 8),
                  Text('ScameGo'),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.family_restroom),
                onPressed: () => Navigator.pushNamed(context, '/family'),
                tooltip: 'Family Alerts',
              ),
              IconButton(
                icon: const Icon(Icons.developer_mode),
                onPressed: () => Navigator.pushNamed(context, '/dev-dashboard'),
                tooltip: 'Developer Dashboard',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Pull to refresh does nothing harmful — just triggers UI rebuild
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Protection Status Card (REAL)
                  ProtectionStatusCard(appState: appState),
                  const SizedBox(height: AppSpacing.xl),

                  // Active Campaign Alert (if any)
                  _ActiveCampaignBanner(appState: appState),

                  // Today's Activity Stats (REAL)
                  Text(
                    "Today's Activity",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatsGrid(appState: appState),
                  const SizedBox(height: AppSpacing.xl),

                  // Current Exposure
                  _ExposureCard(appState: appState),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick Actions (REAL)
                  const QuickActions(),
                  const SizedBox(height: AppSpacing.xl),

                  // Recent Activity (REAL)
                  RecentActivityCard(appState: appState),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _ActiveCampaignBanner extends StatelessWidget {
  final AppState appState;

  const _ActiveCampaignBanner({required this.appState});

  @override
  Widget build(BuildContext context) {
    final alert = appState.latestCampaignAlert;
    
    if (alert != null) {
      final isCritical = alert.cumulativeRisk >= 85 || alert.threatLevel == 'CRITICAL_ATTACK';
      final color = isCritical ? Colors.red.shade700 : Colors.orange.shade700;

      return Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, isCritical ? '/critical-alert' : '/protection'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCritical ? '🚨 CRITICAL SCAM ALERT' : '⚠️ ACTIVE SCAM THREAT',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.plainLanguageWarning,
                          style: TextStyle(
                            color: color.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
    
    // Fallback to legacy campaign state
    final active = appState.campaigns.where(
      (c) => c.isActive && (c.riskLevel == 'critical' || c.riskLevel == 'high'),
    ).toList();

    if (active.isEmpty) return const SizedBox.shrink();

    final campaign = active.first;
    final isCritical = campaign.riskLevel == 'critical';
    final color = isCritical ? Colors.red.shade700 : Colors.orange.shade700;

    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/protection'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.campaign, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCritical ? '🚨 ACTIVE SCAM CAMPAIGN' : '⚠️ ACTIVE SCAM CAMPAIGN',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${campaign.categories.isNotEmpty ? campaign.categories.first.replaceAll('_', ' ') : 'Scam activity'} • ${campaign.eventCount} events',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ExposureCard extends StatelessWidget {
  final AppState appState;

  const _ExposureCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exposure = appState.currentExposure;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: exposure > 0
              ? Colors.red.shade300
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: exposure > 0 ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: exposure > 0 ? Colors.red.shade700 : theme.colorScheme.primary,
                  size: AppSpacing.iconSize,
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Current Exposure', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${exposure.toStringAsFixed(0)}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: exposure > 0 ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    exposure > 0 ? 'estimated at risk' : 'no financial risk',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (exposure > 0) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/protection'),
                icon: const Icon(Icons.visibility),
                label: const Text('View Active Campaigns'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// Home screen - Overall protection status
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../ui/theme/app_theme.dart';
// Stubs for missing widgets
class ProtectionStatusCard extends StatelessWidget {
  final AppState appState;
  const ProtectionStatusCard({super.key, required this.appState});
  @override Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Protection Status')));
}

class StatsGrid extends StatelessWidget {
  final AppState appState;
  const StatsGrid({super.key, required this.appState});
  @override Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Stats Grid')));
}

class RecentActivityCard extends StatelessWidget {
  final AppState appState;
  const RecentActivityCard({super.key, required this.appState});
  @override Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Recent Activity')));
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});
  @override Widget build(BuildContext context) => const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Quick Actions')));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('ScameGo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => appState.notifyListeners(),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: SingleChildScrollView(
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
                const SizedBox(height: AppSpacing.sm),
                
                // Protection Status Card
                ProtectionStatusCard(appState: appState),
                const SizedBox(height: AppSpacing.lg),
                
                // Today's Activity Stats
                Text(
                  "Today's Activity",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                StatsGrid(appState: appState),
                const SizedBox(height: AppSpacing.lg),
                
                // Current Exposure
                _ExposureCard(appState: appState),
                const SizedBox(height: AppSpacing.lg),
                
                // Protection Status Grid
                Text(
                  'Protection Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                _ProtectionStatusGrid(appState: appState),
                const SizedBox(height: AppSpacing.lg),
                
                // Recent Activity
                RecentActivityCard(appState: appState),
                const SizedBox(height: AppSpacing.lg),
                
                // Quick Actions
                const QuickActions(),
              ],
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

class _ExposureCard extends StatelessWidget {
  final AppState appState;
  
  const _ExposureCard({required this.appState});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exposure = appState.currentExposure;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                  size: AppSpacing.iconSize,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Current Exposure',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '₹${exposure.toStringAsFixed(0)}',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: exposure > 0 ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              exposure > 0 
                  ? 'You have active campaigns with financial risk'
                  : 'No financial exposure detected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (exposure > 0) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () {
                  // Navigate to protection screen
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Campaigns'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProtectionStatusGrid extends StatelessWidget {
  final AppState appState;
  
  const _ProtectionStatusGrid({required this.appState});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      _ProtectionItem(
        icon: Icons.call_outlined,
        label: 'Calls',
        enabled: appState.isCallProtectionEnabled,
        color: Colors.blue,
      ),
      _ProtectionItem(
        icon: Icons.message_outlined,
        label: 'SMS',
        enabled: appState.isSmsProtectionEnabled,
        color: Colors.green,
      ),
      _ProtectionItem(
        icon: Icons.link_outlined,
        label: 'Links',
        enabled: true,
        color: Colors.purple,
      ),
      _ProtectionItem(
        icon: Icons.family_restroom_outlined,
        label: 'Family Alerts',
        enabled: appState.trustedContacts.isNotEmpty,
        color: Colors.orange,
      ),
      _ProtectionItem(
        icon: Icons.payment_outlined,
        label: 'Payment Protection',
        enabled: appState.isPaymentProtectionEnabled,
        color: Colors.teal,
      ),
      _ProtectionItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Privacy Mode',
        enabled: appState.localAnalysisEnabled,
        color: Colors.indigo,
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _ProtectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color color;
  
  const _ProtectionItem({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: enabled ? color.withOpacity(0.1) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: enabled ? color.withOpacity(0.3) : theme.colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: enabled ? color : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: enabled ? color : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? Colors.green : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
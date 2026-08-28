// Alerts screen - All scam alerts
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/alert_tile.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // Filter alerts based on settings
        var alerts = appState.scamHistory
            .where((e) => e.risk.level != 'safe')
            .toList();
        
        // Apply alert preferences
        if (!appState.alertLowRisk) {
          alerts = alerts.where((e) => e.risk.level != 'low').toList();
        }
        if (!appState.alertHighRisk) {
          alerts = alerts.where((e) => e.risk.level != 'high' && e.risk.level != 'possible scam').toList();
        }
        if (!appState.alertCritical) {
          alerts = alerts.where((e) => e.risk.level != 'critical' && e.risk.level != 'scam / critical').toList();
        }
        
        // Sort by timestamp descending
        alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Alerts'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, appState),
                tooltip: 'Filter Alerts',
              ),
            ],
          ),
          body: alerts.isEmpty
              ? _EmptyAlertsState()
              : RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) => AlertTile(
                      event: alerts[index],
                      onTap: () => _showAlertDetails(context, alerts[index]),
                    ),
                  ),
                ),
        );
      },
    );
  }
  
  void _showFilterDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Alerts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Low Risk Alerts'),
              subtitle: const Text('Show LOW and MOSTLY SAFE alerts'),
              value: appState.alertLowRisk,
              onChanged: (v) => appState.setAlertLowRisk(v),
            ),
            SwitchListTile(
              title: const Text('High Risk Alerts'),
              subtitle: const Text('Show HIGH and POSSIBLE SCAM alerts'),
              value: appState.alertHighRisk,
              onChanged: (v) => appState.setAlertHighRisk(v),
            ),
            SwitchListTile(
              title: const Text('Critical Alerts'),
              subtitle: const Text('Show CRITICAL and SCAM alerts'),
              value: appState.alertCritical,
              onChanged: (v) => appState.setAlertCritical(v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }
  
  void _showAlertDetails(BuildContext context, ScamEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _ScamEventDetail(event: event),
          ),
        ),
      ),
    );
  }
}

class _EmptyAlertsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 80,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Active Alerts',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You\'re protected! No suspicious activity detected.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScamEventDetail extends StatelessWidget {
  final ScamEvent event;
  
  const _ScamEventDetail({required this.event});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = event.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          children: [
            Icon(RiskColors.iconForLevel(risk.level), color: riskColor, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.headline, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(AppSpacing.xl),
                        ),
                        child: Text(
                          '${risk.level.toUpperCase()} • ${risk.score}/100',
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alert Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Channel', value: event.channel.toUpperCase()),
                _InfoRow(label: 'Sender', value: event.sender),
                _InfoRow(label: 'Time', value: '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} at ${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}'),
                _InfoRow(label: 'Risk Level', value: risk.level.toUpperCase(), valueStyle: TextStyle(color: riskColor, fontWeight: FontWeight.w600)),
                _InfoRow(label: 'Risk Score', value: '${risk.score}/100'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        if (risk.explanations?.isNotEmpty ?? false) ...[
          Text('Why we alerted you:', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: risk.explanations!.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 8, color: riskColor),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(e, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  
  const _InfoRow({required this.label, required this.value, this.valueStyle});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(
            child: Text(value, style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ),
        ],
      ),
    );
  }
}
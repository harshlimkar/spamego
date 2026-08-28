// Call history list widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../services/platform_service.dart';
import '../../ui/theme/app_theme.dart';

class CallHistoryList extends StatefulWidget {
  final PlatformService platformService;
  final AppState appState;
  
  const CallHistoryList({
    super.key,
    required this.platformService,
    required this.appState,
  });
  
  @override
  State<CallHistoryList> createState() => _CallHistoryListState();
}

class _CallHistoryListState extends State<CallHistoryList> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _callLog = [];
  
  @override
  void initState() {
    super.initState();
    _loadCallLog();
  }
  
  Future<void> _loadCallLog() async {
    setState(() => _isLoading = true);
    try {
      _callLog = await widget.platformService.getCallLog(limit: 100);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Combine call log with scam history
    final callEvents = widget.appState.scamHistory
        .where((e) => e.channel == 'call')
        .toList();
    
    if (_isLoading && _callLog.isEmpty && callEvents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_callLog.isEmpty && callEvents.isEmpty) {
      return _EmptyState(
        icon: Icons.call_outlined,
        title: 'No Call History',
        subtitle: 'Your call history will appear here',
        actionLabel: 'Refresh',
        onAction: _loadCallLog,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadCallLog,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: callEvents.length + (_callLog.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0 && _callLog.isNotEmpty) {
            return _CallLogSection(
              title: 'Recent Calls',
              callLog: _callLog,
              onAnalyze: widget.platformService.analyzeCall,
            );
          }
          
          final eventIndex = _callLog.isNotEmpty ? index - 1 : index;
          if (eventIndex < callEvents.length) {
            return _ScamCallTile(event: callEvents[eventIndex]);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CallLogSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> callLog;
  final Function(String, String) onAnalyze;
  
  const _CallLogSection({
    required this.title,
    required this.callLog,
    required this.onAnalyze,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: callLog.length,
          itemBuilder: (context, index) {
            final call = callLog[index];
            return _CallLogTile(call: call, onAnalyze: onAnalyze);
          },
        ),
        const Divider(height: AppSpacing.xl),
      ],
    );
  }
}

class _CallLogTile extends StatelessWidget {
  final Map<String, dynamic> call;
  final Function(String, String) onAnalyze;
  
  const _CallLogTile({
    required this.call,
    required this.onAnalyze,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = call['number'] as String? ?? 'Unknown';
    final name = call['name'] as String? ?? 'Unknown';
    final type = call['type'] as int? ?? 0;
    final timestamp = call['timestamp'] as int? ?? 0;
    final duration = call['duration'] as int? ?? 0;
    
    IconData typeIcon;
    Color typeColor;
    switch (type) {
      case 1: // Incoming
        typeIcon = Icons.call_received;
        typeColor = Colors.green;
        break;
      case 2: // Outgoing
        typeIcon = Icons.call_made;
        typeColor = Colors.blue;
        break;
      case 3: // Missed
        typeIcon = Icons.call_missed;
        typeColor = Colors.red;
        break;
      default:
        typeIcon = Icons.call;
        typeColor = theme.colorScheme.onSurfaceVariant;
    }
    
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final dateStr = '${date.day}/${date.month}/${date.year}';
    
    String durationStr = '';
    if (duration > 0) {
      final mins = duration ~/ 60;
      final secs = duration % 60;
      durationStr = '${mins}m ${secs}s';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.15),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          name == 'Unknown' ? number : name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != 'Unknown') Text(number, style: theme.textTheme.bodyMedium),
            Text(
              '$dateStr at $timeStr${durationStr.isNotEmpty ? ' • $durationStr' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
          onSelected: (value) {
            if (value == 'analyze') onAnalyze(number, name);
            if (value == 'block') _showBlockDialog(context, number);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'analyze', child: Text('Analyze for Scam')),
            const PopupMenuItem(value: 'block', child: Text('Block Number')),
          ],
        ),
        onTap: () => onAnalyze(number, name),
      ),
    );
  }
  
  void _showBlockDialog(BuildContext context, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Number'),
        content: Text('Block $number? You will no longer receive calls from this number.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Block number logic
            },
            child: const Text('BLOCK'),
          ),
        ],
      ),
    );
  }
}

class _ScamCallTile extends StatelessWidget {
  final ScamEvent event;
  
  const _ScamCallTile({required this.event});
  
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: riskColor.withOpacity(0.15),
          child: Icon(riskIcon, color: riskColor),
        ),
        title: Text(
          event.sender,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dateStr at $timeStr', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                  ),
                  child: Text(
                    risk.level.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${risk.score}/100',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        onTap: () => _showDetails(context),
      ),
    );
  }
  
  void _showDetails(BuildContext context) {
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
        
        // Caller info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Caller Information', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Number', value: event.sender),
                _InfoRow(label: 'Channel', value: event.channel.toUpperCase()),
                _InfoRow(label: 'Time', value: '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} at ${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}'),
                if (event.verification?.organization.isNotEmpty ?? false)
                  _InfoRow(
                    label: 'Verification', 
                    value: event.verification!.organization,
                    valueStyle: TextStyle(
                      color: event.verification!.status == 'VERIFIED_OFFICIAL' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Risk explanations
        if (risk.explanations?.isNotEmpty ?? false) ...[
          Text('Why we warned you:', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (risk.explanations ?? []).map((e) => Padding(
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
          const SizedBox(height: AppSpacing.md),
        ],
        
        // Campaign info
        if (event.campaign.campaignId.isNotEmpty) ...[
          Text('Campaign Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Campaign ID', value: event.campaign.campaignId),
                  _InfoRow(label: 'Events in Campaign', value: '${event.campaign.eventCount}'),
                  _InfoRow(label: 'Channels', value: (event.campaign.channels ?? []).join(', ')),
                  _InfoRow(
                    label: 'Exposure', 
                    value: event.campaign.exposure?.description ?? '',
                    valueStyle: TextStyle(
                      color: (event.campaign.exposure?.moneyInr ?? 0) > 0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
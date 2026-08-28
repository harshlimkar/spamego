// Protection screen - Risk history + campaigns + exposure
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../models/campaign.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/campaign_card.dart';

class ProtectionScreen extends StatelessWidget {
  const ProtectionScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Protection'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.campaign_outlined), text: 'Campaigns'),
                  Tab(icon: Icon(Icons.history_outlined), text: 'History'),
                  Tab(icon: Icon(Icons.timeline_outlined), text: 'Timeline'),
                ],
                isScrollable: true,
              ),
            ),
            body: TabBarView(
              children: [
                // Campaigns Tab
                _CampaignsTab(appState: appState),
                // History Tab
                _HistoryTab(appState: appState),
                // Timeline Tab
                _TimelineTab(appState: appState),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CampaignsTab extends StatelessWidget {
  final AppState appState;
  
  const _CampaignsTab({required this.appState});
  
  @override
  Widget build(BuildContext context) {
    final campaigns = appState.campaigns..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    if (campaigns.isEmpty) {
      return _EmptyState(
        icon: Icons.campaign_outlined,
        title: 'No Campaigns Detected',
        subtitle: 'Scam campaigns will appear here when detected',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: campaigns.length,
      itemBuilder: (context, index) => CampaignCard(
        campaign: campaigns[index],
        onTap: () => _showCampaignDetails(context, campaigns[index]),
      ),
    );
  }
  
  void _showCampaignDetails(BuildContext context, Campaign campaign) {
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
            child: _CampaignDetail(campaign: campaign),
          ),
        ),
      ),
    );
  }
}

class _CampaignDetail extends StatelessWidget {
  final Campaign campaign;
  
  const _CampaignDetail({required this.campaign});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = RiskColors.forLevel(campaign.riskLevel, context);
    final riskBgColor = RiskColors.backgroundForLevel(campaign.riskLevel, context);
    
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
            Icon(RiskColors.iconForLevel(campaign.riskLevel), color: riskColor, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Campaign ${campaign.id}', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(AppSpacing.xl),
                    ),
                    child: Text(
                      '${campaign.riskLevel.toUpperCase()} • ${campaign.riskScore}/100',
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
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
                Text('Campaign Overview', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Campaign ID', value: campaign.id),
                _InfoRow(label: 'Events', value: '${campaign.eventCount}'),
                _InfoRow(label: 'Channels', value: campaign.channels.join(', ')),
                _InfoRow(label: 'Categories', value: campaign.categories.join(', ')),
                if (campaign.velocitySeconds != null)
                  _InfoRow(label: 'Progression Velocity', value: '${campaign.velocitySeconds!.toStringAsFixed(0)} seconds'),
                _InfoRow(
                  label: 'Exposure', 
                  value: campaign.exposure.description,
                  valueStyle: TextStyle(
                    color: campaign.exposure.moneyInr > 0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Stage Progression', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ...campaign.stageHistory.map((stage) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _stageColor(stage['stage'] as String).withOpacity(0.15),
              child: Icon(_stageIcon(stage['stage'] as String), color: _stageColor(stage['stage'] as String)),
            ),
            title: Text(_stageLabel(stage['stage'] as String)),
            subtitle: Text(stage['detected_at'] as String? ?? ''),
            trailing: Text('${(stage['confidence'] as double? ?? 1.0) * 100}%'),
          ),
        )),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Events in Campaign', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        ...campaign.categories.map((cat) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(cat[0].toUpperCase()),
            ),
            title: Text(cat.replaceAll('_', ' ').toUpperCase()),
            subtitle: Text('Detected in campaign'),
          ),
        )),
      ],
    );
  }
  
  Color _stageColor(String stage) {
    switch (stage) {
      case 'credential_harvesting':
      case 'exploitation':
      case 'objective_completion':
        return Colors.red;
      case 'urgency':
      case 'isolation':
        return Colors.orange;
      case 'pretexting':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
  
  IconData _stageIcon(String stage) {
    switch (stage) {
      case 'credential_harvesting':
        return Icons.key_off;
      case 'exploitation':
        return Icons.money_off;
      case 'objective_completion':
        return Icons.check_circle;
      case 'urgency':
        return Icons.timer;
      case 'isolation':
        return Icons.lock;
      case 'pretexting':
        return Icons.person;
      default:
        return Icons.help;
    }
  }
  
  String _stageLabel(String stage) {
    return stage.replaceAll('_', ' ').toUpperCase();
  }
}

class _HistoryTab extends StatelessWidget {
  final AppState appState;
  
  const _HistoryTab({required this.appState});
  
  @override
  Widget build(BuildContext context) {
    final events = appState.scamHistory..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.history_outlined,
        title: 'No History',
        subtitle: 'Scam detection history will appear here',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: events.length,
      itemBuilder: (context, index) => _HistoryTile(event: events[index]),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScamEvent event;
  
  const _HistoryTile({required this.event});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = event.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);
    
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
          child: Icon(
            event.channel == 'call' ? Icons.call : Icons.message,
            color: riskColor,
          ),
        ),
        title: Text(
          event.sender,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$dateStr at $timeStr', style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    risk.level.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${risk.score}/100', style: theme.textTheme.bodySmall?.copyWith(color: riskColor, fontWeight: FontWeight.w600)),
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

class _TimelineTab extends StatelessWidget {
  final AppState appState;
  
  const _TimelineTab({required this.appState});
  
  @override
  Widget build(BuildContext context) {
    final events = appState.scamHistory..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final campaigns = appState.campaigns..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    if (events.isEmpty && campaigns.isEmpty) {
      return _EmptyState(
        icon: Icons.timeline_outlined,
        title: 'No Timeline Data',
        subtitle: 'Timeline will show scam progression over time',
      );
    }
    
    // Merge events and campaigns into a single timeline
    final timelineItems = <TimelineItem>[];
    
    for (final event in events) {
      timelineItems.add(TimelineItem(
        timestamp: event.timestamp,
        type: 'event',
        title: '${event.channel.toUpperCase()}: ${event.headline}',
        subtitle: '${event.sender} • ${event.risk.level.toUpperCase()} (${event.risk.score}/100)',
        riskColor: RiskColors.forLevel(event.risk.level, context),
        data: event,
      ));
    }
    
    for (final campaign in campaigns) {
      timelineItems.add(TimelineItem(
        timestamp: campaign.updatedAt,
        type: 'campaign',
        title: 'Campaign Update: ${campaign.id}',
        subtitle: '${campaign.eventCount} events • ${campaign.riskLevel.toUpperCase()} • ${campaign.exposure.description}',
        riskColor: RiskColors.forLevel(campaign.riskLevel, context),
        data: campaign,
      ));
    }
    
    timelineItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: timelineItems.length,
      itemBuilder: (context, index) => _TimelineTile(
        item: timelineItems[index],
        isFirst: index == 0,
        isLast: index == timelineItems.length - 1,
      ),
    );
  }
}

class TimelineItem {
  final DateTime timestamp;
  final String type;
  final String title;
  final String subtitle;
  final Color riskColor;
  final dynamic data;
  
  TimelineItem({
    required this.timestamp,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.riskColor,
    required this.data,
  });
}

class _TimelineTile extends StatelessWidget {
  final TimelineItem item;
  final bool isFirst;
  final bool isLast;
  
  const _TimelineTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = item.timestamp;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line
        Column(
          children: [
            if (!isFirst)
              Expanded(
                child: Container(
                  width: 2,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.riskColor,
                border: Border.all(color: theme.colorScheme.surface, width: 3),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            color: item.riskColor.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: item.riskColor.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.riskColor,
                          borderRadius: BorderRadius.circular(AppSpacing.xl),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$dateStr at $timeStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
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
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
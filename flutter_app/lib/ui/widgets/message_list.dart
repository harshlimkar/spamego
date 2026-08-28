// Message list widget
import 'package:flutter/material.dart';
import '../../models/scam_event.dart';
import '../../ui/theme/app_theme.dart';

class MessageList extends StatelessWidget {
  final List<ScamEvent> events;
  final String filter;
  
  const MessageList({
    super.key,
    required this.events,
    required this.filter,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (events.isEmpty) {
      return _EmptyState(
        icon: filter == 'flagged' ? Icons.flag_outlined : Icons.sms_outlined,
        title: filter == 'flagged' ? 'No Flagged Messages' : 'No SMS Scans Yet',
        subtitle: filter == 'flagged' 
            ? 'Suspicious messages will appear here'
            : 'Incoming SMS will be automatically scanned',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: events.length,
        itemBuilder: (context, index) => _MessageTile(event: events[index]),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final ScamEvent event;
  
  const _MessageTile({required this.event});
  
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
    
    // Truncate message for preview
    String preview = event.text;
    if (preview.length > 100) {
      preview = '${preview.substring(0, 100)}...';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: riskBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riskColor.withOpacity(0.3), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: riskColor.withOpacity(0.15),
                    child: Icon(riskIcon, color: riskColor, size: 20),
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
                                event.sender,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
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
                  const SizedBox(width: AppSpacing.md),
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
                          'Campaign: ${event.campaign.campaignId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                preview,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              if (risk.explanations?.isNotEmpty ?? false) ...[
                const Divider(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: (risk.explanations ?? []).take(2).map((e) => Chip(
                    label: Text(e, style: theme.textTheme.labelSmall),
                    backgroundColor: riskColor.withOpacity(0.1),
                    side: BorderSide(color: riskColor.withOpacity(0.3)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
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
        
        // Message content
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message Content', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                SelectableText(event.text, style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Sender', value: event.sender),
                _InfoRow(label: 'Language', value: event.language.toUpperCase()),
                _InfoRow(label: 'Time', value: '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} at ${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}'),
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
        
        // Links found
        if (event.linkFindings?.isNotEmpty ?? false) ...[
          Text('Links Found', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...event.linkFindings!.map((link) => Card(
            color: link.isSuspicious 
                ? Theme.of(context).colorScheme.errorContainer
                : (link.matchesTrusted ? Colors.green.withOpacity(0.1) : null),
            child: ListTile(
              leading: Icon(
                link.isSuspicious ? Icons.warning : (link.matchesTrusted ? Icons.verified : Icons.link),
                color: link.isSuspicious ? Theme.of(context).colorScheme.error : (link.matchesTrusted ? Colors.green : theme.colorScheme.primary),
              ),
              title: Text(link.domain, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(link.verdict.toUpperCase()),
              trailing: Text(link.verdict.toUpperCase()),
            ),
          )).toList(),
          const SizedBox(height: AppSpacing.md),
        ],
        
        // OTP finding
        if (event.otp != null && event.otp!.context != 'none') ...[
          Text('OTP Analysis', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: event.otp!.isRisky ? Theme.of(context).colorScheme.errorContainer : Colors.green.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        event.otp!.isRisky ? Icons.warning : Icons.check_circle,
                        color: event.otp!.isRisky ? Theme.of(context).colorScheme.error : Colors.green,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          event.otp!.label,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(event.otp!.reason, style: theme.textTheme.bodyMedium),
                  if (event.otp!.valuePresent) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '⚠️ OTP value detected in message',
                      style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
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
                      color: (event.campaign.exposure?.moneyInr ?? 0) > 0 ? Theme.of(context).colorScheme.error : theme.colorScheme.onSurface,
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
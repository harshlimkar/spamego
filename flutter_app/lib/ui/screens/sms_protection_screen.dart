// SMS Protection Screen — dedicated SMS analysis feature screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../services/platform_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_list.dart';
import '../widgets/test_message_widget.dart';
import '../widgets/risk_badge.dart';

class SmsProtectionScreen extends StatefulWidget {
  const SmsProtectionScreen({super.key});

  @override
  State<SmsProtectionScreen> createState() => _SmsProtectionScreenState();
}

class _SmsProtectionScreenState extends State<SmsProtectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, PlatformService>(
      builder: (context, appState, platform, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SMS Protection'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.settings_outlined), text: 'Status'),
                Tab(icon: Icon(Icons.sms_outlined), text: 'All SMS'),
                Tab(icon: Icon(Icons.flag_outlined), text: 'Flagged'),
                Tab(icon: Icon(Icons.science_outlined), text: 'Analyze'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _StatusTab(appState: appState, platform: platform),
              MessageList(
                events: appState.scamHistory.where((e) => e.channel == 'sms').toList(),
                filter: 'all',
              ),
              MessageList(
                events: appState.scamHistory
                    .where((e) => e.channel == 'sms' && e.risk.level != 'safe')
                    .toList(),
                filter: 'flagged',
              ),
              const TestMessageWidget(),
            ],
          ),
        );
      },
    );
  }
}

class _StatusTab extends StatelessWidget {
  final AppState appState;
  final PlatformService platform;

  const _StatusTab({required this.appState, required this.platform});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final smsList = appState.scamHistory.where((e) => e.channel == 'sms').toList();
    final flagged = smsList.where((e) => e.risk.level != 'safe').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Protection toggle
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: appState.isSmsProtectionEnabled
                ? Colors.green.shade50
                : theme.colorScheme.surfaceContainerHighest,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.all(16),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: appState.isSmsProtectionEnabled
                      ? Colors.green.shade100
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sms,
                  color: appState.isSmsProtectionEnabled ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
              title: Text(
                'SMS Protection',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                appState.isSmsProtectionEnabled
                    ? 'Scanning all incoming SMS for scams'
                    : 'SMS scanning is disabled',
                style: theme.textTheme.bodyMedium,
              ),
              value: appState.isSmsProtectionEnabled,
              onChanged: appState.setSmsProtectionEnabled,
            ),
          ),
          const SizedBox(height: 20),

          // How it works
          Text('How SMS Protection Works', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _PipelineStep(step: 1, icon: Icons.inbox, title: 'Incoming SMS', desc: 'Every SMS is intercepted when it arrives'),
          _PipelineStep(step: 2, icon: Icons.translate, title: 'Language Detection', desc: 'Detects English, Hindi, Tamil, and code-mixed'),
          _PipelineStep(step: 3, icon: Icons.rule, title: 'Rule Engine', desc: 'Local keyword and pattern matching (works offline)'),
          _PipelineStep(step: 4, icon: Icons.psychology, title: 'ML Classifier', desc: 'TF-IDF + Logistic Regression (97.5% accuracy)'),
          _PipelineStep(step: 5, icon: Icons.link, title: 'Link Check', desc: 'Extracts and verifies all URLs in the message'),
          _PipelineStep(step: 6, icon: Icons.warning, title: 'Risk Score', desc: 'Combines all signals into a 0–100 risk score'),
          _PipelineStep(step: 7, icon: Icons.campaign, title: 'Campaign Correlation', desc: 'Links related events into scam campaigns'),
          const SizedBox(height: 20),

          // Stats
          Text('Statistics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Total Scanned', value: '${smsList.length}', color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'Flagged', value: '${flagged.length}', color: flagged.isNotEmpty ? Colors.orange : Colors.green)),
            ],
          ),
          const SizedBox(height: 12),

          // Flagged summary
          if (flagged.isNotEmpty) ...[
            Text('Recently Flagged', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...flagged.take(3).map((e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.sms, color: RiskColors.forLevel(e.risk.level, context)),
                title: Text(e.sender),
                subtitle: Text(e.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: RiskBadge(level: e.risk.level),
              ),
            )),
          ],

          const SizedBox(height: 16),
          // Privacy note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.teal.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Privacy: SMS content is analyzed locally by default. Cloud analysis only sends derived signals, not your messages.',
                    style: TextStyle(color: Colors.teal.shade800, fontSize: 13),
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

class _PipelineStep extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String desc;

  const _PipelineStep({required this.step, required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(desc, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

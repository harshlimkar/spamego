// Calls screen - Dialer + caller protection + history
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../services/platform_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/dialer_widget.dart';
import '../../ui/widgets/call_history_list.dart';
class VerifiedContactsList extends StatelessWidget {
  const VerifiedContactsList({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Verified Contacts'));
}
class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, PlatformService>(
      builder: (context, appState, platformService, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calls'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dialpad), text: 'Dialer'),
                Tab(icon: Icon(Icons.history), text: 'History'),
                Tab(icon: Icon(Icons.verified), text: 'Verified'),
              ],
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Dialer Tab
              DialerWidget(
                onCall: (number) => platformService.makeCall(number),
                onAnalyze: (number) => platformService.analyzeCall(number, ''),
              ),
              // History Tab
              CallHistoryList(
                platformService: platformService,
                appState: appState,
              ),
              // Verified Contacts Tab
              const VerifiedContactsList(),
            ],
          ),
        );
      },
    );
  }
}

// Incoming call screen widget
class IncomingCallScreen extends StatelessWidget {
  final ScamEvent event;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onVerify;
  final VoidCallback onAskFamily;
  
  const IncomingCallScreen({
    super.key,
    required this.event,
    required this.onAccept,
    required this.onReject,
    required this.onVerify,
    required this.onAskFamily,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = event.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);
    final riskIcon = RiskColors.iconForLevel(risk.level);
    
    return Scaffold(
      backgroundColor: riskBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Risk indicator
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: riskColor.withOpacity(0.15),
                  border: Border.all(color: riskColor, width: 4),
                ),
                child: Icon(
                  riskIcon,
                  size: 64,
                  color: riskColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Risk level badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                ),
                child: Text(
                  risk.level.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Headline
              Text(
                event.headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Caller info
              Card(
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: riskColor.withOpacity(0.15),
                            child: Icon(
                              Icons.person,
                              size: 28,
                              color: riskColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.sender,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (event.verification?.organization.isNotEmpty ?? false) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Icon(
                                        event.verification!.status == 'VERIFIED_OFFICIAL'
                                            ? Icons.verified
                                            : Icons.warning_amber,
                                        size: 16,
                                        color: event.verification!.status == 'VERIFIED_OFFICIAL'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        event.verification!.organization,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: event.verification!.status == 'VERIFIED_OFFICIAL'
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Risk score
              Column(
                children: [
                  Text(
                    'Risk Score: ${risk.score}/100',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: risk.score / 100,
                    backgroundColor: riskColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(riskColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Explanation
              if (risk.explanations?.isNotEmpty ?? false) ...[
                Card(
                  color: riskColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: riskColor),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Why we warned you:',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...(risk.explanations ?? []).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: riskColor)),
                              Expanded(
                                child: Text(e, style: theme.textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              // Action buttons
              Column(
                children: [
                  // Primary action based on intervention
                  if (event.intervention.action == 'STOP')
                    FilledButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.call_end, size: 28),
                      label: const Text('END CALL', style: TextStyle(fontSize: 18)),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                  else if (event.intervention.action == 'CONFIRM')
                    OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.call_end, size: 28),
                      label: const Text('END CALL', style: TextStyle(fontSize: 18)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error, width: 2),
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Secondary actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onVerify,
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('VERIFY'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAccept,
                          icon: const Icon(Icons.call, size: 24),
                          label: const Text('ANSWER'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (event.intervention.buttons.contains('ASK FAMILY')) ...[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: onAskFamily,
                      icon: const Icon(Icons.family_restroom),
                      label: const Text('ASK FAMILY FOR HELP'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
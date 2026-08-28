import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scam_event.dart';
import '../../services/platform_service.dart';
import '../theme/app_theme.dart';

class ActiveCallScreen extends StatefulWidget {
  final ScamEvent initialEvent;
  final VoidCallback onEndCall;

  const ActiveCallScreen({
    super.key,
    required this.initialEvent,
    required this.onEndCall,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  late ScamEvent _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.initialEvent;
    
    // Listen for live updates from STT / ML pipeline
    final platform = Provider.of<PlatformService>(context, listen: false);
    final previousCallback = platform.onCallReceived;
    
    platform.onCallReceived = (event) {
      if (mounted) {
        setState(() {
          _currentEvent = event;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = _currentEvent.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);

    return Scaffold(
      backgroundColor: riskBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(), // No back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Caller Info
              Text(
                'Active Call',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _currentEvent.sender,
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Live Risk Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: riskColor, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RiskColors.iconForLevel(risk.level), color: riskColor),
                    const SizedBox(width: 12),
                    Text(
                      risk.level.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Live Transcript Area
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.transcribe, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Live Transcript',
                              style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Text(
                              _currentEvent.text.isEmpty ? 'Listening...' : _currentEvent.text,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Risk Explanations (if any)
              if (risk.explanations?.isNotEmpty ?? false)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: (risk.explanations ?? []).take(2).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, size: 16, color: riskColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e, style: theme.textTheme.bodySmall),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                
              const SizedBox(height: AppSpacing.xl),
              
              // End Call Button
              FloatingActionButton(
                onPressed: widget.onEndCall,
                backgroundColor: Colors.red,
                child: const Icon(Icons.call_end, color: Colors.white, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

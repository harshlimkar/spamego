// Kill-chain stepper widget — shows scam progression stages
import 'package:flutter/material.dart';

class KillChainStepper extends StatelessWidget {
  final String? currentStage;
  final bool compact;

  const KillChainStepper({
    super.key,
    this.currentStage,
    this.compact = false,
  });

  static const List<_StageInfo> _stages = [
    _StageInfo('delivery', 'Delivery', Icons.mail_outline, Colors.blue),
    _StageInfo('pretexting', 'Pretexting', Icons.person_outline, Colors.indigo),
    _StageInfo('urgency', 'Urgency', Icons.timer_outlined, Colors.orange),
    _StageInfo('isolation', 'Isolation', Icons.lock_outline, Colors.deepOrange),
    _StageInfo('credential_harvesting', 'Credential\nHarvest', Icons.key_off_outlined, Colors.red),
    _StageInfo('exploitation', 'Exploitation', Icons.money_off_outlined, Colors.red),
    _StageInfo('objective_completion', 'Complete', Icons.dangerous_outlined, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIdx = _stages.indexWhere((s) => s.key == currentStage);

    if (compact) {
      return _CompactChain(stages: _stages, currentIdx: currentIdx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: _stages.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            final isActive = currentIdx >= 0 && i <= currentIdx;

            return Expanded(
              child: Column(
                children: [
                  // Line before
                  if (i > 0)
                    Container(
                      height: 3,
                      color: isActive ? stage.color : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _stages.asMap().entries.map((entry) {
              final i = entry.key;
              final stage = entry.value;
              final isActive = currentIdx >= 0 && i <= currentIdx;
              final isCurrent = i == currentIdx;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive
                            ? stage.color.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? stage.color : theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: isCurrent ? 3 : 1.5,
                        ),
                        boxShadow: isCurrent ? [
                          BoxShadow(
                            color: stage.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        stage.icon,
                        size: 22,
                        color: isActive ? stage.color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 56,
                      child: Text(
                        stage.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? stage.color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CompactChain extends StatelessWidget {
  final List<_StageInfo> stages;
  final int currentIdx;

  const _CompactChain({required this.stages, required this.currentIdx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: stages.asMap().entries.map((entry) {
        final i = entry.key;
        final stage = entry.value;
        final isActive = currentIdx >= 0 && i <= currentIdx;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isActive ? stage.color : theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StageInfo {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _StageInfo(this.key, this.label, this.icon, this.color);
}

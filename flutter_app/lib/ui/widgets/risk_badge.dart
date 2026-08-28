// Reusable risk badge widget for ScameGo
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String level;
  final int? score;
  final bool large;

  const RiskBadge({
    super.key,
    required this.level,
    this.score,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = RiskColors.forLevel(level, context);
    final icon = RiskColors.iconForLevel(level);
    final label = _label();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(large ? 12 : 20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: large ? 20 : 14),
          const SizedBox(width: 4),
          Text(
            score != null ? '$label  $score/100' : label,
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 16 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
    switch (level.toLowerCase()) {
      case 'safe': return '✓ SAFE';
      case 'low': return 'LOW';
      case 'medium': return '⚠ MEDIUM';
      case 'high': return '⚠ HIGH';
      case 'critical': return '🚨 CRITICAL';
      default: return level.toUpperCase();
    }
  }
}

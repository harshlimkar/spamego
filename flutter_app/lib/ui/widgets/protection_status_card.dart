// Protection status card for home screen
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../theme/app_theme.dart';

class ProtectionStatusCard extends StatelessWidget {
  final AppState appState;

  const ProtectionStatusCard({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = appState.protectionStatus;

    Color bgColor;
    Color fgColor;
    Color borderColor;
    IconData shieldIcon;
    String statusTitle;
    String statusMessage;

    switch (status) {
      case 'protected':
        bgColor = const Color(0xFF1B5E20);
        fgColor = Colors.white;
        borderColor = const Color(0xFF4CAF50);
        shieldIcon = Icons.shield;
        statusTitle = 'PROTECTION ACTIVE';
        statusMessage = 'Your phone is being monitored for scam activity';
        break;
      case 'warning':
        bgColor = const Color(0xFFE65100);
        fgColor = Colors.white;
        borderColor = const Color(0xFFFF9800);
        shieldIcon = Icons.shield_outlined;
        statusTitle = 'SCAMS DETECTED TODAY';
        statusMessage = '${appState.scamsDetected} suspicious event${appState.scamsDetected == 1 ? '' : 's'} found';
        break;
      case 'disabled':
        bgColor = theme.colorScheme.surfaceContainerHighest;
        fgColor = theme.colorScheme.onSurfaceVariant;
        borderColor = theme.colorScheme.outline;
        shieldIcon = Icons.shield_outlined;
        statusTitle = 'PROTECTION OFF';
        statusMessage = 'Tap Settings to enable scam protection';
        break;
      default:
        bgColor = const Color(0xFF1B5E20);
        fgColor = Colors.white;
        borderColor = const Color(0xFF4CAF50);
        shieldIcon = Icons.shield;
        statusTitle = 'PROTECTION ACTIVE';
        statusMessage = 'Your phone is being monitored for scam activity';
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Animated shield
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(shieldIcon, size: 44, color: fgColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusMessage,
                    style: TextStyle(
                      color: fgColor.withValues(alpha: 0.85),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  if (status == 'warning') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TAP ALERTS TAB TO REVIEW',
                        style: TextStyle(
                          color: fgColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exposure breakdown card — shows what's at risk (financial, credentials, OTP, device)
import 'package:flutter/material.dart';
import '../../models/scam_event.dart';

class ExposureBreakdownCard extends StatelessWidget {
  final Exposure exposure;

  const ExposureBreakdownCard({super.key, required this.exposure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _hasRisk()
              ? Colors.red.shade300.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Exposure Breakdown', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            _ExposureRow(
              icon: Icons.account_balance_wallet,
              label: 'Financial',
              value: exposure.moneyInr > 0 ? '₹${exposure.moneyInr.toStringAsFixed(0)}' : '₹0',
              riskLevel: exposure.moneyInr > 0 ? 'high' : 'safe',
            ),
            _ExposureRow(
              icon: Icons.key,
              label: 'Credentials',
              value: _riskLabel(exposure.credentialRisk),
              riskLevel: exposure.credentialRisk == 'high' ? 'high'
                  : exposure.credentialRisk == 'medium' ? 'medium'
                  : 'safe',
            ),
            _ExposureRow(
              icon: Icons.password,
              label: 'OTP Requested',
              value: exposure.otpRequested ? 'YES — at risk' : 'No',
              riskLevel: exposure.otpRequested ? 'high' : 'safe',
            ),
            _ExposureRow(
              icon: Icons.phone_android,
              label: 'Device Access',
              value: exposure.deviceAccessRequested ? 'REQUESTED' : 'Safe',
              riskLevel: exposure.deviceAccessRequested ? 'critical' : 'safe',
            ),
            _ExposureRow(
              icon: Icons.account_circle,
              label: 'Account Access',
              value: exposure.accountAccessPossible ? 'POSSIBLE' : 'Safe',
              riskLevel: exposure.accountAccessPossible ? 'high' : 'safe',
            ),
          ],
        ),
      ),
    );
  }

  bool _hasRisk() =>
      exposure.moneyInr > 0 ||
      exposure.credentialRisk != 'none' ||
      exposure.otpRequested ||
      exposure.deviceAccessRequested;

  String _riskLabel(String risk) {
    switch (risk.toLowerCase()) {
      case 'high': return 'HIGH';
      case 'medium': return 'MEDIUM';
      case 'low': return 'LOW';
      default: return 'None';
    }
  }
}

class _ExposureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String riskLevel;

  const _ExposureRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color valueColor;
    switch (riskLevel) {
      case 'critical': valueColor = Colors.red.shade800; break;
      case 'high': valueColor = Colors.red.shade600; break;
      case 'medium': valueColor = Colors.orange.shade700; break;
      case 'low': valueColor = Colors.amber.shade700; break;
      default: valueColor = Colors.green.shade700;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../services/payment_risk_engine.dart';
import '../../ui/theme/app_theme.dart';
import '../../services/risk_engine.dart'; // For RiskResult if needed

class PaymentRiskScreen extends StatefulWidget {
  const PaymentRiskScreen({super.key});

  @override
  State<PaymentRiskScreen> createState() => _PaymentRiskScreenState();
}

class _PaymentRiskScreenState extends State<PaymentRiskScreen> {
  final _amountController = TextEditingController(text: '5000');
  final _receiverController = TextEditingController(text: 'scammer@upi');
  
  PaymentRiskResult? _lastResult;

  @override
  void dispose() {
    _amountController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  void _injectMockScamEvent(AppState appState) {
    // Inject a critical mock event to simulate a recent scam attempt
    final mockEvent = ScamEvent(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      channel: 'sms',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)), // 2 minutes ago
      sender: 'KOTAK-BANK',
      text: 'Dear customer, your account will be blocked. Click here or pay 5000 to unblock. OTP: 123456',
      normalized: 'dear customer your account will be blocked click here or pay 5000 to unblock otp 123456',
      language: 'en',
      verdict: 'CRITICAL',
      headline: 'Payment Request Risk',
      risk: const RiskResult(score: 95, level: 'critical'),
      campaign: CampaignInfo(
        campaignId: 'CAMP-MOCK-001',
        riskScore: 95,
        riskLevel: 'critical',
      ),
      intervention: const Intervention(action: 'STOP', title: 'Critical Scam', message: 'Do not proceed'),
      familyAlert: const FamilyAlertDecision(alertSent: false),
    );
    appState.addScamEvent(mockEvent);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock High-Risk Scam Event Injected (2 mins ago)!')),
    );
  }

  void _simulatePayment(AppState appState) {
    final amountText = _amountController.text.trim();
    final receiverText = _receiverController.text.trim();
    
    final amount = double.tryParse(amountText) ?? 0.0;
    
    // Evaluate using the PaymentRiskEngine
    final result = PaymentRiskEngine.evaluatePayment(
      amount: amount,
      receiver: receiverText,
      timestamp: DateTime.now(),
      recentEvents: appState.scamHistory,
    );
    
    setState(() {
      _lastResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Risk Prototype'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Simulate a payment to see how the local engine connects it with recent scam context (like a prior fraudulent SMS or Call).',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Context Control
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Context Setup', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Inject a recent high-risk message into the local history so the engine can spot the correlation.', style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: () => _injectMockScamEvent(appState),
                      icon: const Icon(Icons.warning_amber),
                      label: const Text('Inject High-Risk SMS Context'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Payment Form
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. Payment Details', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (INR)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _receiverController,
                      decoration: const InputDecoration(
                        labelText: 'Receiver / UPI ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _simulatePayment(appState),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Simulate Payment Intent', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Results Display
            if (_lastResult != null)
              _buildResultCard(_lastResult!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(PaymentRiskResult result, ThemeData theme) {
    Color riskColor;
    IconData riskIcon;
    
    switch (result.level) {
      case 'critical':
        riskColor = Colors.red;
        riskIcon = Icons.cancel;
        break;
      case 'warning':
        riskColor = Colors.orange;
        riskIcon = Icons.warning;
        break;
      default:
        riskColor = Colors.green;
        riskIcon = Icons.check_circle;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riskColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(riskIcon, color: riskColor, size: 32),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Payment Risk: ${result.level.toUpperCase()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildResultRow('Intervention Level:', result.intervention, theme, color: riskColor, isBold: true),
            const SizedBox(height: AppSpacing.sm),
            _buildResultRow('Exposure:', '₹${result.exposure.toStringAsFixed(2)}', theme),
            const SizedBox(height: AppSpacing.sm),
            _buildResultRow('Receiver:', _receiverController.text, theme),
            const SizedBox(height: AppSpacing.md),
            Text('Reasoning:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(result.reason, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, ThemeData theme, {Color? color, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

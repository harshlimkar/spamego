// Dialer widget for outgoing calls
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../services/platform_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../services/risk_engine.dart';

class DialerWidget extends StatefulWidget {
  final Function(String) onCall;
  final Function(String) onAnalyze;
  
  const DialerWidget({
    super.key,
    required this.onCall,
    required this.onAnalyze,
  });
  
  @override
  State<DialerWidget> createState() => _DialerWidgetState();
}

class _DialerWidgetState extends State<DialerWidget> {
  final TextEditingController _numberController = TextEditingController();
  ScamEvent? _analysisResult;
  bool _isAnalyzing = false;
  
  static const List<List<String>> _keypad = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['*', '0', '#'],
  ];
  
  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
  
  void _addDigit(String digit) {
    setState(() {
      _numberController.text += digit;
      _analysisResult = null;
    });
  }
  
  void _deleteDigit() {
    setState(() {
      if (_numberController.text.isNotEmpty) {
        _numberController.text = _numberController.text.substring(0, _numberController.text.length - 1);
        _analysisResult = null;
      }
    });
  }
  
  void _clearNumber() {
    setState(() {
      _numberController.clear();
      _analysisResult = null;
    });
  }
  
  Future<void> _analyzeNumber() async {
    final number = _numberController.text.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.isEmpty) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      await widget.onAnalyze(number);
      // The analysis result will come via the platform service stream
      // For now, we'll do a quick local analysis
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }
  
  void _makeCall() {
    final number = _numberController.text.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.isEmpty) return;
    
    // Show warning if high risk
    if (_analysisResult?.risk.level == 'high' || _analysisResult?.risk.level == 'critical') {
      _showCallWarning(number);
    } else {
      widget.onCall(number);
    }
  }
  
  void _showCallWarning(String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('⚠️ High Risk Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This number has been flagged as high risk.'),
            const SizedBox(height: AppSpacing.md),
            if (_analysisResult != null) ...[
              Text('Risk: ${_analysisResult!.risk.level.toUpperCase()} (${_analysisResult!.risk.score}/100)'),
              const SizedBox(height: AppSpacing.sm),
              ...(_analysisResult!.risk.explanations ?? []).take(2).map((e) => Text('• $e')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCall(number);
            },
            child: const Text('CALL ANYWAY'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Number display with analysis
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _numberController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter number',
                      hintStyle: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        letterSpacing: 4,
                      ),
                      suffixIcon: _numberController.text.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.report, color: Colors.red),
                                  tooltip: 'Report Spam',
                                  onPressed: () {
                                    final number = _numberController.text.replaceAll(RegExp(r'[^\d+]'), '');
                                    if (number.isNotEmpty) {
                                      Provider.of<AppState>(context, listen: false).reportSpamNumber(number);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Number marked as spam temporarily')),
                                      );
                                      _clearNumber();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearNumber,
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  
                  // Analysis result
                  if (_analysisResult != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _AnalysisBanner(result: _analysisResult!),
                  ] else if (_isAnalyzing) ...[
                    const Divider(height: AppSpacing.lg),
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Text('Analyzing...'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Keypad
          Expanded(
            child: Column(
              children: [
                ..._keypad.map((row) => Expanded(
                  child: Row(
                    children: row.map((digit) => Expanded(
                      child: _KeypadButton(
                        label: digit,
                        onTap: () => _addDigit(digit),
                      ),
                    )).toList(),
                  ),
                )),
                // Action row
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: _KeypadButton(
                          label: '⌫',
                          onTap: _deleteDigit,
                          icon: Icons.backspace,
                          isAction: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _numberController.text.isNotEmpty ? _makeCall : null,
                          icon: const Icon(Icons.call, size: 28),
                          label: const Text('CALL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _KeypadButton(
                          label: '✓',
                          onTap: _analyzeNumber,
                          icon: Icons.verified,
                          isAction: true,
                          enabled: _numberController.text.isNotEmpty && !_isAnalyzing,
                        ),
                      ),
                    ],
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

class _AnalysisBanner extends StatelessWidget {
  final ScamEvent result;
  
  const _AnalysisBanner({required this.result});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = result.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: riskBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(RiskColors.iconForLevel(risk.level), color: riskColor, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  result.verdict,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                ),
                child: Text(
                  '${risk.score}/100',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            result.headline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (result.risk.explanations?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.sm),
            ...(result.risk.explanations ?? []).take(2).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: riskColor)),
                  Expanded(child: Text(e, style: theme.textTheme.bodySmall)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isAction;
  final bool enabled;
  
  const _KeypadButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isAction = false,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAction 
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isAction 
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: enabled ? color : color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, size: 28, color: textColor)
                : Text(
                    label,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: textColor,
                      fontWeight: isAction ? FontWeight.w500 : FontWeight.w300,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
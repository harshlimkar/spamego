// Test a Message widget - manual text analysis for testing
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/scam_event.dart';
import '../../services/platform_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../services/risk_engine.dart';

class TestMessageWidget extends StatefulWidget {
  const TestMessageWidget({super.key});
  
  @override
  State<TestMessageWidget> createState() => _TestMessageWidgetState();
}

class _TestMessageWidgetState extends State<TestMessageWidget> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  String _selectedChannel = 'sms';
  ScamEvent? _result;
  bool _isAnalyzing = false;
  
  static const List<Map<String, String>> _channels = [
    {'value': 'sms', 'label': 'SMS', 'icon': '📱'},
    {'value': 'call', 'label': 'Call', 'icon': '📞'},
    {'value': 'social', 'label': 'Social Media', 'icon': '💬'},
    {'value': 'payment', 'label': 'Payment', 'icon': '💳'},
    {'value': 'email', 'label': 'Email', 'icon': '📧'},
  ];
  
  @override
  void dispose() {
    _textController.dispose();
    _senderController.dispose();
    super.dispose();
  }
  
  Future<void> _analyze() async {
    if (_textController.text.trim().isEmpty) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      final platformService = context.read<PlatformService>();
      final event = await platformService.analyzeWithBackend(
        channel: _selectedChannel,
        sender: _senderController.text.trim(),
        text: _textController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _result = event;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final localResult = RiskEngine.analyzeLocal(
          channel: _selectedChannel,
          sender: _senderController.text.trim(),
          text: _textController.text.trim(),
        );
        setState(() {
          _result = localResult;
          _isAnalyzing = false;
        });
      }
    }
  }
  
  void _loadExample(String example) {
    final examples = {
      'bank_kyc': {
        'sender': '+919876543210',
        'text': 'SIR YOUR KYC HAS EXPIRED. UPDATE IMMEDIATELY OR ACCOUNT WILL BE BLOCKED TODAY. CLICK http://sbi-kyc-secure-login.xyz TO VERIFY',
      },
      'otp_theft': {
        'sender': '+919999999999',
        'text': 'Your account will be blocked. Tell me the OTP you just received immediately.',
      },
      'tamil_mixed': {
        'sender': '+918800000001',
        'text': 'Sir unga KYC expire aagiduchu, immediately OTP sollunga link click pannunga',
      },
      'legit_otp': {
        'sender': 'AD-SBIPL',
        'text': 'Your A/C XXXXX is credited Rs. 5000. OTP 482918 for transaction. Do not share.',
      },
      'prize_scam': {
        'sender': '+918800000002',
        'text': 'Congratulations! You won ₹10,00,000 in Jio Lucky Draw. Click http://jio-prize-claim.xyz to claim now!',
      },
      'investment_scam': {
        'sender': '+917777777777',
        'text': 'Double your money in 30 days! Guaranteed returns on crypto investment. WhatsApp +919876543210',
      },
      'remote_access': {
        'sender': '+916666666666',
        'text': 'Your computer has a virus. Install AnyDesk immediately so we can fix it. Download from anydesk.com',
      },
    };
    
    if (examples.containsKey(example)) {
      _senderController.text = examples[example]!['sender']!;
      _textController.text = examples[example]!['text']!;
      _analyze();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test a Message',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Paste any suspicious message to analyze it with our scam detection engine.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Channel selector
          Text('Channel', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: _channels.map((ch) => ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${ch['icon']} '),
                  Text(ch['label']!),
                ],
              ),
              selected: _selectedChannel == ch['value'],
              onSelected: (selected) {
                if (selected) setState(() => _selectedChannel = ch['value']!);
              },
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Sender field
          TextField(
            controller: _senderController,
            decoration: const InputDecoration(
              labelText: 'Sender (Phone Number / Name)',
              hintText: '+919876543210 or AD-SBIPL',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Message field
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Message Text',
              hintText: 'Paste the suspicious message here...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Example buttons
          Text('Quick Examples', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ExampleChip(label: 'Bank KYC Scam', onTap: () => _loadExample('bank_kyc')),
              _ExampleChip(label: 'OTP Theft', onTap: () => _loadExample('otp_theft')),
              _ExampleChip(label: 'Tamil Mixed', onTap: () => _loadExample('tamil_mixed')),
              _ExampleChip(label: 'Legit OTP', onTap: () => _loadExample('legit_otp')),
              _ExampleChip(label: 'Prize Scam', onTap: () => _loadExample('prize_scam')),
              _ExampleChip(label: 'Investment', onTap: () => _loadExample('investment_scam')),
              _ExampleChip(label: 'Remote Access', onTap: () => _loadExample('remote_access')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Analyze button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAnalyzing ? null : _analyze,
              icon: _isAnalyzing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.psychology, size: 28),
              label: Text(_isAnalyzing ? 'ANALYZING...' : 'ANALYZE MESSAGE', style: const TextStyle(fontSize: 18)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Results
          if (_result != null) _ResultsPanel(result: _result!),
        ],
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _ExampleChip({required this.label, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.lightbulb_outline, size: 18),
    );
  }
}

// _ResultsPanel widget - displays analysis results
class _ResultsPanel extends StatelessWidget {
  final ScamEvent result;
  
  const _ResultsPanel({required this.result});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = result.risk;
    final riskColor = RiskColors.forLevel(risk.level, context);
    final riskBgColor = RiskColors.backgroundForLevel(risk.level, context);
    final riskIcon = RiskColors.iconForLevel(risk.level);
    
    // Build children list dynamically
    final children = <Widget>[
      const Divider(thickness: 2),
      const SizedBox(height: AppSpacing.lg),
      Text('Analysis Results', style: theme.textTheme.headlineSmall),
      const SizedBox(height: AppSpacing.lg),
      
      // Verdict card
      Card(
        color: riskBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: riskColor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(riskIcon, color: riskColor, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.verdict,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      result.headline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                ),
                child: Text(
                  '${risk.score}/100',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      LinearProgressIndicator(
        value: risk.score / 100,
        backgroundColor: riskColor.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation(riskColor),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Confidence: ${(risk.confidence * 100).toStringAsFixed(0)}%',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      
      // Explanations
      if (risk.explanations?.isNotEmpty ?? false) ...[
        const SizedBox(height: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why this verdict:', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: risk.explanations!.map((e) => Padding(
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
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ],
      
      // Details sections
      _DetailSection(title: 'Detected Intent', children: _buildIntentChildren(result)),
      _DetailSection(title: 'Kill-Chain Stage', children: _buildStageChildren(result)),
      _DetailSection(title: 'OTP Analysis', children: _buildOtpChildren(result)),
      _DetailSection(title: 'Links Found', children: _buildLinkChildren(result)),
      _DetailSection(title: 'Campaign', children: _buildCampaignChildren(result)),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
  
  List<Widget> _buildIntentChildren(ScamEvent result) {
    if (result.intents?.isNotEmpty ?? false) {
      return result.intents!.map((i) => _DetailRow(
        label: i.name.replaceAll('_', ' ').toUpperCase(),
        value: i.label,
        badge: '${(i.confidence * 100).toStringAsFixed(0)}%',
      )).toList();
    } else {
      return [_DetailRow(label: 'Unknown', value: 'Could not determine intent')];
    }
  }
  
  List<Widget> _buildStageChildren(ScamEvent result) {
    if (result.stage != null) {
      return [_DetailRow(
        label: result.stage!.stage.toUpperCase(),
        value: result.stage!.label,
        badge: '${(result.stage!.confidence * 100).toStringAsFixed(0)}%',
      )];
    } else {
      return [_DetailRow(label: 'Benign', value: 'No scam progression detected')];
    }
  }
  
  List<Widget> _buildOtpChildren(ScamEvent result) {
    if (result.otp != null && result.otp!.context != 'none') {
      return [
        _DetailRow(
          label: result.otp!.context.toUpperCase(),
          value: result.otp!.label,
          badge: result.otp!.isRisky ? '⚠️ RISKY' : 'SAFE',
        ),
        if (result.otp!.reason.isNotEmpty) _DetailRow(label: 'Details', value: result.otp!.reason),
        if (result.otp!.valuePresent) _DetailRow(label: 'OTP Value', value: 'DETECTED IN MESSAGE', badge: '⚠️'),
      ];
    } else {
      return [_DetailRow(label: 'None', value: 'No OTP activity detected')];
    }
  }
  
  List<Widget> _buildLinkChildren(ScamEvent result) {
    if (result.linkFindings?.isNotEmpty ?? false) {
      return result.linkFindings!.map((l) => _DetailRow(
        label: l.domain,
        value: l.verdict.toUpperCase(),
        badge: l.isSuspicious ? '⚠️' : (l.matchesTrusted ? '✅' : '❓'),
      )).toList();
    } else {
      return [_DetailRow(label: 'None', value: 'No links detected')];
    }
  }
  
  List<Widget> _buildCampaignChildren(ScamEvent result) {
    if (result.campaign.campaignId.isNotEmpty) {
      return [
        _DetailRow(label: 'Campaign ID', value: result.campaign.campaignId),
        _DetailRow(label: 'Risk Level', value: result.campaign.riskLevel.toUpperCase()),
        _DetailRow(label: 'Events', value: '${result.campaign.eventCount}'),
        _DetailRow(label: 'Channels', value: result.campaign.channels?.join(', ') ?? ''),
        _DetailRow(label: 'Exposure', value: result.campaign.exposure?.description ?? ''),
      ];
    } else {
      return [_DetailRow(label: 'New', value: 'No existing campaign correlation')];
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _DetailSection({required this.title, required this.children});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;
  
  const _DetailRow({required this.label, required this.value, this.badge});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            )),
          ),
          if (badge != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
              ),
              child: Text(badge!, style: theme.textTheme.labelSmall),
            ),
          ],
        ],
      ),
    );
  }
}

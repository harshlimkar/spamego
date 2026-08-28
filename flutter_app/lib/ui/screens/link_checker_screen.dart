// Link Checker Screen — manual link/URL verification
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/risk_engine.dart';
import '../theme/app_theme.dart';

class LinkCheckerScreen extends StatefulWidget {
  const LinkCheckerScreen({super.key});

  @override
  State<LinkCheckerScreen> createState() => _LinkCheckerScreenState();
}

class _LinkCheckerScreenState extends State<LinkCheckerScreen> {
  final _urlController = TextEditingController();
  bool _isChecking = false;
  _LinkResult? _result;

  static const _examples = [
    'http://sbi-kyc-secure-login.xyz',
    'http://hdfc-verify-account.xyz',
    'https://www.sbi.co.in',
    'http://jio-prize-claim-now.xyz',
    'https://www.incometax.gov.in',
    'http://axis-bank-update-kyc.net',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() { _isChecking = true; _result = null; });

    await Future.delayed(const Duration(milliseconds: 800)); // Simulate analysis
    final result = _analyzeLink(url);
    setState(() { _isChecking = false; _result = result; });
  }

  _LinkResult _analyzeLink(String url) {
    final lower = url.toLowerCase();

    // Extract domain
    String domain = url;
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      domain = uri.host;
    } catch (_) {}

    // Trusted domains
    const trustedDomains = [
      'sbi.co.in', 'onlinesbi.sbi', 'hdfcbank.com', 'icicibank.com',
      'axisbank.com', 'pnbindia.in', 'bankofbaroda.in', 'unionbankofindia.co.in',
      'incometax.gov.in', 'gov.in', 'nic.in', 'npci.org.in', 'upi.org',
      'paytm.com', 'phonepe.com', 'google.com', 'amazon.in', 'flipkart.com',
      'irctc.co.in', 'uidai.gov.in', 'mygov.in',
    ];

    final isTrusted = trustedDomains.any((d) => domain == d || domain.endsWith('.$d'));

    // Suspicious patterns
    final signals = <String>[];
    if (lower.contains('kyc')) signals.add('Contains "kyc" — often used in bank impersonation scams');
    if (lower.contains('verify') || lower.contains('secure-login')) signals.add('Claims to be a secure verification site');
    if (lower.contains('prize') || lower.contains('claim') || lower.contains('lucky')) signals.add('Prize or lottery claim detected');
    if (lower.contains('block') || lower.contains('freeze') || lower.contains('suspend')) signals.add('Urgency language (block/freeze) detected');
    if (lower.contains('-sbi') || lower.contains('sbi-') || lower.contains('-hdfc') || lower.contains('hdfc-')) {
      signals.add('Uses a bank name with a hyphen — likely a lookalike domain');
    }
    if (RegExp(r'\.(xyz|tk|ml|ga|cf|gq|top|click|online)$').hasMatch(domain)) {
      signals.add('Uses a suspicious TLD (.xyz, .tk, .online, etc.) — not associated with legitimate services');
    }
    if (RegExp(r'\d{4,}').hasMatch(domain)) {
      signals.add('Domain contains an unusual number sequence');
    }

    // Lookalike check
    bool isLookalike = false;
    const brandNames = ['sbi', 'hdfc', 'icici', 'axis', 'paytm', 'phonepe', 'gpay', 'jio', 'airtel', 'amazon', 'flipkart'];
    for (final brand in brandNames) {
      if (lower.contains(brand) && !isTrusted) {
        isLookalike = true;
        signals.add('Domain uses the brand name "$brand" but is NOT the official website');
        break;
      }
    }

    // Verdict
    String verdict;
    String riskLevel;
    if (isTrusted) {
      verdict = '✅ VERIFIED / TRUSTED';
      riskLevel = 'safe';
    } else if (signals.length >= 2 || isLookalike) {
      verdict = '🔴 SUSPICIOUS / DANGEROUS';
      riskLevel = 'high';
    } else if (signals.isNotEmpty) {
      verdict = '⚠️ POTENTIALLY SUSPICIOUS';
      riskLevel = 'medium';
    } else {
      verdict = '❓ UNKNOWN — PROCEED WITH CAUTION';
      riskLevel = 'low';
    }

    return _LinkResult(
      url: url,
      domain: domain,
      verdict: verdict,
      riskLevel: riskLevel,
      isTrusted: isTrusted,
      isLookalike: isLookalike,
      signals: signals,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Link Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paste any suspicious link to check if it is safe. Do NOT click on links from unknown senders.',
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Paste the link here:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'http://example.com or paste a full URL',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) _urlController.text = data!.text!;
                  },
                  tooltip: 'Paste from clipboard',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isChecking ? null : _checkLink,
                icon: _isChecking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search),
                label: Text(_isChecking ? 'CHECKING...' : 'CHECK LINK', style: const TextStyle(fontSize: 17)),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 58)),
              ),
            ),
            const SizedBox(height: 20),

            // Examples
            Text('Try These Examples:', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _examples.map((ex) => ActionChip(
                label: Text(ex.replaceAll('https://', '').replaceAll('http://', ''), maxLines: 1, overflow: TextOverflow.ellipsis),
                onPressed: () { _urlController.text = ex; _checkLink(); },
                avatar: const Icon(Icons.lightbulb_outline, size: 16),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // Result
            if (_result != null) _LinkResultWidget(result: _result!),
          ],
        ),
      ),
    );
  }
}

class _LinkResult {
  final String url;
  final String domain;
  final String verdict;
  final String riskLevel;
  final bool isTrusted;
  final bool isLookalike;
  final List<String> signals;

  _LinkResult({
    required this.url,
    required this.domain,
    required this.verdict,
    required this.riskLevel,
    required this.isTrusted,
    required this.isLookalike,
    required this.signals,
  });
}

class _LinkResultWidget extends StatelessWidget {
  final _LinkResult result;

  const _LinkResultWidget({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = RiskColors.forLevel(result.riskLevel, context);
    final bgColor = RiskColors.backgroundForLevel(result.riskLevel, context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1.5),
        const SizedBox(height: 12),
        Text('Result', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        // Verdict card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: riskColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.verdict,
                style: TextStyle(color: riskColor, fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Domain: ${result.domain}',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (result.isLookalike) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.warning, color: riskColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This appears to be a FAKE/LOOKALIKE of a legitimate website',
                        style: TextStyle(color: riskColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (result.signals.isNotEmpty) ...[
          Text('Suspicious Signals Detected:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.signals.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber, color: riskColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],

        if (result.isTrusted) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: Icon(Icons.verified, color: Colors.green.shade700, size: 32),
              title: Text('Verified Official Website', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w700)),
              subtitle: Text('This domain is in ScameGo\'s trusted official database', style: TextStyle(color: Colors.green.shade700)),
            ),
          ),
        ],

        const SizedBox(height: 16),
        if (!result.isTrusted) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety Advice', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Text('• Do NOT click this link unless you are 100% sure of its source\n• Do NOT enter any passwords, OTP, or bank details\n• Always verify by visiting the official website directly by typing in your browser', style: TextStyle(color: Colors.orange.shade800, height: 1.6)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

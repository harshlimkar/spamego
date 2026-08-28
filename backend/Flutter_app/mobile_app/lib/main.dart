import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ─── Configuration ────────────────────────────────────────────
// Using your active Ngrok URL for testing on Moto G96
const String kBackendBaseUrl = 'https://defense-drench-debrief.ngrok-free.dev';
const String kWsBaseUrl = 'wss://defense-drench-debrief.ngrok-free.dev';
// ──────────────────────────────────────────────────────────────

void main() {
  runApp(const ScamDetectApp());
}

class ScamDetectApp extends StatelessWidget {
  const ScamDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScamDetect Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const DialerScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 1: DIALER
// ═══════════════════════════════════════════════════════════════
class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen>
    with SingleTickerProviderStateMixin {
  final _roomController = TextEditingController();
  bool _isConnecting = false;
  static const platform = MethodChannel('com.scamdetect.call/native');
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final destinationNumber = _roomController.text.trim();

    if (destinationNumber.isEmpty) {
      _showSnack('Enter a phone number or any session name.');
      return;
    }

    // Request mic permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showSnack('Microphone permission is required.');
      return;
    }

    setState(() => _isConnecting = true);

    // Use number as session ID so the backend and alert WS use the same key
    final sessionId = destinationNumber.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          roomId: sessionId,
          userName: 'Caller',
        ),
      ),
    );

    if (mounted) setState(() => _isConnecting = false);
  }


  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Logo / Icon ──
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF3B36B0),
                    ]),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'ScamDetect Call',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered real-time scam protection',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 48),

              // ── Phone Number field ──
              _buildTextField(
                controller: _roomController,
                label: 'Enter Phone Number',
                hint: 'e.g. 8270768841',
                icon: Icons.dialpad_rounded,
              ),
              const SizedBox(height: 36),

              // ── Connect Button ──
              SizedBox(
                width: double.infinity,
                height: 58,
                child: _isConnecting
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _connect,
                        icon: const Icon(Icons.call_rounded, size: 22),
                        label: const Text(
                          'Connect Call',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF6C63FF).withOpacity(0.4),
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // ── Info chips ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(Icons.mic_rounded, 'Live Audio'),
                  const SizedBox(width: 10),
                  _chip(Icons.psychology_rounded, 'AI Analysis'),
                  const SizedBox(width: 10),
                  _chip(Icons.shield_rounded, 'Protected'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 1.0, fontWeight: FontWeight.normal),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 2: ACTIVE CALL (Scam Analysis Overlay)
// ═══════════════════════════════════════════════════════════════
class ActiveCallScreen extends StatefulWidget {
  final String roomId;
  final String userName;

  const ActiveCallScreen({
    super.key,
    required this.roomId,
    required this.userName,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen>
    with TickerProviderStateMixin {
  bool _isRoomConnected = true;
  bool _isListening = false;

  // Native audio EventChannel
  static const _audioChannel = EventChannel('com.scamdetect.call/audio_stream');
  static const _nativeChannel = MethodChannel('com.scamdetect.call/native');
  StreamSubscription? _audioSub;
  WebSocketChannel? _audioWsChannel;

  // Alert WebSocket
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;

  // Scam state
  bool _isScam = false;
  int _riskScore = 0;
  String _threatType = 'SAFE';
  String _warningMessage = '✅ AI Sentinel active. Tap mic to start.';

  // Transcript
  final List<String> _transcripts = [];
  final ScrollController _scrollController = ScrollController();

  // Animations
  late AnimationController _threatPulseController;
  late Animation<double> _threatPulse;
  late AnimationController _bannerController;
  late Animation<Color?> _bannerColor;

  // Call timer
  late Stopwatch _callTimer;
  Timer? _timerTick;
  String _callDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _callTimer = Stopwatch()..start();
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final elapsed = _callTimer.elapsed;
        setState(() {
          _callDuration =
              '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });

    _threatPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _threatPulse = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _threatPulseController, curve: Curves.easeInOut),
    );

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bannerColor = ColorTween(
      begin: const Color(0xFF1B5E20),
      end: const Color(0xFFB71C1C),
    ).animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeOut));

    _connectWebSocket();
  }

  @override
  void dispose() {
    _timerTick?.cancel();
    _callTimer.stop();
    _threatPulseController.dispose();
    _bannerController.dispose();
    _wsSub?.cancel();
    _wsChannel?.sink.close();
    _audioSub?.cancel();
    _audioWsChannel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Start Mic Streaming ──────────────────────────────────────
  void _startMicStreaming() {
    if (_isListening) return; // Prevent double-start

    final audioWsUrl = '$kWsBaseUrl/ws/audio/${widget.roomId}';
    try {
      _audioWsChannel = WebSocketChannel.connect(Uri.parse(audioWsUrl));
    } catch (e) {
      debugPrint('Failed to connect audio WS: $e');
      return;
    }

    _audioSub = _audioChannel.receiveBroadcastStream().listen(
      (dynamic chunk) {
        try {
          if (chunk is Uint8List) {
            _audioWsChannel?.sink.add(chunk);
          } else if (chunk is List) {
            _audioWsChannel?.sink.add(Uint8List.fromList(chunk.cast<int>()));
          }
        } catch (e) {
          debugPrint('Audio chunk send error: $e');
        }
      },
      onError: (e) {
        debugPrint('Audio EventChannel error: $e');
        if (mounted) setState(() => _isListening = false);
      },
      onDone: () {
        debugPrint('Audio EventChannel done');
        if (mounted) setState(() => _isListening = false);
      },
      cancelOnError: false,
    );

    setState(() => _isListening = true);
    debugPrint('🎙️ Mic streaming started → $audioWsUrl');
  }

  void _stopMicStreaming() {
    try {
      _audioWsChannel?.sink.add('stop');
    } catch (_) {}
    _audioSub?.cancel();
    try {
      _audioWsChannel?.sink.close();
    } catch (_) {}
    _audioSub = null;
    _audioWsChannel = null;
    if (mounted) setState(() => _isListening = false);
    debugPrint('🛑 Mic streaming stopped.');
  }

  // ── WebSocket Connection ─────────────────────────────────────
  void _connectWebSocket() {
    final wsUrl = '$kWsBaseUrl/ws/alerts/${widget.roomId}';
    _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _wsSub = _wsChannel!.stream.listen(
      _onWsMessage,
      onError: (e) => debugPrint('WS error: $e'),
      onDone: () => debugPrint('WS disconnected'),
    );

    // Send keep-alive pings every 20s
    Timer.periodic(const Duration(seconds: 20), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _wsChannel?.sink.add('ping');
    });
  }

  void _onWsMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'];

      if (type == 'analysis') {
        final isScam = data['is_scam'] as bool? ?? false;
        final riskScore = data['risk_score'] as int? ?? 0;
        final threatType = data['threat_type'] as String? ?? 'SAFE';
        final warningMsg = data['warning_message'] as String? ?? '';
        final transcript = data['transcript'] as String? ?? '';

        if (mounted) {
          setState(() {
            _isScam = isScam;
            _riskScore = riskScore;
            _threatType = threatType;
            _warningMessage = warningMsg;

            if (transcript.isNotEmpty) {
              _transcripts.add(transcript);
            }
          });

          // Animate banner
          if (isScam) {
            _bannerController.forward();
            _threatPulseController.repeat(reverse: true);
          } else {
            _bannerController.reverse();
            _threatPulseController.stop();
            _threatPulseController.reset();
          }

          // Auto-scroll transcript
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }

  // ── End Call ─────────────────────────────────────────────────
  Future<void> _endCall() async {
    // Hang up the native call
    const platform = MethodChannel('com.scamdetect.call/native');
    try {
      // In a real implementation, we would add an endCall method
      // For now, returning pops the screen
    } catch (e) {}
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP RISK BANNER ──
            AnimatedBuilder(
              animation: _bannerController,
              builder: (_, __) => ScaleTransition(
                scale: _threatPulse,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isScam
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFF1B5E20),
                    boxShadow: [
                      BoxShadow(
                        color: (_isScam
                                ? Colors.red
                                : const Color(0xFF4CAF50))
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isScam
                            ? Icons.warning_rounded
                            : Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isScam
                                  ? 'THREAT DETECTED — Risk: $_riskScore%'
                                  : 'Call Protected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (_isScam) ...[
                              const SizedBox(height: 2),
                              Text(
                                _warningMessage,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_isScam)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _threatType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── CALL INFO ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomId,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Live Call · $_callDuration',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Connection indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isRoomConnected
                              ? const Color(0xFF4CAF50)
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isRoomConnected ? 'Live' : 'Connecting...',
                        style: TextStyle(
                          color: _isRoomConnected
                              ? const Color(0xFF4CAF50)
                              : Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── RISK GAUGE ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Risk Level',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_riskScore%',
                        style: TextStyle(
                          color: _riskColor(_riskScore),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: 0, end: _riskScore / 100),
                      duration: const Duration(milliseconds: 600),
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _riskColor(_riskScore),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── LIVE TRANSCRIPT ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Live Transcription',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF13132A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: _transcripts.isEmpty
                            ? Center(
                                child: Text(
                                  _isRoomConnected
                                      ? 'Listening... Start speaking.'
                                      : 'Connecting to call...',
                                  style: const TextStyle(
                                    color: Colors.white24,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _transcripts.length,
                                itemBuilder: (_, i) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i + 1}. ',
                                        style: const TextStyle(
                                          color: Color(0xFF6C63FF),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _transcripts[i],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── BOTTOM CONTROLS ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute toggle
                  _controlButton(
                    icon: _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: _isListening ? 'Stop' : 'Start AI',
                    color: _isListening
                        ? Colors.redAccent.withOpacity(0.3)
                        : Colors.greenAccent.withOpacity(0.2),
                    onTap: () {
                      if (_isListening) {
                        _stopMicStreaming();
                      } else {
                        _startMicStreaming();
                      }
                    },
                  ),
                  const SizedBox(width: 24),

                  // End Call FAB
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Speaker toggle
                  _controlButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Speaker',
                    color: Colors.white24,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _riskColor(int score) {
    if (score >= 70) return Colors.red;
    if (score >= 40) return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

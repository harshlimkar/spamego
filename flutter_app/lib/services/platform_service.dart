// Platform service for Flutter ↔ Android communication
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../models/scam_event.dart';
import '../models/notification_event.dart';
import 'call_audio_service.dart';
import 'stt_service.dart';

class PlatformService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('scamego/platform');
  static const EventChannel _smsChannel = EventChannel('scamego/sms_stream');
  static const EventChannel _callChannel = EventChannel('scamego/call_stream');
  static const EventChannel _notificationChannel = EventChannel('scamego/notification_stream');
  
  bool _isInitialized = false;
  bool _hasSmsPermission = false;
  bool _hasCallPermission = false;
  bool _hasNotificationPermission = false;
  bool _isDefaultDialer = false;
  bool _isNotificationListenerEnabled = false;
  
  late final CallAudioService _audioService;
  late final SttService _sttService;
  
  // Callbacks for incoming events
  Function(ScamEvent)? onSmsReceived;
  Function(ScamEvent)? onCallReceived;
  Function(NotificationEvent)? onNotificationReceived;
  Function(String)? onCallStateChanged;
  
  bool get isInitialized => _isInitialized;
  bool get hasSmsPermission => _hasSmsPermission;
  bool get hasCallPermission => _hasCallPermission;
  bool get hasNotificationPermission => _hasNotificationPermission;
  bool get isDefaultDialer => _isDefaultDialer;
  bool get isNotificationListenerEnabled => _isNotificationListenerEnabled;
  
  Future<void> initialize() async {
    try {
      _audioService = CallAudioService();
      _sttService = SttService(_audioService);
      
      // Listen to live STT transcripts to update call risk in real-time
      _sttService.transcriptStream.listen((text) async {
        if (text.isNotEmpty) {
          final event = await analyzeWithBackend(
            channel: 'call',
            sender: 'LIVE_CALL',
            text: text,
          );
          onCallReceived?.call(event);
        }
      });
      
      // Check permissions
      await _checkPermissions();
      
      // Set up method call handlers
      _channel.setMethodCallHandler(_handleMethodCall);
      
      // Listen to SMS stream
      _smsChannel.receiveBroadcastStream().listen(
        _onSmsEvent,
        onError: (error) => debugPrint('SMS stream error: $error'),
      );
      
      // Listen to call stream
      _callChannel.receiveBroadcastStream().listen(
        _onCallEvent,
        onError: (error) => debugPrint('Call stream error: $error'),
      );

      // Listen to notification stream
      _notificationChannel.receiveBroadcastStream().listen(
        _onNotificationEvent,
        onError: (error) => debugPrint('Notification stream error: $error'),
      );
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Platform service initialization error: $e');
    }
  }
  
  Future<void> _checkPermissions() async {
    try {
      final permissions = await _channel.invokeMethod('checkPermissions');
      _hasSmsPermission = permissions['sms'] ?? false;
      _hasCallPermission = permissions['call'] ?? false;
      _hasNotificationPermission = permissions['notification'] ?? false;
      _isDefaultDialer = permissions['isDefaultDialer'] ?? false;
      _isNotificationListenerEnabled = permissions['notificationListener'] ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
  }
  
  Future<void> requestPermissions() async {
    try {
      await _channel.invokeMethod('requestPermissions');
      await _checkPermissions();
    } catch (e) {
      debugPrint('Request permissions error: $e');
    }
  }
  
  Future<void> requestCallScreeningRole() async {
    try {
      await _channel.invokeMethod('requestCallScreeningRole');
      await _checkPermissions();
    } catch (e) {
      debugPrint('Request call screening role error: $e');
    }
  }
  
  Future<void> openNotificationListenerSettings() async {
    try {
      await _channel.invokeMethod('openNotificationListenerSettings');
    } catch (e) {
      debugPrint('Open notification settings error: $e');
    }
  }

  Future<bool> checkNotificationListenerPermission() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('isNotificationListenerEnabled') ?? false;
      _isNotificationListenerEnabled = enabled;
      notifyListeners();
      return enabled;
    } catch (e) {
      debugPrint('Check notification listener error: $e');
      return false;
    }
  }
  
  Future<void> makeCall(String number) async {
    try {
      // Simulate STT pipeline activation when making a call in this demo
      _sttService.simulateScamCall();
      
      final res = await FlutterPhoneDirectCaller.callNumber(number);
      if (res != null && !res) {
        debugPrint('Make call failed');
      }
    } catch (e) {
      debugPrint('Make call error: $e');
    }
  }
  
  Future<void> blockNumber(String number) async {
    try {
      await _channel.invokeMethod('blockNumber', {'number': number});
    } catch (e) {
      debugPrint('Block number error: $e');
    }
  }
  
  Future<void> sendSms(String number, String message) async {
    try {
      await _channel.invokeMethod('sendSms', {'number': number, 'message': message});
    } catch (e) {
      debugPrint('Send SMS error: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getCallLog({int limit = 50}) async {
    try {
      final result = await _channel.invokeMethod('getCallLog', {'limit': limit});
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      debugPrint('Get call log error: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final result = await _channel.invokeMethod('getContacts');
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      debugPrint('Get contacts error: $e');
      return [];
    }
  }
  
  Future<void> analyzeSms(String sender, String text) async {
    try {
      await _channel.invokeMethod('analyzeSms', {'sender': sender, 'text': text});
    } catch (e) {
      debugPrint('Analyze SMS error: $e');
    }
  }
  
  Future<void> analyzeCall(String number, String name) async {
    try {
      await _channel.invokeMethod('analyzeCall', {'number': number, 'name': name});
    } catch (e) {
      debugPrint('Analyze call error: $e');
    }
  }
  
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onSmsAnalyzed':
        final data = Map<String, dynamic>.from(call.arguments as Map);
        final event = _mapToScamEvent(data);
        onSmsReceived?.call(event);
        break;
      case 'onCallAnalyzed':
        final data = Map<String, dynamic>.from(call.arguments as Map);
        final event = _mapToScamEvent(data);
        onCallReceived?.call(event);
        break;
      case 'onCallStateChanged':
        final state = call.arguments as String;
        onCallStateChanged?.call(state);
        break;
      case 'onPermissionsChanged':
        await _checkPermissions();
        break;
    }
  }
  
  void _onSmsEvent(dynamic event) {
    try {
      final data = Map<String, dynamic>.from(event as Map);
      final scamEvent = _mapToScamEvent(data);
      onSmsReceived?.call(scamEvent);
    } catch (e) {
      debugPrint('SMS event parse error: $e');
    }
  }
  
  void _onCallEvent(dynamic event) {
    try {
      final number = event as String;
      analyzeWithBackend(
        channel: 'call',
        sender: number,
        text: '',
      ).then((scamEvent) {
        onCallReceived?.call(scamEvent);
      });
    } catch (e) {
      debugPrint('Call event parse error: $e');
    }
  }

  void _onNotificationEvent(dynamic event) {
    try {
      final data = Map<String, dynamic>.from(event as Map);
      final notifEvent = NotificationEvent.fromMap(data);
      onNotificationReceived?.call(notifEvent);
    } catch (e) {
      debugPrint('Notification event parse error: $e');
    }
  }
  
  ScamEvent _mapToScamEvent(Map<String, dynamic> data) {
    return ScamEvent(
      id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      channel: data['channel'] as String? ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      sender: data['sender'] as String? ?? '',
      text: data['text'] as String? ?? '',
      normalized: data['normalized'] as String? ?? '',
      language: data['language'] as String? ?? 'en',
      verdict: data['verdict'] as String? ?? 'UNKNOWN',
      headline: data['headline'] as String? ?? '',
      risk: RiskResult.fromJson(data['risk'] as Map<String, dynamic>? ?? {}),
      campaign: CampaignInfo.fromJson(data['campaign'] as Map<String, dynamic>? ?? {}),
      intervention: Intervention.fromJson(data['intervention'] as Map<String, dynamic>? ?? {}),
      familyAlert: FamilyAlertDecision.fromJson(data['familyAlert'] as Map<String, dynamic>? ?? {}),
      recovery: data['recovery'] != null 
          ? RecoveryPlan.fromJson(data['recovery'] as Map<String, dynamic>)
          : null,
      supportSms: data['supportSms'] as String?,
    );
  }
  
  // Risk engine integration - call Python backend
  Future<ScamEvent> analyzeWithBackend({
    required String channel,
    required String sender,
    required String text,
    String? upiId,
    double? amountInr,
    String? url,
    String? recipient,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/intel/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channel': channel,
          'sender': sender,
          'text': text,
          'upi_id': upiId,
          'amount_inr': amountInr,
          'url': url,
          'recipient': recipient,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        return ScamEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          channel: channel,
          timestamp: DateTime.now(),
          sender: sender,
          text: text,
          normalized: text.toLowerCase(),
          language: data['language'] as String? ?? 'en',
          verdict: data['verdict'] as String? ?? 'UNKNOWN',
          headline: data['headline'] as String? ?? 'Analyzed Event',
          risk: RiskResult.fromJson(data['risk'] as Map<String, dynamic>? ?? {}),
          campaign: CampaignInfo.fromJson(data['campaign'] as Map<String, dynamic>? ?? {}),
          intervention: Intervention.fromJson(data['intervention'] as Map<String, dynamic>? ?? {}),
          familyAlert: FamilyAlertDecision.fromJson(data['family_alert'] as Map<String, dynamic>? ?? {}),
          recovery: data['recovery'] != null 
              ? RecoveryPlan.fromJson(data['recovery'] as Map<String, dynamic>)
              : null,
          supportSms: data['support_sms'] as String?,
        );
      } else {
        throw Exception('Failed to analyze with backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Backend analysis error: $e');
      rethrow;
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/api_config.dart';
import '../models/campaign_alert.dart';

class CampaignAlertService {
  static final CampaignAlertService _instance = CampaignAlertService._internal();
  static CampaignAlertService get instance => _instance;

  CampaignAlertService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<CampaignAlert> _alertController = StreamController<CampaignAlert>.broadcast();

  Stream<CampaignAlert> get alertStream => _alertController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_isConnected) return;
    _connectInternal(userId);
  }

  void _connectInternal(String userId) {
    try {
      final wsUrl = Uri.parse(ApiConfig.campaignAlertsWs(userId));
      _channel = WebSocketChannel.connect(wsUrl);
      
      _isConnected = true;
      debugPrint('[CampaignAlertService] Connected to $wsUrl');

      _subscription = _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            final alert = CampaignAlert.fromJson(data);
            _alertController.add(alert);
          } catch (e) {
            debugPrint('[CampaignAlertService] Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('[CampaignAlertService] WebSocket Error: $error');
          _reconnect(userId);
        },
        onDone: () {
          debugPrint('[CampaignAlertService] WebSocket Closed.');
          _reconnect(userId);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[CampaignAlertService] Failed to connect: $e');
      _reconnect(userId);
    }
  }

  void _reconnect(String userId) {
    _isConnected = false;
    _subscription?.cancel();
    _channel?.sink.close();
    
    // Simple backoff for reconnect
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        debugPrint('[CampaignAlertService] Attempting to reconnect...');
        _connectInternal(userId);
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _alertController.close();
    _isConnected = false;
  }
}

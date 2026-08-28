import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

// Callback type for when a notification is tapped
typedef NotificationTapCallback = void Function(String? payload);

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  static LocalNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  NotificationTapCallback? onNotificationTapped;

  LocalNotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Currently only focusing on Android per instructions, but ready for iOS
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTapped?.call(response.payload);
      },
    );
  }

  Future<void> showCriticalAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'scamego_critical_alerts', // id
      'Critical Scam Alerts', // title
      channelDescription: 'High priority alerts for critical scam threats',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Critical Scam Alert',
      color: Colors.red,
      enableVibration: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

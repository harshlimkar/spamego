// Flutter app entry point for ScameGo - Digital Scam Protection Platform
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/calls_screen.dart';
import 'ui/screens/active_call_screen.dart';
import 'ui/screens/payment_risk_screen.dart';
import 'ui/screens/messages_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/alerts_screen.dart';
import 'ui/screens/protection_screen.dart';
import 'ui/screens/recovery_screen.dart';
import 'ui/screens/family_screen.dart';
import 'ui/screens/sms_protection_screen.dart';
import 'ui/screens/link_checker_screen.dart';
import 'ui/screens/developer_dashboard_screen.dart';
import 'services/platform_service.dart';
import 'services/threat_analysis_service.dart';
import 'services/campaign_alert_service.dart';
import 'services/local_notification_service.dart';
import 'ui/screens/critical_alert_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize app state
  final appState = AppState();
  await appState.initialize();

  // 2. Initialize platform service
  final platformService = PlatformService();
  await platformService.initialize();

  // 3. Initialize threat analysis adapter service
  final threatAnalysisService = ThreatAnalysisService(appState: appState);

  // 4. Initialize Campaign and Notification Services
  final localNotificationService = LocalNotificationService.instance;
  await localNotificationService.initialize();

  // Listen for local notification taps to route to critical alert screen
  localNotificationService.onNotificationTapped = (payload) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/critical-alert');
    }
  };

  // Setup Campaign WebSocket Connection
  final campaignAlertService = CampaignAlertService.instance;
  campaignAlertService.connect('user_1'); // Currently stubbed to user_1

  // Listen to Campaign Alerts and trigger local notifications and app state
  campaignAlertService.alertStream.listen((alert) {
    final isCritical = appState.processCampaignAlert(alert);
    if (isCritical) {
      localNotificationService.showCriticalAlert(
        id: alert.campaignId.hashCode,
        title: '⚠️ CRITICAL SCAM ALERT',
        body: 'A dangerous scam threat has been detected. Tap to view details.',
        payload: alert.campaignId,
      );

      // Auto-alert trusted contact if preference is enabled
      if (appState.automaticCriticalAlerts && appState.trustedContacts.isNotEmpty) {
        // Here we could implement the true automatic background SMS if permissions allow.
        // For now, per instruction, if true automatic is supported reuse it, else rely on manual GET HELP.
        debugPrint('[CampaignAlertService] Automatic critical alert triggered for Guardian.');
      }
    }
  });

  // 5. Wire real-time notification listener to threat analysis pipeline
  platformService.onNotificationReceived = (notificationEvent) async {
    debugPrint('[Main] Intercepted Notification: ${notificationEvent.appName} (${notificationEvent.source.name}) - ${notificationEvent.title}');
    final scamEvent = await threatAnalysisService.processNotification(notificationEvent);
    if (scamEvent != null && (scamEvent.risk.level == 'critical' || scamEvent.risk.level == 'high')) {
      debugPrint('[Main] High/Critical Threat Detected in Notification: ${scamEvent.headline}');
    }
  };

  // 6. Wire real-time SMS stream to threat analysis pipeline
  platformService.onSmsReceived = (smsEvent) async {
    debugPrint('[Main] Intercepted SMS: ${smsEvent.sender} - ${smsEvent.text}');
    await threatAnalysisService.processSms(
      sender: smsEvent.sender,
      text: smsEvent.text,
      timestamp: smsEvent.timestamp,
    );
  };

  // 6. Wire real-time call screening
  platformService.onCallReceived = (scamEvent) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ActiveCallScreen(
            initialEvent: scamEvent,
            onEndCall: () => Navigator.pop(context),
          ),
        ),
      );
    }
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: platformService),
        Provider.value(value: threatAnalysisService),
      ],
      child: const ScameGoApp(),
    ),
  );
}

class ScameGoApp extends StatelessWidget {
  const ScameGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScameGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home: const MainNavigationScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/calls': (context) => const CallsScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/sms': (context) => const SmsProtectionScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/protection': (context) => const ProtectionScreen(),
        '/payment': (context) => const PaymentRiskScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/recovery': (context) => const RecoveryScreen(),
        '/family': (context) => const FamilyScreen(),
        '/link-check': (context) => const LinkCheckerScreen(),
        '/dev-dashboard': (context) => const DeveloperDashboardScreen(),
        '/critical-alert': (context) => const CriticalAlertScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CallsScreen(),
    const MessagesScreen(),
    const AlertsScreen(),
    const ProtectionScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.call_outlined),
      selectedIcon: Icon(Icons.call),
      label: 'Calls',
    ),
    const NavigationDestination(
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: 'Messages',
    ),
    const NavigationDestination(
      icon: Icon(Icons.warning_amber_outlined),
      selectedIcon: Icon(Icons.warning_amber),
      label: 'Alerts',
    ),
    const NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield),
      label: 'Protection',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
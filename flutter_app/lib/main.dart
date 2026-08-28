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

  // 4. Wire real-time notification listener to threat analysis pipeline
  platformService.onNotificationReceived = (notificationEvent) async {
    debugPrint('[Main] Intercepted Notification: ${notificationEvent.appName} (${notificationEvent.source.name}) - ${notificationEvent.title}');
    final scamEvent = await threatAnalysisService.processNotification(notificationEvent);
    if (scamEvent != null && (scamEvent.risk.level == 'critical' || scamEvent.risk.level == 'high')) {
      debugPrint('[Main] High/Critical Threat Detected in Notification: ${scamEvent.headline}');
    }
  };

  // 5. Wire real-time SMS stream to threat analysis pipeline
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
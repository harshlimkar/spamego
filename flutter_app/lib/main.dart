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
import 'services/platform_service.dart';
// Stubs for missing screens
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Alerts Screen')));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform service
  final platformService = PlatformService();
  await platformService.initialize();
  
  // Initialize app state
  final appState = AppState();
  await appState.initialize();

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
        '/alerts': (context) => const AlertsScreen(),
        '/protection': (context) => const PaymentRiskScreen(),
        '/settings': (context) => const SettingsScreen(),
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
    const PaymentRiskScreen(),
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
      icon: Icon(Icons.warning_outlined),
      selectedIcon: Icon(Icons.warning),
      label: 'Alerts',
    ),
    const NavigationDestination(
      icon: Icon(Icons.security_outlined),
      selectedIcon: Icon(Icons.security),
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
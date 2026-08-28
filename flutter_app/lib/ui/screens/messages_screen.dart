// Messages screen - SMS + scam detection
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/scam_event.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/message_list.dart';
import '../../ui/widgets/test_message_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.sms_outlined), text: 'SMS Scans'),
                Tab(icon: Icon(Icons.flag_outlined), text: 'Flagged'),
                Tab(icon: Icon(Icons.science_outlined), text: 'Test a Message'),
              ],
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // SMS Scans Tab
              MessageList(
                events: appState.scamHistory.where((e) => e.channel == 'sms').toList(),
                filter: 'all',
              ),
              // Flagged Tab
              MessageList(
                events: appState.scamHistory
                    .where((e) => e.channel == 'sms' && e.risk.level != 'safe')
                    .toList(),
                filter: 'flagged',
              ),
              // Test a Message Tab
              const TestMessageWidget(),
            ],
          ),
        );
      },
    );
  }
}
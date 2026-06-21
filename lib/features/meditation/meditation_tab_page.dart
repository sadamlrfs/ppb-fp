import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/meditation_provider.dart';
import '../chat/chat_list_page.dart';
import 'session_list_page.dart';

class MeditationTabPage extends StatefulWidget {
  const MeditationTabPage({super.key});

  @override
  State<MeditationTabPage> createState() => _MeditationTabPageState();
}

class _MeditationTabPageState extends State<MeditationTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final meditationProv = context.read<MeditationProvider>();
    final chatProv = context.read<ChatProvider>();
    await meditationProv.loadSessions();
    if (!mounted) return;
    meditationProv.listenUserSessions(uid);
    chatProv.listenConversations(uid);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditasi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.self_improvement), text: 'Sesi'),
            Tab(icon: Icon(Icons.smart_toy_outlined), text: 'AI Companion'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SessionListPage(),
          ChatListPage(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              heroTag: 'addSessionFAB',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addSession),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Sesi'),
            )
          : null,
    );
  }
}

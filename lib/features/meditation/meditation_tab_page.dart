import 'package:flutter/material.dart';

// TODO [Anggota 3 — Meditation + AI]: Container Tab 3 dengan 2 sub-tab
//
// Struktur:
//   - AppBar dengan title "Meditasi"
//   - TabBar 2 tab:
//       Tab 0 "Sesi"  → SessionListPage
//       Tab 1 "AI Companion" → ChatListPage
//
// initState:
//   - MeditationProvider.loadSessions()
//   - MeditationProvider.listenUserSessions(uid)
//   - ChatProvider.listenConversations(uid)

class MeditationTabPage extends StatefulWidget {
  const MeditationTabPage({super.key});

  @override
  State<MeditationTabPage> createState() => _MeditationTabPageState();
}

class _MeditationTabPageState extends State<MeditationTabPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Meditation Tab — TODO')),
    );
  }
}

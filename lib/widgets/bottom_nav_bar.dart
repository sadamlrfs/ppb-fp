import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../features/home/home_page.dart';
import '../features/journal/journal_list_page.dart';
import '../features/meditation/meditation_tab_page.dart';
import '../features/profile/profile_page.dart';

// Widget navigasi utama — 4 tab bottom navigation.
// Ganti dummy pages dengan implementasi masing-masing anggota saat sudah selesai.

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),           // Tab 0 — Anggota 2
    JournalListPage(),    // Tab 1 — Anggota 1
    MeditationTabPage(),  // Tab 2 — Anggota 3
    ProfilePage(),        // Tab 3 — Semua
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.home),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: AppStrings.journal),
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: AppStrings.meditate),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppStrings.profile),
        ],
      ),
    );
  }
}

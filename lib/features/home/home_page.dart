import 'package:flutter/material.dart';

// TODO [Anggota 2 — Mood Tracker]: Halaman utama / Tab 1
//
// Tampilan:
//   - Greeting card dengan nama user + quote dari ZenQuotes API (QuoteService)
//   - Widget _MoodCheckIn: tampilkan mood hari ini jika sudah ada, atau placeholder
//   - MoodChartWidget: chart tren mood 7/30 hari (fl_chart)
//   - MoodHistoryWidget: daftar mood terbaru (5 item) dengan tap ke MoodDetailPage
//   - FAB "Catat Mood" → navigasi ke MoodInputPage
//
// Provider yang digunakan: AuthProvider, MoodProvider
// Semantics identifier untuk Appium: 'homeTitle' (AppBar title), 'addMoodButton' (FAB)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home — TODO')),
    );
  }
}

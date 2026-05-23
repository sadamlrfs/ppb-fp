import 'package:flutter/material.dart';

// TODO [Anggota 2 — Mood Tracker]: Form input mood harian
//
// Tampilan:
//   - Grid 5 emoji (😢 😕 😐 😊 😄) yang bisa dipilih dengan animasi highlight
//   - TextField catatan (opsional)
//   - Tombol "Simpan Mood"
//
// Logika:
//   - Ambil uid dari AuthProvider
//   - Panggil MoodProvider.createMood(userId, moodLevel, note)
//   - Setelah berhasil, pop kembali ke HomePage
//
// Semantics identifier untuk Appium: 'moodEmojiLevel{1-5}', 'saveMoodButton'

class MoodInputPage extends StatefulWidget {
  const MoodInputPage({super.key});

  @override
  State<MoodInputPage> createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(child: Text('Mood Input — TODO')),
    );
  }
}

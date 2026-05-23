import 'package:flutter/material.dart';

// TODO [Anggota 2 — Mood Tracker]: Halaman detail + edit mood
//
// Menerima argument: MoodModel via ModalRoute.settings.arguments
//
// Tampilan:
//   - Emoji besar + label mood + tanggal/waktu
//   - Catatan (jika ada)
//   - Mode edit: picker emoji + TextField catatan
//   - Tombol Edit dan Delete di AppBar
//
// Logika:
//   - Edit: panggil MoodProvider.updateMood(mood.copyWith(...))
//   - Delete: konfirmasi dialog → MoodProvider.deleteMood(id) → pop

class MoodDetailPage extends StatefulWidget {
  const MoodDetailPage({super.key});

  @override
  State<MoodDetailPage> createState() => _MoodDetailPageState();
}

class _MoodDetailPageState extends State<MoodDetailPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Mood Detail — TODO')),
    );
  }
}

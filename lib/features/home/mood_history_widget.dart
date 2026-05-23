import 'package:flutter/material.dart';
import '../../models/mood_model.dart';

// TODO [Anggota 2 — Mood Tracker]: Widget daftar riwayat mood
//
// Props: List<MoodModel> moods
//
// Tampilan:
//   - ListView Card: emoji + label + tanggal relatif + cuplikan catatan
//   - Tap item → navigasi ke MoodDetailPage dengan argument MoodModel
//   - Empty state jika list kosong

class MoodHistoryWidget extends StatelessWidget {
  final List<MoodModel> moods;

  const MoodHistoryWidget({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return const Center(
        child: Text('Belum ada riwayat mood',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: moods
          .map((m) => ListTile(
                leading: Text(m.emoji,
                    style: const TextStyle(fontSize: 24)),
                title: Text(m.label),
                // TODO: tambahkan tanggal relatif & navigasi ke detail
              ))
          .toList(),
    );
  }
}

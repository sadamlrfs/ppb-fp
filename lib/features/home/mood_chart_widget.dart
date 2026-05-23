import 'package:flutter/material.dart';
import '../../models/mood_model.dart';

// TODO [Anggota 2 — Mood Tracker]: Widget chart tren mood
//
// Props: List<MoodModel> moods
//
// Implementasi:
//   - Gunakan LineChart dari package fl_chart
//   - Sumbu X: hari (relatif), sumbu Y: moodLevel 1–5
//   - Label sumbu Y: emoji sesuai level (😢 😕 😐 😊 😄)
//   - Warna line: AppColors.primary dengan area fill transparan
//   - Tampilkan empty state jika moods kosong

class MoodChartWidget extends StatelessWidget {
  final List<MoodModel> moods;

  const MoodChartWidget({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const Text('Chart — TODO'),
    );
  }
}

import 'package:flutter/material.dart';

// TODO [Anggota 3 — Meditation]: Daftar sesi meditasi + riwayat
//
// Tampilan:
//   - Judul "Sesi Meditasi"
//   - ListView _SessionCard: thumbnail + judul + deskripsi + durasi + chip kategori
//     Tap → navigasi ke SessionPlayerPage dengan argument MeditationSessionModel
//   - Section "Riwayat Sesi": 3 item terbaru + tombol "Lihat semua" → SessionHistoryPage
//   - Loading indicator saat MeditationProvider.loading == true
//   - Empty state jika sessions kosong
//
// Provider: MeditationProvider

class SessionListPage extends StatelessWidget {
  const SessionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Session List — TODO'));
  }
}

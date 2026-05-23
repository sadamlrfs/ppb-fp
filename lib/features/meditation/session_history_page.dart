import 'package:flutter/material.dart';

// TODO [Anggota 3 — Meditation]: Halaman riwayat sesi yang sudah diselesaikan
//
// Tampilan:
//   - ListView Card: nama sesi + rating bintang + tanggal + catatan (jika ada)
//   - PopupMenuButton per item: "Edit Rating" (dialog bintang + catatan) | "Hapus"
//   - Empty state jika userSessions kosong
//
// Logika:
//   - Edit: MeditationProvider.updateUserSession(session.copyWith(rating, note))
//   - Delete: konfirmasi dialog → MeditationProvider.deleteUserSession(id)
//
// Provider: MeditationProvider

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Session History — TODO')),
    );
  }
}

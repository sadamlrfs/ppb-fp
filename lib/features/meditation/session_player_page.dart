import 'package:flutter/material.dart';

// TODO [Anggota 3 — Meditation]: Audio player sesi meditasi
//
// Menerima argument: MeditationSessionModel via ModalRoute.settings.arguments
//
// Tampilan:
//   - Artwork bulat besar (gradient warna primary)
//   - Judul + deskripsi sesi
//   - Slider progress audio (posisi / durasi)
//   - Tombol: replay -10s | play/pause | forward +10s
//   - Setelah audio selesai (onPlayerComplete): tampilkan form rating (1-5 bintang)
//     + TextField catatan opsional + tombol "Simpan Sesi"
//
// Audio: gunakan package audioplayers → AudioPlayer()
//   - play(UrlSource(session.audioUrl))
//   - onPlayerStateChanged, onPositionChanged, onDurationChanged, onPlayerComplete
//
// Logika simpan:
//   - MeditationProvider.saveUserSession(userId, sessionId, rating, note?)
//   - Setelah berhasil: Navigator.pop(context)

class SessionPlayerPage extends StatefulWidget {
  const SessionPlayerPage({super.key});

  @override
  State<SessionPlayerPage> createState() => _SessionPlayerPageState();
}

class _SessionPlayerPageState extends State<SessionPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Session Player — TODO')),
    );
  }
}

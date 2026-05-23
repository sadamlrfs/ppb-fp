import 'package:flutter/material.dart';

// TODO [Semua]: Halaman profil user / Tab 4
//
// Tampilan:
//   - Avatar foto profil (CircleAvatar + NetworkImage, fallback ikon person)
//     Tap → EditProfilePage
//   - displayName + email
//   - Row statistik: total mood entries | total jurnal | total sesi meditasi
//     (ambil dari jumlah list di masing-masing provider)
//   - ListTile "Notifikasi" → toggle switch (update Firestore preferences)
//   - ListTile "Edit Profil" → EditProfilePage
//   - ListTile "Keluar" (warna merah) → konfirmasi → AuthProvider.signOut() → LoginPage
//
// Provider: AuthProvider, MoodProvider, JournalProvider, MeditationProvider

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile — TODO')),
    );
  }
}

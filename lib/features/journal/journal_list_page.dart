import 'package:flutter/material.dart';

// TODO [Anggota 1 — Journaling]: Halaman list jurnal / Tab 2
//
// Tampilan:
//   - AppBar dengan search bar (TextField) di bagian bawah
//   - Icon filter → BottomSheet JournalFilterWidget
//   - ListView kartu jurnal: kategori chip + judul + cuplikan isi + tanggal relatif
//   - FAB icon pensil → navigasi ke JournalFormPage (create baru)
//   - Empty state jika belum ada jurnal
//
// Logika:
//   - initState: panggil JournalProvider.listenJournals(uid)
//   - Search: panggil JournalProvider.setSearch(query)
//   - Filter: panggil JournalProvider.setFilter(category)
//   - Tap kartu → navigasi ke JournalDetailPage dengan argument JournalModel
//
// Provider: AuthProvider, JournalProvider
// Semantics identifier: 'addJournalButton' (FAB)

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Journal List — TODO')),
    );
  }
}

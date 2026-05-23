import 'package:flutter/material.dart';

// TODO [Anggota 1 — Journaling]: Halaman detail jurnal
//
// Menerima argument: JournalModel via ModalRoute.settings.arguments
//
// Tampilan:
//   - AppBar: icon edit → JournalFormPage(argument: journal), icon hapus (merah)
//   - Chip kategori + tanggal dibuat + tanggal diperbarui (jika beda)
//   - Judul besar (fontSize 24, bold)
//   - Image.network jika imageUrl ada (rounded, height 200)
//   - Teks isi jurnal (height 1.7)
//   - Wrap chip tags di bawah
//
// Logika:
//   - Delete: showDialog konfirmasi → JournalProvider.deleteJournal(id) → Navigator.pop

class JournalDetailPage extends StatelessWidget {
  const JournalDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Journal Detail — TODO')),
    );
  }
}

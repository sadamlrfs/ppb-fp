import 'package:flutter/material.dart';

// TODO [Anggota 1 — Journaling]: Form tulis/edit jurnal
//
// Menerima argument opsional: JournalModel (null = create baru, ada = edit)
//
// Tampilan:
//   - AppBar dengan tombol "Simpan" (TextButton di actions)
//   - TextField judul (tanpa border, style bold besar)
//   - Row ChoiceChip untuk pilih kategori (gratitude, refleksi, kekhawatiran, lainnya)
//   - TextField isi jurnal (maxLines: null, minLines: 10)
//   - Row input tag + tombol +, lalu Wrap chip tag
//   - OutlinedButton "Tambah Gambar" → ImagePicker.gallery → upload via CloudinaryService
//
// Logika:
//   - Create: JournalProvider.createJournal(userId, title, content, category, tags, imagePath?)
//   - Edit: JournalProvider.updateJournal(journal, imagePath?)
//   - Setelah berhasil: Navigator.pop(context)

class JournalFormPage extends StatefulWidget {
  const JournalFormPage({super.key});

  @override
  State<JournalFormPage> createState() => _JournalFormPageState();
}

class _JournalFormPageState extends State<JournalFormPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Journal Form — TODO')),
    );
  }
}

import 'package:flutter/material.dart';

// TODO [Anggota 1 — Journaling]: BottomSheet filter kategori jurnal
//
// Props:
//   - String? selected  — kategori yang sedang aktif (null = semua)
//   - ValueChanged<String?> onSelected  — callback saat user memilih
//
// Tampilan:
//   - Judul "Filter Kategori"
//   - ListTile + Radio untuk "Semua" (value: null)
//   - ListTile + Radio untuk tiap JournalCategory.values
//   - Setelah pilih: panggil onSelected(value) lalu Navigator.pop(context)

class JournalFilterWidget extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const JournalFilterWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implementasi filter widget
    return const SizedBox(height: 200, child: Center(child: Text('Filter — TODO')));
  }
}

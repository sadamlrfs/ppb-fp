import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/journal_model.dart';
import '../../providers/journal_provider.dart';

class JournalDetailPage extends StatelessWidget {
  const JournalDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final journal =
        ModalRoute.of(context)!.settings.arguments as JournalModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jurnal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
                context, AppRoutes.journalForm,
                arguments: journal),
          ),
          IconButton(
            icon:
                const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, journal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(journal.category.label,
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
                const SizedBox(width: 8),
                Text(DateFormatter.toDisplay(journal.createdAt),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(journal.title,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (journal.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  journal.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(journal.content,
                style: const TextStyle(fontSize: 15, height: 1.7)),
            if (journal.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 6,
                children: journal.tags
                    .map((t) => Chip(
                          label: Text(t,
                              style: const TextStyle(fontSize: 12)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
            if (journal.updatedAt != journal.createdAt) ...[
              const SizedBox(height: 16),
              Text(
                  'Diperbarui: ${DateFormatter.toDisplay(journal.updatedAt)}',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, JournalModel journal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jurnal?'),
        content: const Text('Jurnal ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<JournalProvider>().deleteJournal(journal.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

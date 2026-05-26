import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/mood_model.dart';
import '../../providers/mood_provider.dart';

class MoodDetailPage extends StatelessWidget {
  const MoodDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = ModalRoute.of(context)!.settings.arguments as MoodModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.moodInput,
              arguments: mood,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, mood),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(mood.emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(mood.label,
                style: TextStyle(
                    color: mood.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(DateFormatter.toDisplayWithTime(mood.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 32),
            if (mood.note.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(mood.note,
                        style: const TextStyle(fontSize: 15, height: 1.6)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MoodModel mood) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Mood?'),
        content: const Text('Catatan mood ini akan dihapus permanen.'),
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
      await context.read<MoodProvider>().deleteMood(mood.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

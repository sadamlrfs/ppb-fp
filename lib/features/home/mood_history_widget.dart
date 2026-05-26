import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/mood_model.dart';

class MoodHistoryWidget extends StatelessWidget {
  final List<MoodModel> moods;

  const MoodHistoryWidget({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Belum ada riwayat mood',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: moods
          .map((m) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.moodDetail,
                      arguments: m),
                  leading: Text(m.emoji,
                      style: const TextStyle(fontSize: 28)),
                  title: Text(m.label,
                      style: TextStyle(
                          color: m.color, fontWeight: FontWeight.w600)),
                  subtitle: m.note.isNotEmpty
                      ? Text(m.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  trailing: Text(
                    DateFormatter.toRelative(m.createdAt),
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

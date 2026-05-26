import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/user_session_model.dart';
import '../../providers/meditation_provider.dart';

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MeditationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Sesi')),
      body: prov.userSessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat sesi',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prov.userSessions.length,
              itemBuilder: (_, i) {
                final us = prov.userSessions[i];
                final session = prov.getSessionById(us.sessionId);
                return _HistoryCard(
                  userSession: us,
                  sessionTitle: session?.title ?? 'Sesi tidak ditemukan',
                  onEdit: () => _showEditDialog(context, us, prov),
                  onDelete: () => _confirmDelete(context, us.id, prov),
                );
              },
            ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, UserSessionModel us,
      MeditationProvider prov) async {
    int rating = us.rating;
    final noteCtrl = TextEditingController(text: us.note ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Edit Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setSt(() => rating = i + 1),
                  ),
                ),
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                await prov.updateUserSession(us.copyWith(
                  rating: rating,
                  note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, MeditationProvider prov) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Riwayat sesi ini akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await prov.deleteUserSession(id);
  }
}

class _HistoryCard extends StatelessWidget {
  final UserSessionModel userSession;
  final String sessionTitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.userSession,
    required this.sessionTitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading:
            const Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text(sessionTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormatter.toDisplay(userSession.completedAt),
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            if (userSession.note != null && userSession.note!.isNotEmpty)
              Text(userSession.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              5,
              (i) => Icon(
                i < userSession.rating ? Icons.star : Icons.star_border,
                size: 14,
                color: Colors.amber,
              ),
            ),
            PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus',
                        style: TextStyle(color: Colors.red))),
              ],
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

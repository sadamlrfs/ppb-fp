import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  Future<void> _newChat(BuildContext context) async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final prov = context.read<ChatProvider>();
    final id = await prov.createConversation(uid);
    if (context.mounted) {
      Navigator.pushNamed(context, AppRoutes.chatRoom, arguments: id);
    }
  }

  Future<void> _showRenameDialog(
      BuildContext context, String id, String current) async {
    final ctrl = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Nama'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Nama percakapan'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ChatProvider>().renameConversation(id, ctrl.text.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Percakapan?'),
        content: const Text('Semua pesan akan dihapus permanen.'),
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
      context.read<ChatProvider>().deleteConversation(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final convs = context.watch<ChatProvider>().conversations;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MindEase AI bukan pengganti psikolog profesional. Hubungi tenaga ahli jika diperlukan.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: convs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Belum ada percakapan',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _newChat(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Mulai Chat Baru'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: convs.length,
                  itemBuilder: (_, i) {
                    final c = convs[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.spa,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(c.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          DateFormatter.toRelative(c.updatedAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.chatRoom,
                            arguments: c.id),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'rename',
                                child: Text('Ganti Nama')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus',
                                    style:
                                        TextStyle(color: Colors.red))),
                          ],
                          onSelected: (v) {
                            if (v == 'rename') {
                              _showRenameDialog(context, c.id, c.title);
                            } else if (v == 'delete') {
                              _confirmDelete(context, c.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Semantics(
            identifier: 'newChatButton',
            child: FloatingActionButton.extended(
              heroTag: 'newChatFAB',
              onPressed: () => _newChat(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat Baru'),
            ),
          ),
        ),
      ],
    );
  }
}

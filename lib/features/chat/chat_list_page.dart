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
        // Voice session card
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.voiceSession),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesi Suara dengan AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bicara langsung dan curhat dengan AI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
        // Disclaimer
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MindEase AI bukan pengganti psikolog profesional. Hubungi tenaga ahli jika diperlukan.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
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
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Image.asset(
                            'assets/images/logo_mark.png',
                            width: 20,
                            height: 20,
                            color: Colors.white,
                            colorBlendMode: BlendMode.srcIn,
                          ),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.primary,
          child: Semantics(
            identifier: 'newChatButton',
            child: ElevatedButton.icon(
              onPressed: () => _newChat(context),
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Colors.white),
              label: const Text('Chat Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

// TODO [Anggota 3 — AI Chat]: Daftar percakapan dengan AI
//
// Tampilan:
//   - Banner disclaimer: "MindEase AI bukan pengganti psikolog profesional"
//   - ListView Card percakapan: judul + tanggal update relatif
//   - PopupMenuButton per item: "Rename" (dialog input) | "Hapus"
//   - FAB icon chat_bubble → buat percakapan baru
//   - Empty state jika conversations kosong
//
// Logika:
//   - Buat baru: ChatProvider.createConversation(uid) → dapat conversationId
//     → navigasi ke ChatRoomPage dengan argument conversationId
//   - Rename: ChatProvider.renameConversation(id, newTitle)
//   - Delete: konfirmasi dialog → ChatProvider.deleteConversation(id)
//
// Provider: AuthProvider, ChatProvider
// Semantics identifier: 'newChatButton' (FAB)

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chat List — TODO'));
  }
}

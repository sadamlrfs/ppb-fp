import 'package:flutter/material.dart';

// TODO [Anggota 3 — AI Chat]: Halaman ruang chat dengan Gemini AI
//
// Menerima argument: String conversationId via ModalRoute.settings.arguments
//
// Tampilan:
//   - AppBar dengan judul percakapan
//   - ListView pesan (bawah ke atas / reverse: true):
//       tiap pesan → ChatBubbleWidget(message)
//   - Indicator "mengetik..." (animated dots) saat ChatProvider.sending == true
//   - TextField input + tombol kirim di bawah
//
// Logika:
//   - initState: ChatProvider.listenMessages(conversationId)
//   - Kirim: ChatProvider.sendMessage(conversationId, content)
//   - dispose: ChatProvider.clearMessages()
//
// Provider: ChatProvider

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chat Room — TODO')),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';

// TODO [Anggota 3 — AI Chat]: Widget gelembung chat
//
// Props: ChatMessageModel message
//
// Tampilan berdasarkan message.isUser:
//   User  → bubble rata kanan, warna AppColors.primary, teks putih
//   AI    → bubble rata kiri, warna putih / abu, teks gelap + avatar ikon spa
//
// Tambahkan timestamp kecil di bawah setiap bubble (DateFormatter.toTime)

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // TODO: implementasi bubble dengan alignment berbeda untuk user vs AI
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.purple.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message.content),
        ),
      ),
    );
  }
}

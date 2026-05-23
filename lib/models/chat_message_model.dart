import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant }

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}

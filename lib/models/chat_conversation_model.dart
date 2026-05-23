import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationModel {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatConversationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Percakapan Baru',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  ChatConversationModel copyWith({String? title, DateTime? updatedAt}) =>
      ChatConversationModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

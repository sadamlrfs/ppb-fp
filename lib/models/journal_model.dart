import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalCategory { gratitude, refleksi, kekhawatiran, lainnya }

extension JournalCategoryX on JournalCategory {
  String get label {
    switch (this) {
      case JournalCategory.gratitude:
        return 'Gratitude';
      case JournalCategory.refleksi:
        return 'Refleksi';
      case JournalCategory.kekhawatiran:
        return 'Kekhawatiran';
      case JournalCategory.lainnya:
        return 'Lainnya';
    }
  }
}

class JournalModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final JournalCategory category;
  final List<String> tags;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalModel.fromMap(Map<String, dynamic> map, String id) {
    return JournalModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: JournalCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => JournalCategory.lainnya,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'content': content,
        'category': category.name,
        'tags': tags,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  JournalModel copyWith({
    String? title,
    String? content,
    JournalCategory? category,
    List<String>? tags,
    String? imageUrl,
  }) =>
      JournalModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

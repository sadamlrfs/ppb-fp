import 'package:cloud_firestore/cloud_firestore.dart';

class UserSessionModel {
  final String id;
  final String userId;
  final String sessionId;
  final DateTime completedAt;
  final int rating; // 1–5
  final String? note;

  const UserSessionModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.completedAt,
    required this.rating,
    this.note,
  });

  factory UserSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return UserSessionModel(
      id: id,
      userId: map['userId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      completedAt:
          (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: map['rating'] ?? 3,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'sessionId': sessionId,
        'completedAt': Timestamp.fromDate(completedAt),
        'rating': rating,
        'note': note,
      };

  UserSessionModel copyWith({int? rating, String? note}) => UserSessionModel(
        id: id,
        userId: userId,
        sessionId: sessionId,
        completedAt: completedAt,
        rating: rating ?? this.rating,
        note: note ?? this.note,
      );
}

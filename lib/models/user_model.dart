import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String fcmToken;
  final DateTime createdAt;
  final bool notificationsEnabled;
  final String reminderTime;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.fcmToken = '',
    required this.createdAt,
    this.notificationsEnabled = true,
    this.reminderTime = '20:00',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationsEnabled: map['preferences']?['notifications'] ?? true,
      reminderTime: map['preferences']?['reminderTime'] ?? '20:00',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken,
        'createdAt': Timestamp.fromDate(createdAt),
        'preferences': {
          'notifications': notificationsEnabled,
          'reminderTime': reminderTime,
        },
      };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    bool? notificationsEnabled,
    String? reminderTime,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        reminderTime: reminderTime ?? this.reminderTime,
      );
}

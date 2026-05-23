import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_colors.dart';

class MoodModel {
  final String id;
  final String userId;
  final int moodLevel; // 1–5
  final String emoji;
  final String note;
  final DateTime createdAt;
  final String date; // YYYY-MM-DD

  const MoodModel({
    required this.id,
    required this.userId,
    required this.moodLevel,
    required this.emoji,
    this.note = '',
    required this.createdAt,
    required this.date,
  });

  static const emojis = ['😢', '😕', '😐', '😊', '😄'];
  static const labels = [
    'Sangat Buruk',
    'Buruk',
    'Biasa',
    'Baik',
    'Sangat Baik'
  ];

  String get label => labels[moodLevel - 1];

  Color get color {
    switch (moodLevel) {
      case 1:
        return AppColors.mood1;
      case 2:
        return AppColors.mood2;
      case 3:
        return AppColors.mood3;
      case 4:
        return AppColors.mood4;
      case 5:
        return AppColors.mood5;
      default:
        return AppColors.mood3;
    }
  }

  factory MoodModel.fromMap(Map<String, dynamic> map, String id) {
    return MoodModel(
      id: id,
      userId: map['userId'] ?? '',
      moodLevel: map['moodLevel'] ?? 3,
      emoji: map['emoji'] ?? '😐',
      note: map['note'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'moodLevel': moodLevel,
        'emoji': emoji,
        'note': note,
        'createdAt': Timestamp.fromDate(createdAt),
        'date': date,
      };

  MoodModel copyWith({int? moodLevel, String? emoji, String? note}) =>
      MoodModel(
        id: id,
        userId: userId,
        moodLevel: moodLevel ?? this.moodLevel,
        emoji: emoji ?? this.emoji,
        note: note ?? this.note,
        createdAt: createdAt,
        date: date,
      );
}

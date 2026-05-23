import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_model.dart';
import '../core/utils/date_formatter.dart';

class MoodProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<MoodModel> _moods = [];
  bool _loading = false;
  String? _error;

  List<MoodModel> get moods => _moods;
  bool get loading => _loading;
  String? get error => _error;

  MoodModel? get todayMood {
    final today = DateFormatter.toDateOnly(DateTime.now());
    try {
      return _moods.firstWhere((m) => m.date == today);
    } catch (_) {
      return null;
    }
  }

  List<MoodModel> getLast(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _moods.where((m) => m.createdAt.isAfter(cutoff)).toList();
  }

  double get averageMoodLast7Days {
    final list = getLast(7);
    if (list.isEmpty) return 0;
    return list.map((m) => m.moodLevel).reduce((a, b) => a + b) / list.length;
  }

  void listenMoods(String userId) {
    _db
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _moods =
          snap.docs.map((d) => MoodModel.fromMap(d.data(), d.id)).toList();
      notifyListeners();
    });
  }

  Future<bool> createMood({
    required String userId,
    required int moodLevel,
    String note = '',
  }) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      await _db.collection('moods').add(MoodModel(
            id: '',
            userId: userId,
            moodLevel: moodLevel,
            emoji: MoodModel.emojis[moodLevel - 1],
            note: note,
            createdAt: now,
            date: DateFormatter.toDateOnly(now),
          ).toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateMood(MoodModel mood) async {
    try {
      await _db.collection('moods').doc(mood.id).update(mood.toMap());
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMood(String id) async {
    try {
      await _db.collection('moods').doc(id).delete();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

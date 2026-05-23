import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meditation_session_model.dart';
import '../models/user_session_model.dart';

class MeditationProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<MeditationSessionModel> _sessions = [];
  List<UserSessionModel> _userSessions = [];
  bool _loading = false;

  List<MeditationSessionModel> get sessions => _sessions;
  List<UserSessionModel> get userSessions => _userSessions;
  bool get loading => _loading;

  Future<void> loadSessions() async {
    _setLoading(true);
    try {
      final snap = await _db.collection('meditationSessions').get();
      _sessions = snap.docs
          .map((d) => MeditationSessionModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  void listenUserSessions(String userId) {
    _db
        .collection('userSessions')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .listen((snap) {
      _userSessions = snap.docs
          .map((d) => UserSessionModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    });
  }

  MeditationSessionModel? getSessionById(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUserSession({
    required String userId,
    required String sessionId,
    required int rating,
    String? note,
  }) async {
    try {
      await _db.collection('userSessions').add(UserSessionModel(
            id: '',
            userId: userId,
            sessionId: sessionId,
            completedAt: DateTime.now(),
            rating: rating,
            note: note,
          ).toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUserSession(UserSessionModel session) async {
    try {
      await _db
          .collection('userSessions')
          .doc(session.id)
          .update(session.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUserSession(String id) async {
    try {
      await _db.collection('userSessions').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

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
      if (snap.docs.isEmpty) {
        await _seedDefaultSessions();
        final seeded = await _db.collection('meditationSessions').get();
        _sessions = seeded.docs
            .map((d) => MeditationSessionModel.fromMap(d.data(), d.id))
            .toList();
      } else {
        _sessions = snap.docs
            .map((d) => MeditationSessionModel.fromMap(d.data(), d.id))
            .toList();
      }
      notifyListeners();
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _seedDefaultSessions() async {
    final sessions = [
      {
        'title': 'Pernapasan 4-7-8',
        'description':
            'Teknik pernapasan untuk menenangkan pikiran dan mengurangi stres dengan ritme 4-7-8 detik.',
        'duration': 600,
        'audioUrl': '',
        'thumbnailUrl': '',
        'category': 'breathing',
      },
      {
        'title': 'Meditasi Tidur Nyenyak',
        'description':
            'Panduan relaksasi tubuh dari ujung kaki hingga kepala untuk membantu tidur lebih cepat.',
        'duration': 1200,
        'audioUrl': '',
        'thumbnailUrl': '',
        'category': 'sleep',
      },
      {
        'title': 'Fokus & Konsentrasi',
        'description':
            'Meditasi singkat untuk meningkatkan fokus dan kejernihan pikiran sebelum belajar atau bekerja.',
        'duration': 480,
        'audioUrl': '',
        'thumbnailUrl': '',
        'category': 'focus',
      },
      {
        'title': 'Meredakan Kecemasan',
        'description':
            'Latihan grounding 5-4-3-2-1 untuk mengurangi rasa cemas dan membawa kesadaran ke momen ini.',
        'duration': 720,
        'audioUrl': '',
        'thumbnailUrl': '',
        'category': 'anxiety',
      },
      {
        'title': 'Napas Pagi Hari',
        'description':
            'Mulai pagi dengan napas dalam dan niat positif untuk menjalani hari dengan tenang.',
        'duration': 300,
        'audioUrl': '',
        'thumbnailUrl': '',
        'category': 'breathing',
      },
    ];

    final batch = _db.batch();
    for (final s in sessions) {
      batch.set(_db.collection('meditationSessions').doc(), s);
    }
    await batch.commit();
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

  Future<bool> addSession(MeditationSessionModel session) async {
    try {
      await _db.collection('meditationSessions').add(session.toMap());
      await loadSessions();
      return true;
    } catch (_) {
      return false;
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

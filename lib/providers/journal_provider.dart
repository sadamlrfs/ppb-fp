import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_model.dart';
import '../services/cloudinary_service.dart';

class JournalProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryService();

  List<JournalModel> _journals = [];
  bool _loading = false;
  String? _error;
  String? _filterCategory;
  String _searchQuery = '';

  String? _currentUserId;
  StreamSubscription<QuerySnapshot>? _subscription;

  bool get loading => _loading;
  String? get error => _error;
  String? get filterCategory => _filterCategory;

  List<JournalModel> get journals {
    var list = [..._journals];
    if (_filterCategory != null) {
      list = list.where((j) => j.category.name == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((j) =>
              j.title.toLowerCase().contains(q) ||
              j.content.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void setFilter(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void listenJournals(String userId) {
    print('DEBUG: JournalProvider: listenJournals called for userId: "$userId", currentUserId: "$_currentUserId"');
    if (userId.isEmpty) {
      print('DEBUG: JournalProvider: userId is empty, clearing journals.');
      _currentUserId = null;
      _subscription?.cancel();
      _subscription = null;
      _journals = [];
      notifyListeners();
      return;
    }
    if (_currentUserId == userId) {
      print('DEBUG: JournalProvider: already listening to "$userId", skipping subscription.');
      return;
    }

    print('DEBUG: JournalProvider: changing listener from "$_currentUserId" to "$userId"');
    _currentUserId = userId;
    _subscription?.cancel();
    _journals = []; // Clear immediately to avoid showing previous user's data

    _subscription = _db
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snap) {
      print('DEBUG: JournalProvider: received snapshot with ${snap.docs.length} documents.');
      final list = snap.docs.map((d) => JournalModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort locally by createdAt descending
      _journals = list;
      notifyListeners();
    }, onError: (err) {
      print('DEBUG: JournalProvider: Firestore stream error: $err');
    });
  }

  Future<void> fetchJournals(String userId) async {
    if (userId.isEmpty) return;
    try {
      final snap = await _db
          .collection('journals')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map((d) => JournalModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort locally by createdAt descending
      _journals = list;
      notifyListeners();
    } catch (e) {
      print('DEBUG: fetchJournals error: $e');
    }
  }

  Future<bool> createJournal({
    required String userId,
    required String title,
    required String content,
    required JournalCategory category,
    List<String> tags = const [],
    String? imagePath,
  }) async {
    _setLoading(true);
    try {
      String? imageUrl;
      if (imagePath != null) {
        imageUrl = await _cloudinary.uploadImage(imagePath, folder: 'journals');
      }
      final now = DateTime.now();
      await _db.collection('journals').add(JournalModel(
            id: '',
            userId: userId,
            title: title,
            content: content,
            category: category,
            tags: tags,
            imageUrl: imageUrl,
            createdAt: now,
            updatedAt: now,
          ).toMap());
      await fetchJournals(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateJournal(JournalModel journal, {String? imagePath}) async {
    _setLoading(true);
    try {
      var updated = journal;
      if (imagePath != null) {
        final url =
            await _cloudinary.uploadImage(imagePath, folder: 'journals');
        updated = updated.copyWith(imageUrl: url);
      }
      await _db.collection('journals').doc(journal.id).update(updated.toMap());
      await fetchJournals(journal.userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteJournal(String id, String userId) async {
    try {
      await _db.collection('journals').doc(id).delete();
      await fetchJournals(userId);
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

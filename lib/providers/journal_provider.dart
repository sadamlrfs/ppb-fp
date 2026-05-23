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
    _db
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _journals =
          snap.docs.map((d) => JournalModel.fromMap(d.data(), d.id)).toList();
      notifyListeners();
    });
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
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteJournal(String id) async {
    try {
      await _db.collection('journals').doc(id).delete();
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

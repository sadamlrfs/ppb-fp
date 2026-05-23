import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<String> add(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> set(
          String collection, String id, Map<String, dynamic> data) =>
      _db.collection(collection).doc(id).set(data);

  Future<void> update(
          String collection, String id, Map<String, dynamic> data) =>
      _db.collection(collection).doc(id).update(data);

  Future<void> delete(String collection, String id) =>
      _db.collection(collection).doc(id).delete();

  Future<DocumentSnapshot<Map<String, dynamic>>> get(
          String collection, String id) =>
      _db.collection(collection).doc(id).get();

  Stream<QuerySnapshot<Map<String, dynamic>>> stream(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(collection);
    if (whereField != null) q = q.where(whereField, isEqualTo: whereValue);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    if (limit != null) q = q.limit(limit);
    return q.snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAll(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(collection);
    if (whereField != null) q = q.where(whereField, isEqualTo: whereValue);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    return q.get();
  }
}

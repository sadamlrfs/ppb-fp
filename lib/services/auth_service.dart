import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn(
    serverClientId:
        '437913946832-2t9johuuh4nsd95h29qgefti5ckc2n36.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail(
      String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.updateDisplayName(displayName);
    await _createUserDoc(cred.user!, displayName);
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    // 1. Buka picker akun Google
    final account = await _googleSignIn.signIn();
    if (account == null) return null; // user cancel

    // 2. Tukar token Google → kredensial Firebase
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Sign-in ke Firebase Auth (otomatis create akun jika belum ada)
    final cred = await _auth.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return cred;

    // 4. Pastikan dokumen Firestore user ada — buat jika belum
    //    (lebih robust daripada hanya mengandalkan isNewUser, karena
    //    isNewUser tidak akurat saat Firebase Auth user dihapus tapi
    //    Firestore doc tetap, atau sebaliknya)
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      await _createUserDoc(user, user.displayName ?? 'User');
    }

    return cred;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createUserDoc(User user, String displayName) async {
    final model = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(model.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) =>
      _firestore.collection('users').doc(uid).update(data);
}

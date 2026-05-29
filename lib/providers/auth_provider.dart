import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _loading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;

  AuthProvider() {
    _service.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _userModel = await _service.getUserProfile(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _service.signInWithEmail(email, password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
      String email, String password, String displayName) async {
    _setLoading(true);
    try {
      await _service.registerWithEmail(email, password, displayName);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final result = await _service.signInWithGoogle();
      if (result == null) {
        // User cancel picker — bukan error, jangan tampilkan banner
        _clearError();
        return false;
      }
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authError(e.code));
      return false;
    } catch (e) {
      _setError('Gagal masuk dengan Google: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _service.sendPasswordReset(email);
      _clearError();
    } on FirebaseAuthException catch (e) {
      _setError(_authError(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_firebaseUser == null) return;
    _userModel = await _service.getUserProfile(_firebaseUser!.uid);
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() => _error = null;

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Kata sandi salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Kata sandi terlalu lemah';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}

import 'dart:async';
import 'package:employee_management_assessment/framework/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._service) {
    user = _service.currentUser;
    _subscription = _service.authStateChanges.listen((value) {
      user = value;
      notifyListeners();
    });
  }
  final AuthService _service;
  late final StreamSubscription<User?> _subscription;
  User? user;
  bool loading = false;
  String? error;
  bool get isAuthenticated => user != null;
  Future<void> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Authentication failed. Please try again.';
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) => _run(() async {
    await _service.login(email, password);
  });
  Future<void> register(String name, String email, String password) =>
      _run(() async {
        await _service.register(name, email, password);
      });
  Future<void> resetPassword(String email) =>
      _run(() => _service.resetPassword(email));
  Future<void> googleSignIn() => _run(() async {
    await _service.signInWithGoogle();
  });
  Future<void> updateProfile({String? displayName, String? photoURL}) =>
      _run(() async {
        await _service.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        user = _service.currentUser;
      });
  Future<void> logout() => _run(_service.signOut);
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

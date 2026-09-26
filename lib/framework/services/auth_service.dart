import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({required this.firebaseReady});
  final bool firebaseReady;
  FirebaseAuth get _auth {
    if (!firebaseReady) {
      throw StateError(
        'Firebase is not configured. Follow the setup steps in README.md.',
      );
    }
    return FirebaseAuth.instance;
  }

  User? get currentUser =>
      firebaseReady ? FirebaseAuth.instance.currentUser : null;
  Stream<User?> get authStateChanges => firebaseReady
      ? FirebaseAuth.instance.authStateChanges()
      : const Stream.empty();
  Future<UserCredential> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  Future<UserCredential> register(
      String name,
      String email,
      String password,
      ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return credential;
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
  Future<UserCredential> signInWithGoogle() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }
    final tokens = await account.authentication;
    return _auth.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      ),
    );
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    await Future.wait([_auth.signOut(), GoogleSignIn().signOut()]);
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (!firebaseReady) return;
    final u = _auth.currentUser;
    if (u == null) return;
    if (displayName != null) await u.updateDisplayName(displayName.trim());
    if (photoURL != null) await u.updatePhotoURL(photoURL.trim());
    await u.reload();
  }
}

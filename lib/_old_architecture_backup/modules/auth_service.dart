import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }
}

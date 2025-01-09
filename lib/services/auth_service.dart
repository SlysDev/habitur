import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ReactiveServiceMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    listenToReactiveValues([_currentUser]);
    _initAuthStateListener();
  }

  ReactiveValue<User?> _currentUser =
      ReactiveValue<User?>(FirebaseAuth.instance.currentUser);

  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  String? get userId => _currentUser.value?.uid;

  void _initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser.value = user;
      notifyListeners();
    });
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _currentUser.value = credential.user;
      return credential;
    } catch (e, s) {
      throw _handleAuthError(e, s);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Check if user is blocked
      final userDoc =
          await _firestore.collection('users').doc(credential.user?.uid).get();
      final userData = userDoc.data();

      if (userData != null && userData['isBlocked'] == true) {
        await _auth.signOut(); // Sign out the blocked user
        throw FirebaseAuthException(
          code: 'user-blocked',
          message:
              'Your account has been blocked. Please contact support for assistance.',
        );
      }

      _currentUser.value = credential.user;
      return credential;
    } catch (e, s) {
      throw _handleAuthError(e, s);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser.value = null;
    } catch (e, s) {
      throw _handleAuthError(e, s);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      _currentUser.value = null;
    } catch (e, s) {
      throw _handleAuthError(e, s);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      _currentUser.value = _auth.currentUser;
    } catch (e, s) {
      throw _handleAuthError(e, s);
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'firebase_auth/invalid-email':
          throw Exception('Please enter a valid email address.');
        default:
          throw Exception('Failed to send verification email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  Exception _handleAuthError(dynamic error, dynamic stackTrace) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-blocked':
          return Exception(error.message ?? 'Your account has been blocked.');
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('An account already exists with this email.');
        case 'weak-password':
          return Exception('The password provided is too weak.');
        case 'invalid-email':
          return Exception('The email address is not valid.');
        default:
          return Exception('Authentication error: ${error.message}');
      }
    }

    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
    return Exception('An unexpected error occurred');
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/status_service.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _snackbarService = locator<SnackbarService>();
  final _statusService = locator<StatusService>();
  final _authService = locator<AuthService>();

  String _email = '';
  String _password = '';

  void setEmail(String value) {
    _email = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  Future<void> login() async {
    if (_email.isEmpty || _password.isEmpty) {
      _snackbarService.showSnackbar(message: 'Please fill in all fields');
      return;
    }

    try {
      setBusy(true);
      final credential = await _authService.signInWithEmailAndPassword(
        _email,
        _password,
      );

      // Load user data and navigate
      await _userService.loadUser(credential.user!.uid);
      setBusy(false);
      await _navigationService.replaceWith(Routes.homeView);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-blocked':
          message =
              'This account has been blocked. Please contact support for assistance.';
          break;
        case 'user-not-found':
          message = 'No user found for that email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'An error occurred during login';
      }
      throw Exception(message);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  void navigateToRegister() {
    _navigationService.navigateTo(Routes.registerView);
  }
}

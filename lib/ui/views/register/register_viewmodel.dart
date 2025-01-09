import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/status_service.dart';

class RegisterViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _snackbarService = locator<SnackbarService>();
  final _statusService = locator<StatusService>();
  final _authService = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setEmail(String value) => _email = value;
  void setPassword(String value) => _password = value;
  void setConfirmPassword(String value) => _confirmPassword = value;
  void setUsername(String value) => _username = value;

  Future<void> register() async {
    if (_email.isEmpty ||
        _password.isEmpty ||
        _confirmPassword.isEmpty ||
        _username.isEmpty) {
      _snackbarService.showSnackbar(message: 'Please fill in all fields');
      return;
    }

    if (_password != _confirmPassword) {
      _snackbarService.showSnackbar(message: 'Passwords do not match');
      return;
    }

    try {
      setBusy(true);
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Create user model
      final newUser = UserModel(
        username: _username,
        email: _email,
        uid: userCredential.user!.uid,
        bio: '',
        userLevel: 1,
        userXP: 0,
        isAdmin: false,
      );

      // Save user to database
      await _userService.createUser(newUser);
      await _navigationService.replaceWith(Routes.homeView);
      setBusy(false);

      _snackbarService.showCustomSnackBar(
          message: 'Welcome, ${newUser.username}',
          variant: SnackbarType.success);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password must be at least 6 characters long';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      if (e.toString().contains('Username is already taken')) {
        throw Exception(
            'This username is already taken. Please choose another one.');
      } else {
        throw Exception('An unexpected error occurred. Please try again.');
      }
    }
  }

  void navigateToLogin() {
    _navigationService.navigateTo(Routes.loginView);
  }
}

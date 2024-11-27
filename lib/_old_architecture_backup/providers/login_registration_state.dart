import 'package:flutter/material.dart';

class LoginRegistrationState extends ChangeNotifier {
  bool _registerSuccess = true;
  bool _loginSuccess = true;
  String errorMessage = 'Please try again';
  loginFail(e) {
    _loginSuccess = false;
    errorMessage = e;
    notifyListeners();
  }

  registrationFail(e) {
    _registerSuccess = false;
    errorMessage = e;
    notifyListeners();
  }

  get registerSuccess {
    return _registerSuccess;
  }

  get loginSuccess {
    return _loginSuccess;
  }

  void setRegisterSuccess(bool success) {
    _registerSuccess = success;
    notifyListeners();
  }

  void setLoginSuccess(bool success) {
    _loginSuccess = success;
    notifyListeners();
  }
}

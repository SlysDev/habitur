import 'package:flutter/material.dart';

class LoginRegistrationState extends ChangeNotifier {
  bool _registerSuccess = true;
  bool _loginSuccess = true;
  loginFail() {
    _loginSuccess = false;
    notifyListeners();
  }

  registrationFail() {
    _registerSuccess = false;
    notifyListeners();
  }

  get registerSuccess {
    return _registerSuccess;
  }

  get loginSuccess {
    return _loginSuccess;
  }
}

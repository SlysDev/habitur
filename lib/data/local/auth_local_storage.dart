import 'package:flutter/material.dart';
import 'package:habitur/models/user.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class AuthLocalStorage extends ChangeNotifier {
  static const String authBoxKey = 'auth';

  @HiveType(typeId: 0)
  static const String isLoggedInKey = 'isLoggedIn';

  @HiveType(typeId: 1, adapterName: 'UserModelAdapter')
  static const String userStorageKey = 'userData';
  dynamic _authBox;

  Future<void> init() async {
    print('are we initing?');
    if (Hive.isBoxOpen(authBoxKey)) {
      print('authBox is open');
      _authBox = Hive.box(authBoxKey);
    } else {
      print('authBox must be newly opened');
      _authBox = await Hive.openBox(authBoxKey);
    }
  }

  Future<void> close() async {
    await Hive.close();
  }

  Future<void> populateDefaultAuthData() async {
    if (!await isLoggedIn()) {
      await _authBox.put(isLoggedInKey, false);
      await _authBox.put(userStorageKey, null); // Store null for no user data
    }
  }

  Future<bool> isLoggedIn() async {
    return _authBox.containsKey(isLoggedInKey)
        ? _authBox.get(isLoggedInKey) as bool
        : false; // Default to false if key doesn't exist
  }

  Future<void> setLoggedIn(bool loggedIn) async {
    await _authBox.put(isLoggedInKey, loggedIn);
    notifyListeners(); // Notify listeners when login state changes
  }

  Future<void> storeUserData(UserModel user) async {
    await _authBox.put(userStorageKey, user);
  }

  Future<UserModel?> getUserData() async {
    return _authBox.get(userStorageKey);
  }
}

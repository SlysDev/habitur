import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class UserLocalStorage extends ChangeNotifier {
  dynamic _userBox;

  Future<void> init(context) async {
    try {
      if (Hive.isBoxOpen('user')) {
        debugPrint('userBox is open');
        _userBox = Hive.box('user');
      } else {
        debugPrint('userBox must be newly opened');
        _userBox = await Hive.openBox('user');
      }
    } catch (e, s) {
      showErrorSnackbar(context, e, s);
    }
  }

  Future<void> loadData(context) async {
    await init(context); // may need, may not
    if (_userBox.get('currentUser') == null) {
      debugPrint('filling in default user data...');
      currentUser = UserModel(
        username: 'Guest',
        email: 'N/A',
        userLevel: 1,
        userXP: 0,
        uid: 'N/A',
        profilePicture: const AssetImage('assets/images/default-profile.png'),
      );
    }
    if (FirebaseAuth.instance.currentUser != null) {
      debugPrint('auth has something');
      updateUserProperty('uid', FirebaseAuth.instance.currentUser!.uid);
      updateUserProperty(
          'username', FirebaseAuth.instance.currentUser!.displayName);
      // TODO: fix error here; firebase auth is returning null for username
      debugPrint(
          'username is ${FirebaseAuth.instance.currentUser!.displayName}');
      updateUserProperty('email', FirebaseAuth.instance.currentUser!.email);
    }
  }

  Future<void> saveData(context) async {
    try {
      await _userBox.put('currentUser', currentUser);
      await _userBox.put('lastUpdated', DateTime.now());
    } catch (e, s) {
      showErrorSnackbar(context, e, s);
    }
  }

  Future<void> deleteData(context) async {
    try {
      await Hive.deleteBoxFromDisk('user');
    } catch (e, s) {
      showErrorSnackbar(context, e, s);
    }
  }

  Future<void> populateDefaultUserData() async {
    currentUser = UserModel(
      username: 'Guest',
      email: 'N/A',
      userLevel: 1,
      userXP: 0,
      uid: 'N/A',
      profilePicture: const AssetImage('assets/images/default-profile.png'),
    );
  }

  get currentUser {
    return _userBox.get('currentUser');
  }

  set currentUser(value) {
    if (value is UserModel) {
      _userBox.put('currentUser', value).then((value) => _userBox
          .put('lastUpdated', DateTime.now())
          .then((value) => notifyListeners()));
    } else {
      throw Exception("Value must be a UserModel");
    }
  }

  DateTime get lastUpdated {
    return _userBox.get('lastUpdated'); // last updated in 1, user in 0
  }

  void updateUserProperty(String propertyName, dynamic newValue) {
    try {
      final updatedUser = UserModel(
        username: propertyName == "username" ? newValue : currentUser.username,
        email: propertyName == "email" ? newValue : currentUser.email,
        userLevel:
            propertyName == "userLevel" ? newValue : currentUser.userLevel,
        userXP: propertyName == "userXP" ? newValue : currentUser.userXP,
        uid: propertyName == "uid" ? newValue : currentUser.uid,
        stats: propertyName == "stats" ? newValue : currentUser.stats,
        profilePicture: propertyName == "profilePicture"
            ? newValue
            : currentUser.profilePicture,
      );
      currentUser = updatedUser;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
    notifyListeners();
  }

  void updateUserStat(String statName, dynamic newValue, context) {
    final user = _userBox.get('currentUser');
    try {
      user.stats.last.updateStatByName(statName, newValue);
      _userBox.put('currentUser', user);
    } catch (e, s) {
      debugPrint('unsuccessful stat update');
      debugPrint(e.toString());
      debugPrint(s.toString());
      showErrorSnackbar(context, e, s);
    }
    notifyListeners();
  }

  void addUserStatPoint(StatPoint newStat, context) {
    final user = _userBox.get('currentUser');
    try {
      final updatedUser = UserModel(
        username: user.username,
        email: user.email,
        userLevel: user.userLevel,
        userXP: user.userXP,
        uid: user.uid,
        stats: [...user.stats, newStat],
        profilePicture: user.profilePicture,
      );
      currentUser = updatedUser;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showErrorSnackbar(context, e, s);
    }
    notifyListeners();
  }

  void clearStats() {
    final user = _userBox.get('currentUser');
    final updatedUser = UserModel(
      username: user.username,
      email: user.email,
      userLevel: 1,
      userXP: 0,
      uid: user.uid,
      stats: [],
      profilePicture: user.profilePicture,
    );
    currentUser = updatedUser;
    notifyListeners();
  }

  void addHabiturRating({int amount = 10}) {
    updateUserProperty('userXP', currentUser.userXP + amount);
    checkLevelUp();
    notifyListeners();
  }

  void removeHabiturRating({int amount = 10}) {
    if (currentUser.userXP < amount) {
      levelDown();
    }
    if (currentUser.userLevel == 1 && currentUser.userXP < amount) {
      updateUserProperty('userXP', 0);
      return;
    }
    updateUserProperty('userXP', currentUser.userXP - amount);
    checkLevelUp();
    notifyListeners();
  }

  void checkLevelUp() {
    if (currentUser.userXP >= currentUser.levelUpRequirement) {
      levelUp();
    }
  }

  void levelUp() {
    updateUserProperty('userLevel', currentUser.userLevel + 1);
    currentUser.userXP = 0;
    updateUserProperty('userXP', 0);
    notifyListeners();
  }

  void levelDown() {
    if (currentUser.userLevel == 1) {
      return;
    }
    updateUserProperty('userLevel', currentUser.userLevel - 1);
    updateUserProperty('userXP', currentUser.levelUpRequirement);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class UserLocalStorage extends ChangeNotifier {
  dynamic _userBox;

  Future<void> init() async {
    if (Hive.isBoxOpen('user')) {
      print('userBox is open');
      _userBox = Hive.box('user');
    } else {
      print('userBox must be newly opened');
      _userBox = await Hive.openBox('user');
    }
  }

  Future<void> loadData() async {
    await init(); // may need, may not
    if (_userBox.get('currentUser') == null) {
      print('filling in default user data...');
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
      print('auth has something');
      updateUserProperty('uid', FirebaseAuth.instance.currentUser!.uid);
      updateUserProperty(
          'username', FirebaseAuth.instance.currentUser!.displayName);
      print('username is ${FirebaseAuth.instance.currentUser!.displayName}');
      updateUserProperty('email', FirebaseAuth.instance.currentUser!.email);
    }
  }

  Future<void> saveData() async {
    await _userBox.put('currentUser', currentUser);
    await _userBox.put('lastUpdated', DateTime.now());
  }

  Future<void> deleteData() async {
    await Hive.deleteBoxFromDisk('user');
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

  // TODO: Refactor to store summary stats instead of summary stats repo
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
    final updatedUser = UserModel(
      username: propertyName == "username" ? newValue : currentUser.username,
      email: propertyName == "email" ? newValue : currentUser.email,
      userLevel: propertyName == "userLevel" ? newValue : currentUser.userLevel,
      userXP: propertyName == "userXP" ? newValue : currentUser.userXP,
      uid: propertyName == "uid" ? newValue : currentUser.uid,
      stats: propertyName == "stats" ? newValue : currentUser.stats,
      profilePicture: propertyName == "profilePicture"
          ? newValue
          : currentUser.profilePicture,
    );
    currentUser = updatedUser;
    notifyListeners();
  }

  void updateUserStat(String statName, dynamic newValue) {
    final user = _userBox.get('currentUser');
    try {
      user.stats.last.updateStatByName(statName, newValue);
      _userBox.put('currentUser', user);
    } catch (e, s) {
      print('unsuccessful stat update');
      print(e);
      print(s);
    }
    notifyListeners();
  }

  void addUserStatPoint(StatPoint newStat) {
    final user = _userBox.get('currentUser');
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

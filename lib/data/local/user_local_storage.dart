import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/privacy_settings.dart'; // added import

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
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> loadData(context) async {
    await init(context); // may need, may not
    if (_userBox.get('currentUser') == null) {
      debugPrint('filling in default user data...');
      await populateDefaultUserData();
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
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> deleteData(context) async {
    try {
      await Hive.deleteBoxFromDisk('user');
    } catch (e, s) {
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> populateDefaultUserData() async {
    currentUser = UserModel(
      username: 'Guest',
      bio: '',
      email: 'N/A',
      userLevel: 1,
      userXP: 0,
      uid: 'N/A',
      profilePicture: 'assets/images/default-profile.png',
    );
    await _userBox.put('lastUpdated', DateTime.now());
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
    if (_userBox.get('lastUpdated') == null) {
      _userBox.put('lastUpdated', DateTime.now());
    }
    return _userBox.get('lastUpdated'); // last updated in 1, user in 0
  }

  void updateUserProperty(String propertyName, dynamic newValue) {
    try {
      final updatedUser = UserModel(
        username: propertyName == "username" ? newValue : currentUser.username,
        bio: propertyName == "bio" ? newValue : currentUser.bio,
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

  void updateStatByName(String statName, dynamic newValue, context) {
    if (currentUser.stats == null || currentUser.stats!.isEmpty) {
      addNewStat(context);
    }
    
    try {
      currentUser.stats!.last.updateStatByName(statName, newValue);
      debugPrint(
          'just updated stat $statName to ${currentUser.stats!.last.getStatByName(statName)}');
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
    notifyListeners();
  }

  void addNewStat(context) {
    try {
      StatPoint newStat = StatPoint(
        date: DateTime.now(),
        confidenceLevel: 0,
        completions: 0,
        streak: 0,
      );
      currentUser = UserModel(
        username: currentUser.username,
        bio: currentUser.bio,
        email: currentUser.email,
        uid: currentUser.uid,
        userLevel: currentUser.userLevel,
        userXP: currentUser.userXP,
        isAdmin: currentUser.isAdmin,
        stats: [...(currentUser.stats ?? []), newStat],
        profilePicture: currentUser.profilePicture,
        friends: currentUser.friends,
        receivedFriendRequests: currentUser.receivedFriendRequests,
        sentFriendRequests: currentUser.sentFriendRequests,
        habitVisibilitySettings: currentUser.habitVisibilitySettings,
      );
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
    notifyListeners();
  }

  void updateUserStat(String statName, dynamic newValue, context) {
    final user = _userBox.get('currentUser');
    debugPrint(
        'updating stat $statName to $newValue for user ${user.toString()}');
    try {
      user.stats.last.updateStatByName(statName, newValue);
      debugPrint(
          'just updated stat $statName to ${user.stats.last.getStatByName(statName)}');
      _userBox.put('currentUser', user);
    } catch (e, s) {
      debugPrint('unsuccessful stat update');
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
    notifyListeners();
  }

  void addUserStatPoint(BuildContext context, StatPoint newStat) {
    final user = _userBox.get('currentUser');
    try {
      final updatedUser = UserModel(
        username: user.username,
        bio: user.bio,
        email: user.email,
        userLevel: user.userLevel,
        userXP: user.userXP,
        uid: user.uid,
        stats: [...user.stats, newStat],
        profilePicture: user.profilePicture,
        isAdmin: user.isAdmin,
      );
      currentUser = updatedUser;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
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

  Future<void> updatePrivacySettings(PrivacySettings newSettings) async {
    final user = currentUser;
    if (user != null) {
      user.privacySettings = newSettings;
      await _userBox.put('currentUser', user);
      notifyListeners();

      // Update Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'privacySettings': newSettings.toMap()});
      } catch (e) {
        print('Error updating privacy settings in Firestore: $e');
      }
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import '../../models/privacy_settings.dart'; // added import

class UserLocalStorage extends ChangeNotifier {
  dynamic _userBox;

  Future<void> init(context) async {
    try {
      if (!Hive.isBoxOpen('user')) {
        debugPrint('Opening user box...');
        _userBox = await Hive.openBox('user');
        
        debugPrint('\n=== USER BOX INITIAL STATE ===');
        debugPrint('Box opened: ${_userBox.isOpen}');
        debugPrint('Box name: ${_userBox.name}');
        debugPrint('Box length: ${_userBox.length}');
        debugPrint('Box keys: ${_userBox.keys.toList()}');
        
        debugPrint('\nRaw values:');
        for (var key in _userBox.keys) {
          var value = _userBox.get(key);
          debugPrint('Key: $key, Type: ${value.runtimeType}, Value: $value');
        }
        debugPrint('===============================\n');
      }
    } catch (e, s) {
      debugPrint('Error initializing user box: $e');
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> loadData(context) async {
    await init(context);
    debugPrint('\n=== USER BOX DEBUG INFO ===');
    if (_userBox == null) {
      debugPrint('userBox is null!');
    } else {
      debugPrint('Box name: ${_userBox.name}');
      debugPrint('Box length: ${_userBox.length}');
      debugPrint('Box keys: ${_userBox.keys.toList()}');
      
      final user = _userBox.get('currentUser');
      if (user == null) {
        debugPrint('No current user found');
      } else {
        debugPrint('\nCurrent User Info:');
        debugPrint('Username: ${user.username}');
        debugPrint('Email: ${user.email}');
        debugPrint('UID: ${user.uid}');
        debugPrint('Privacy Settings: ${user.privacySettings?.toMap()}');
      }

      final lastUpdate = _userBox.get('lastUpdated');
      debugPrint('\nLast Updated: $lastUpdate');
    }
    debugPrint('===========================\n');

    if (_userBox.get('currentUser') == null) {
      debugPrint('filling in default user data...');
      await populateDefaultUserData();
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
    debugPrint('\n=== Populating Default User Data ===');
    try {
      if (_userBox == null) {
        throw Exception('Cannot populate default data: _userBox is null');
      }

      currentUser = UserModel(
        username: 'Guest',
        bio: '',
        email: 'N/A',
        userLevel: 1,
        userXP: 0,
        uid: 'N/A',
        profilePicture: 'assets/images/default-profile.png',
        privacySettings: PrivacySettings(),
        habitVisibilitySettings: [],
        stats: [], // Initialize empty stats list
        friends: [], // Initialize empty friends list
        receivedFriendRequests: [], // Initialize empty received requests
        sentFriendRequests: [], // Initialize empty sent requests
        isAdmin: false, // Set default admin status
      );

      debugPrint('Created default UserModel:');
      debugPrint('Username: ${currentUser.username}');
      debugPrint('UID: ${currentUser.uid}');
      debugPrint('Privacy Settings: ${currentUser.privacySettings}');
      debugPrint('Friend Requests: ${currentUser.receivedFriendRequests.length} received, ${currentUser.sentFriendRequests.length} sent');

      await _userBox.put('currentUser', currentUser);
      await _userBox.put('lastUpdated', DateTime.now());
      debugPrint('Default data saved to box');
    } catch (e, stackTrace) {
      debugPrint('Error populating default user data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
    debugPrint('=== Default User Data Populated ===\n');
  }

  UserModel get currentUser {
    if (_userBox == null) {
      return UserModel(
        username: 'Guest',
        bio: '',
        email: '',
        uid: 'N/A',
        userLevel: 1,
        userXP: 0,
        isAdmin: false,
        stats: [],
        friends: [],
        receivedFriendRequests: [],
        sentFriendRequests: [],
        profilePicture: 'assets/images/default-profile.png',
        habitVisibilitySettings: [],
        privacySettings: PrivacySettings(),
      );
    }
    final user = _userBox.get('currentUser');
    if (user == null) {
      return UserModel(
        username: 'Guest',
        bio: '',
        email: '',
        uid: 'N/A',
        userLevel: 1,
        userXP: 0,
        isAdmin: false,
        stats: [],
        friends: [],
        receivedFriendRequests: [],
        sentFriendRequests: [],
        profilePicture: 'assets/images/default-profile.png',
        habitVisibilitySettings: [],
        privacySettings: PrivacySettings(),
      );
    }
    return user;
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
    if (_userBox == null) {
      return DateTime.now();  // Return current time if box isn't initialized
    }
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
        privacySettings: propertyName == "privacySettings" 
            ? newValue 
            : currentUser.privacySettings,
        friends: currentUser.friends,
        habitVisibilitySettings: currentUser.habitVisibilitySettings,
      );
      
      debugPrint('Updating local user property: $propertyName');
      debugPrint('New value: $newValue');
      
      currentUser = updatedUser;
    } catch (e, s) {
      debugPrint('Error updating user property locally: $e');
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
    }
  }

  Future<void> clearData() async {
    debugPrint('\n=== Clearing User Data ===');
    try {
      if (_userBox != null) {
        await _userBox.clear();
        debugPrint('User box cleared');
        await populateDefaultUserData();
        debugPrint('Default user data populated');
      } else {
        debugPrint('Warning: _userBox is null during clearData()');
      }
    } catch (e, stackTrace) {
      debugPrint('Error clearing user data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
    debugPrint('=== User Data Cleared ===\n');
  }

  Future<void> updateUserStats(Map<String, dynamic> updates, BuildContext context) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (currentUser.stats == null || currentUser.stats!.isEmpty) return;

      // Find current day index
      final now = updates['date'] as DateTime? ?? DateTime.now();
      final currentDayIndex = currentUser.stats!.indexWhere((stat) =>
          stat.date.year == now.year &&
          stat.date.month == now.month &&
          stat.date.day == now.day);

      if (currentDayIndex == -1) return;

      // Apply all updates in a single batch
      updates.forEach((key, value) {
        switch (key) {
          case 'completions':
            currentUser.stats![currentDayIndex].completions = value as int;
            break;
          case 'confidenceLevel':
            currentUser.stats![currentDayIndex].confidenceLevel = value as double;
            break;
          case 'streak':
            currentUser.stats![currentDayIndex].streak = value as int;
            break;
          case 'consistencyFactor':
            currentUser.stats![currentDayIndex].consistencyFactor = value as double;
            break;
          case 'difficultyRating':
            currentUser.stats![currentDayIndex].difficultyRating = value as double;
            break;
          case 'slopeCompletions':
            currentUser.stats![currentDayIndex].slopeCompletions = value as double;
            break;
          case 'slopeConsistency':
            currentUser.stats![currentDayIndex].slopeConsistency = value as double;
            break;
          case 'slopeConfidenceLevel':
            currentUser.stats![currentDayIndex].slopeConfidenceLevel = value as double;
            break;
          case 'slopeDifficultyRating':
            currentUser.stats![currentDayIndex].slopeDifficultyRating = value as double;
            break;
        }
      });

      notifyListeners();
      debugPrint('Batch user stats update took: ${stopwatch.elapsedMilliseconds}ms');
    } finally {
      stopwatch.stop();
    }
  }
}

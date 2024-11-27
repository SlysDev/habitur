import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/setting.dart';

class LocalStorageService with ListenableServiceMixin {
  Box? _userBox;
  Box? _habitsBox;
  Box? _settingsBox;

  Future<void> init() async {
    await _initHive();
    await _migrateDataIfNeeded();
  }

  Future<void> _initHive() async {
if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);
  }
Hive
    ..registerAdapter(HabitAdapter())
    ..registerAdapter(StatPointAdapter())
    ..registerAdapter(SettingModelAdapter())
    ..registerAdapter(TimeModelAdapter())
    ..registerAdapter(HabitVisibilityAdapter())
    ..registerAdapter(PrivacySettingsAdapter())
    ..registerAdapter(SharingScopeAdapter())
    ..registerAdapter(FriendRequestAdapter())
    ..registerAdapter(UserModelAdapter());
    try {
      if (!Hive.isBoxOpen('user')) {
        _userBox = await Hive.openBox('user');
        _debugPrintBoxInfo(_userBox!, 'USER');
      }

      if (!Hive.isBoxOpen('habits')) {
        _habitsBox = await Hive.openBox('habits');
        _debugPrintBoxInfo(_habitsBox!, 'HABITS');
      }

      if (!Hive.isBoxOpen('settings')) {
        _settingsBox = await Hive.openBox('settings');
        _debugPrintBoxInfo(_settingsBox!, 'SETTINGS');
      }
    } catch (e, s) {
      debugPrint('Error initializing Hive boxes: $e');
      debugPrint(s.toString());
    }
  }

  Future<void> _migrateDataIfNeeded() async {
    final currentVersion = await getValue('data_version') ?? 0;

    if (currentVersion < 1) {
      // Migrate to version 1
      await _migrateToVersion1();
      await setValue('data_version', 1);
    }
  }

  Future<void> _migrateToVersion1() async {
    try {
      final habitsBox = Hive.box<Habit>('habits');

      // Create backup of current data
      final habitBackups =
          habitsBox.values.map((habit) => habit.toMap()).toList();
      await setValue('habits_backup_v0', habitBackups);

      // Clear and update data
      await habitsBox.clear();

      // Migrate each habit with new format
      for (var habitData in habitBackups) {
        final resetPeriod =
            (habitData['resetPeriod'] as String?)?.toLowerCase() ?? 'daily';
        habitData['resetPeriod'] = resetPeriod;

        final habit = Habit.fromMap(habitData);
        await habitsBox.add(habit);
      }

      print('Successfully migrated habits to version 1');
    } catch (e) {
      print('Error during migration: $e');
      // Restore from backup if needed
      final backup = await getValue('habits_backup_v0');
      if (backup != null) {
        final habitsBox = Hive.box<Habit>('habits');
        await habitsBox.clear();
        for (var habitData in backup) {
          await habitsBox.add(Habit.fromMap(habitData));
        }
      }
      rethrow;
    }
  }

  void _debugPrintBoxInfo(Box box, String boxName) {
    debugPrint('\n=== $boxName BOX INITIAL STATE ===');
    debugPrint('Box opened: ${box.isOpen}');
    debugPrint('Box name: ${box.name}');
    debugPrint('Box length: ${box.length}');
    debugPrint('Box keys: ${box.keys.toList()}');

    debugPrint('\nRaw values:');
    for (var key in box.keys) {
      var value = box.get(key);
      debugPrint('Key: $key, Type: ${value.runtimeType}, Value: $value');
    }
    debugPrint('===============================\n');
  }

  // User Methods
  Future<UserModel?> getCurrentUser() async {
    await _ensureBoxOpen('user');
    return _userBox?.get('currentUser');
  }

  Future<void> setCurrentUser(UserModel user) async {
    await _ensureBoxOpen('user');
    await _userBox?.put('currentUser', user);
  }

  Future<void> updateUserStat(String statName, double value) async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user != null && user.stats != null) {
      int todayIndex = user.stats!.indexWhere((stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day);

      if (todayIndex != -1) {
        StatPoint updatedStat = user.stats![todayIndex];
        switch (statName) {
          case 'completions':
            updatedStat.completions = value.toInt();
            break;
          case 'confidenceLevel':
            updatedStat.confidenceLevel = value;
            break;
          case 'streak':
            updatedStat.streak = value.toInt();
            break;
          case 'consistencyFactor':
            updatedStat.consistencyFactor = value;
            break;
          case 'difficultyRating':
            updatedStat.difficultyRating = value;
            break;
        }
        user.stats![todayIndex] = updatedStat;
        await setCurrentUser(user);
      }
    }
  }

  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user != null && user.stats != null) {
      int todayIndex = user.stats!.indexWhere((stat) =>
          stat.date.year == DateTime.now().year &&
          stat.date.month == DateTime.now().month &&
          stat.date.day == DateTime.now().day);

      if (todayIndex != -1) {
        StatPoint updatedStat = user.stats![todayIndex];
        stats.forEach((key, value) {
          switch (key) {
            case 'completions':
              updatedStat.completions = value;
              break;
            case 'confidenceLevel':
              updatedStat.confidenceLevel = value;
              break;
            case 'streak':
              updatedStat.streak = value;
              break;
            case 'consistencyFactor':
              updatedStat.consistencyFactor = value;
              break;
            case 'difficultyRating':
              updatedStat.difficultyRating = value;
              break;
            case 'slopeCompletions':
              updatedStat.slopeCompletions = value;
              break;
            case 'slopeConsistency':
              updatedStat.slopeConsistency = value;
              break;
            case 'slopeConfidenceLevel':
              updatedStat.slopeConfidenceLevel = value;
              break;
            case 'slopeDifficultyRating':
              updatedStat.slopeDifficultyRating = value;
              break;
          }
        });
        user.stats![todayIndex] = updatedStat;
        await setCurrentUser(user);
      }
    }
  }

  Future<void> addNewUserStat() async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user != null) {
      if (user.stats == null) {
        user.stats = [];
      }
      user.stats!.add(StatPoint(
        date: DateTime.now(),
        confidenceLevel: 0,
        completions: 0,
        streak: 0,
      ));
      await setCurrentUser(user);
    }
  }

  Future<void> updateAllStats(List<StatPoint> stats) async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user != null) {
      user.stats = stats;
      await setCurrentUser(user);
    }
  }

  // Habits Methods
  Future<List<Habit>> getHabits() async {
    await _ensureBoxOpen('habits');
    final habitsData = _habitsBox?.get('habits');
    return habitsData?.cast<Habit>() ?? [];
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _ensureBoxOpen('habits');
    await _habitsBox?.put('habits', habits);
  }

  // Settings Methods
  Future<PrivacySettings?> getPrivacySettings() async {
    await _ensureBoxOpen('settings');
    return _settingsBox?.get('privacy_settings');
  }

  Future<void> savePrivacySettings(PrivacySettings settings) async {
    await _ensureBoxOpen('settings');
    await _settingsBox?.put('privacy_settings', settings);
  }

  // Settings Operations
  Future<List<SettingModel>> getSettings() async {
    await _ensureBoxOpen('settings');
    final Map<dynamic, dynamic>? settingsMap = _settingsBox?.get('settings');
    if (settingsMap == null) return [];

    return settingsMap.entries
        .map<SettingModel>((e) => SettingModel.fromMap({e.key: e.value}))
        .toList();
  }

  Future<void> saveSettings(List<SettingModel> settings) async {
    await _ensureBoxOpen('settings');
    final Map<String, dynamic> settingsMap = {};
    for (var setting in settings) {
      settingsMap[setting.settingName] = setting.settingValue;
    }
    await _settingsBox?.put('settings', settingsMap);
    await setSettingsLastUpdated(DateTime.now());
  }

  // Last updated getters
  Future<DateTime?> get habitsLastUpdated async {
    await _ensureBoxOpen('habits');
    return _habitsBox?.get('lastUpdated') as DateTime?;
  }

  Future<DateTime?> get settingsLastUpdated async {
    await _ensureBoxOpen('settings');
    return _settingsBox?.get('lastUpdated') as DateTime?;
  }

  // Last updated setters
  Future<void> setHabitsLastUpdated(DateTime dateTime) async {
    await _ensureBoxOpen('habits');
    await _habitsBox?.put('lastUpdated', dateTime);
  }

  Future<void> setSettingsLastUpdated(DateTime dateTime) async {
    await _ensureBoxOpen('settings');
    await _settingsBox?.put('lastUpdated', dateTime);
  }

  // Helper Methods
  Future<void> _ensureBoxOpen(String boxName) async {
    switch (boxName) {
      case 'user':
        if (_userBox == null || !_userBox!.isOpen) {
          _userBox = await Hive.openBox('user');
        }
        break;
      case 'habits':
        if (_habitsBox == null || !_habitsBox!.isOpen) {
          _habitsBox = await Hive.openBox('habits');
        }
        break;
      case 'settings':
        if (_settingsBox == null || !_settingsBox!.isOpen) {
          _settingsBox = await Hive.openBox('settings');
        }
        break;
    }
  }

  Future<void> clearAllData() async {
    await _userBox?.clear();
    await _habitsBox?.clear();
    await _settingsBox?.clear();
  }

  Future<dynamic> getValue(String key) async {
    await _ensureBoxOpen('settings');
    return _settingsBox?.get(key);
  }

  Future<void> setValue(String key, dynamic value) async {
    await _ensureBoxOpen('settings');
    await _settingsBox?.put(key, value);
  }
}

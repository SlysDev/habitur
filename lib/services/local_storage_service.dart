import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;

class LocalStorageService with ListenableServiceMixin {
  Box? _userBox;
  Box? _habitsBox;
  Box? _settingsBox;

  Future<void> init() async {
    try {
      await _initHive();
      // Check if we need to clear data due to schema changes
      final needsSchemaUpdate = await getValue('needs_schema_update') ?? true;
      if (needsSchemaUpdate) {
        await _clearHiveData();
        await setValue('needs_schema_update', false);
      }

      await _migrateDataIfNeeded();
    } catch (e) {
      debugPrint('Error initializing Hive boxes: $e');
      // If initialization fails, try clearing data and reinitializing
      await _clearHiveData();
    }
  }

  Future<void> _initHive() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      Directory directory =
          await path_provider.getApplicationDocumentsDirectory();
      await Hive.initFlutter(directory.path);
    }
    if (!Hive.isAdapterRegistered(HabitAdapter().typeId)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(SharedHabitAdapter().typeId)) {
      Hive.registerAdapter(SharedHabitAdapter());
    }
    if (!Hive.isAdapterRegistered(StatPointAdapter().typeId)) {
      Hive.registerAdapter(StatPointAdapter());
    }
    if (!Hive.isAdapterRegistered(SettingModelAdapter().typeId)) {
      Hive.registerAdapter(SettingModelAdapter());
    }
    if (!Hive.isAdapterRegistered(TimeModelAdapter().typeId)) {
      Hive.registerAdapter(TimeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HabitVisibilityAdapter().typeId)) {
      Hive.registerAdapter(HabitVisibilityAdapter());
    }
    if (!Hive.isAdapterRegistered(PrivacySettingsAdapter().typeId)) {
      Hive.registerAdapter(PrivacySettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(SharingScopeAdapter().typeId)) {
      Hive.registerAdapter(SharingScopeAdapter());
    }
    if (!Hive.isAdapterRegistered(FriendRequestAdapter().typeId)) {
      Hive.registerAdapter(FriendRequestAdapter());
    }
    if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }
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
    try {
      final version = await getValue('data_version') ?? 0;
      if (version < 1) {
        await _migrateToVersion1();
        await setValue('data_version', 1);
      }
      if (version < 2) {
        await _migrateToVersion2();
        await setValue('data_version', 2);
      }
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }

  Future<void> _migrateToVersion1() async {
    try {
      final habitsBox = await Hive.openBox('habits');

      // Create backup of current data
      final habitBackups = habitsBox.values
          .whereType<Habit>()
          .map((habit) => habit.toMap())
          .toList();
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

      await setHabitsLastUpdated(DateTime.now());

      print('Successfully migrated habits to version 1');
    } catch (e) {
      print('Error during migration: $e');
      // Restore from backup if needed
      final backup = await getValue('habits_backup_v0');
      if (backup != null) {
        final habitsBox = Hive.box('habits');
        await habitsBox.clear();
        for (var habitData in backup) {
          await habitsBox.add(Habit.fromMap(habitData));
        }
      }
      rethrow;
    }
  }

  Future<void> _migrateToVersion2() async {
    try {
      final userBox = await Hive.openBox('user');

      // Create backup of current data
      final userBackup = Map<String, dynamic>.from(userBox.toMap());
      await setValue('user_backup_v1', userBackup);

      // Clear the box to prevent type conflicts
      await userBox.clear();

      // Convert old data to new format
      final userData = userBackup.map((key, value) {
        if (value is Map && value.containsKey('privacySettings')) {
          if (value['privacySettings'] is bool) {
            // Convert old boolean privacy setting to new PrivacySettings object
            value['privacySettings'] = PrivacySettings().toMap();
          }
        }
        return MapEntry(key, value);
      });

      // Write back the converted data
      for (var entry in userData.entries) {
        await userBox.put(entry.key, entry.value);
      }

      debugPrint('Successfully migrated user data to version 2');
    } catch (e) {
      debugPrint('Error during user data migration: $e');
      // Restore from backup if needed
      final backup = await getValue('user_backup_v1');
      if (backup != null) {
        debugPrint('Restoring user data from backup...');
        final userBox = await Hive.openBox('user');
        await userBox.clear();
        for (var entry in (backup as Map).entries) {
          await userBox.put(entry.key, entry.value);
        }
      }
    }
  }

  Future<void> clearAllHiveData() async {
    await _clearHiveData();
    await _initHive();
  }

  Future<void> _clearHiveData() async {
    await Hive.deleteFromDisk();
    // try {
    //   if (!kIsWeb) {
    //     final directory =
    //         await path_provider.getApplicationDocumentsDirectory();
    //     final hivePath = '${directory.path}/habitur.hive';
    //     final dir = Directory(hivePath);
    //     if (await dir.exists()) {
    //       await dir.delete(recursive: true);
    //       debugPrint('Cleared Hive data directory');
    //     }
    //   } else {
    //     await Hive.deleteFromDisk();
    //   }
    // } catch (e) {
    // debugPrint('Error clearing Hive data: $e');
    // }
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

  Future<void> updateMostRecentStat(StatPoint stat) async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user == null || user.stats == null) return;
    user.stats.last = stat;
  }

  Future<void> updateUserStats(List<StatPoint> stats) async {
    await _ensureBoxOpen('user');
    UserModel? user = await getCurrentUser();
    if (user != null && user.stats != null) {
      user.stats = stats;
      await setCurrentUser(user);
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
  Future<void> addHabit(HabitInterface habit) async {
    await _habitsBox!.put(habit.id, habit);
    await setSettingsLastUpdated(DateTime.now());
  }

  Future<void> updateHabit(HabitInterface habit) async {
    await _habitsBox!.put(habit.id, habit);
    debugPrint('Updated habit in LS with ID: ${habit.id}');
    debugPrint('Box values after update: ${_habitsBox!.values.toList()}');
    await setHabitsLastUpdated(DateTime.now());
  }

  Future<void> deleteHabit(String habitId) async {
    await _ensureBoxOpen('habits');
    debugPrint('Deleting habit in LS with ID: $habitId');
    final habitIdInt = int.parse(habitId);
    debugPrint('Box keys before deletion: ${_habitsBox!.keys.toList()}');
    await _habitsBox!.delete(habitIdInt);
    debugPrint('Box keys after deletion: ${_habitsBox!.keys.toList()}');
    await setHabitsLastUpdated(DateTime.now());
  }

  List<HabitInterface> getHabitData() {
    try {
      if (_habitsBox == null || !_habitsBox!.isOpen) {
        debugPrint('habitsBox is null or not open');
        return [];
      }

      debugPrint('\n=== HABITS BOX DEBUG INFO ===');
      debugPrint('Box name: ${_habitsBox!.name}');
      debugPrint('Box length: ${_habitsBox!.length}');
      debugPrint('Box keys: ${_habitsBox!.keys.toList()}');

      // Print each habit's basic info
      _habitsBox!.values.whereType<Habit>().forEach((habit) {
        debugPrint(habit.toString());
      });
      debugPrint('===========================\n');

      List<dynamic> allValues = _habitsBox!.values.toList();
      return allValues.whereType<Habit>().toList();
    } catch (e, s) {
      debugPrint('Error in getHabitData: ${e.toString()}');
      debugPrint(s.toString());
      return [];
    }
  }

  Habit? getHabitById(int id) {
    return _habitsBox!.get(id);
  }

  Future<void> clearStats() async {
    for (HabitInterface habit in getHabitData()) {
      HabitInterface clearedHabit = habit;
      clearedHabit.currentProgress = 0;
      clearedHabit.streak = 0;
      clearedHabit.lastSeen = DateTime.now();
      clearedHabit.daysCompleted = [];
      clearedHabit.stats = [];
      clearedHabit.confidenceLevel = 0;
      clearedHabit.highestStreak = 0;
      clearedHabit.totalProgress = 0;

      updateHabit(clearedHabit);
    }
    await setSettingsLastUpdated(DateTime.now());
  }

  Future<void> clearDuplicateHabits() async {
    debugPrint('clearing duplicate habits');
    try {
      List<HabitInterface> allHabits = getHabitData();
      for (HabitInterface habit in allHabits) {
        if (allHabits.where((element) => element.id == habit.id).length > 1) {
          debugPrint('clearing a habit');
          HabitInterface duplicateHabit =
              allHabits.where((element) => element.id == habit.id).first;
          await deleteHabit(duplicateHabit.id.toString());
        }
      } // clears dups
      await setSettingsLastUpdated(DateTime.now());
      saveHabits(allHabits);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  String stringifyHabitData() {
    String output = "";
    output += "----------------------------------\n";
    output += "LS Habits:\n";
    for (HabitInterface habit in getHabitData()) {
      debugPrint(habit.title);
      output += " ${habit.title}:\n";
      output += " -> Completions: ${habit.currentProgress}\n";
      output += " -> Streak: ${habit.streak}\n";
      output += " -> Last seen: ${habit.lastSeen}\n";
      output += " -> Days Completed: ${habit.daysCompleted}\n";
    }
    output += "----------------------------------\n";
    return output;
  }

  Future<void> saveHabits(List<HabitInterface> habits) async {
    await _ensureBoxOpen('habits');
    await _habitsBox!.clear(); // Clear existing habits
    for (var habit in habits) {
      await _habitsBox!.put(habit.id, habit);
    }
    await setHabitsLastUpdated(DateTime.now());
    debugPrint('Saved ${habits.length} habits to local storage');
    debugPrint('Habit IDs: ${habits.map((h) => h.id).toList()}');
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

  Future<void> clearUserData() async {
    try {
      await _habitsBox?.clear();
      await resetSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }

  Future<void> resetSettings() async {
    try {
      final defaultSettings = [
        SettingModel(
          settingValue: true,
          settingName: 'Daily Reminders',
          settingDescription: 'Enable daily reminders',
        ),
        SettingModel(
          settingValue: 3,
          settingName: 'Number of Reminders',
          settingDescription: 'Number of daily reminders',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 10, minute: 0),
          settingName: '1st Reminder Time',
          settingDescription: 'First reminder of the day',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 16, minute: 0),
          settingName: '2nd Reminder Time',
          settingDescription: 'Second reminder of the day',
        ),
        SettingModel(
          settingValue: TimeModel(hour: 22, minute: 0),
          settingName: '3rd Reminder Time',
          settingDescription: 'Third reminder of the day',
        ),
      ];

      await _settingsBox?.clear();
      for (var setting in defaultSettings) {
        await _settingsBox?.put(setting.settingName, setting);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      rethrow;
    }
  }
}

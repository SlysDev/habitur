import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/settings_service.dart';
import 'package:habitur/services/community_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';

import 'sync_service.dart';

class DataService {
  final _habitService = locator<HabitService>();
  final _userService = locator<UserService>();
  final _settingsService = locator<SettingsService>();
  final _communityService = locator<CommunityService>();
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _syncService = locator<SyncService>();

  Future<void> loadAllData({bool forceDbLoad = false}) async {
    debugPrint('\n=== Starting loadAllData() ===');
    debugPrint('forceDbLoad: $forceDbLoad');

    try {
      if (forceDbLoad) {
        debugPrint('Clearing local storage...');
        await _localStorageService.clearAllData();
        debugPrint('Local storage cleared');
      }

      debugPrint('Initializing storage...');
      await _localStorageService.init();
      debugPrint('Storage initialized');

      debugPrint('Loading user data...');
      await _loadUserData(forceDbLoad: forceDbLoad);
      debugPrint('User data loaded');

      debugPrint('Loading habits data...');
      await _loadHabitsData(forceDbLoad: forceDbLoad);
      debugPrint('Habits data loaded');

      debugPrint('Loading settings data...');
      await _loadSettingsData(forceDbLoad: forceDbLoad);
      debugPrint('Settings data loaded');

      debugPrint('Loading community data...');
      await _loadCommunityData();
      debugPrint('Community data loaded');

      debugPrint('=== Data loading complete ===\n');
    } catch (e, stackTrace) {
      debugPrint('\n!!! Error in loadAllData() !!!');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('========================\n');
      rethrow;
    }
  }

  Future<void> _loadUserData({bool forceDbLoad = false}) async {
    if (_authService.isLoggedIn) {
      if (await _shouldLoadFromDb(
          await _syncService.lastUpdated ?? DateTime.now(), forceDbLoad)) {
        await _userService.loadFromRemote();
      } else {
        await _userService.loadFromLocal();
      }
    } else {
      await _userService.loadFromLocal();
    }
  }

  Future<void> _loadHabitsData({bool forceDbLoad = false}) async {
    if (_authService.isLoggedIn) {
      if (await _shouldLoadFromDb(
          await _localStorageService.habitsLastUpdated ?? DateTime.now(),
          forceDbLoad)) {
        await _habitService.loadFromRemote();
      } else {
        await _habitService.loadFromLocal();
      }
    } else {
      await _habitService.loadFromLocal();
    }
  }

  Future<void> _loadSettingsData({bool forceDbLoad = false}) async {
    if (_authService.isLoggedIn) {
      if (await _shouldLoadFromDb(
          await _localStorageService.settingsLastUpdated ?? DateTime.now(),
          forceDbLoad)) {
        await _settingsService.loadFromRemote();
      } else {
        await _settingsService.loadFromLocal();
      }
    } else {
      await _settingsService.loadFromLocal();
    }
  }

  Future<void> _loadCommunityData() async {
    if (_authService.isLoggedIn) {
      await _communityService.loadChallenges();
    }
  }

  Future<bool> _shouldLoadFromDb(
      DateTime localLastUpdated, bool forceDbLoad) async {
    final dbLastUpdated = await _syncService.lastUpdated;
    if (dbLastUpdated == null) return false;
    return forceDbLoad || dbLastUpdated.isAfter(localLastUpdated);
  }
}

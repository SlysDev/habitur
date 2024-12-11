import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:stacked/stacked.dart';

import '../models/user.dart';
import '../models/setting.dart';
import '../constants.dart';
import 'network_service.dart';
import 'user_service.dart';

class SettingsService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _userService = locator<UserService>();
  final _networkService = locator<NetworkService>();

  List<SettingModel> _settings = [];
  List<SettingModel> get settings => _settings;

  SettingsService() {
    listenToReactiveValues([]);
  }

  Future<void> loadSettings() async {
    final isConnected = _networkService.isConnected;
    final futures = <Future<void>>[];

    futures.add(loadFromLocal());
    if (isConnected) {
      futures.add(loadFromRemote());
    }

    await Future.wait(futures);
  }

  Future<void> loadFromRemote() async {
    final String? userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID == null) throw Exception('User ID is null');

    _settings = await _databaseService.getSettings(userID);
    final settingsString =
        _settings.map((s) => '${s.settingName}: ${s.settingValue}').join('\n');
    debugPrint('Settings:\n$settingsString');
    if (_settings.isEmpty) {
      _settings = kDefaultSettings;
    }
    await _localStorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> loadFromLocal() async {
    _settings = await _localStorageService.getSettings();
    if (_settings.isEmpty) {
      _settings = kDefaultSettings;
      await _localStorageService.saveSettings(_settings);
    }
    notifyListeners();
  }

  Future<void> updateSetting(SettingModel setting) async {
    final index =
        _settings.indexWhere((s) => s.settingName == setting.settingName);
    if (index != -1) {
      _settings[index] = setting;
    } else {
      _settings.add(setting);
    }

    await _localStorageService.saveSettings(_settings);
    // update to impl. singular setting function to LS

    final userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID != null) {
      debugPrint('Updating setting for user $userID in DB');
      debugPrint(
          'Setting: ${setting.settingName}, Value: ${setting.settingValue}');
      await _databaseService.updateSetting(userID, setting);
    }

    notifyListeners();
  }

  SettingModel? getSetting(String name) {
    try {
      return _settings.firstWhere((s) => s.settingName == name);
    } catch (e) {
      return null;
    }
  }

  bool getCommunityFeaturesEnabled() {
    final setting = _settings.firstWhere(
      (s) => s.settingName == 'communityFeatures',
      orElse: () =>
          SettingModel(settingName: 'communityFeatures', settingValue: 'true'),
    );
    return setting.settingValue == 'true';
  }

  Future<void> enableCommunityFeatures() async {
    try {
      await updateSetting(
          SettingModel(settingName: 'communityFeatures', settingValue: 'true'));
      debugPrint('Community features enabled');
    } catch (e) {
      debugPrint('Error enabling community features: $e');
    }
  }

  Future<void> disableCommunityFeatures() async {
    try {
      await updateSetting(SettingModel(
          settingName: 'communityFeatures', settingValue: 'false'));
      debugPrint('Community features disabled');
    } catch (e) {
      debugPrint('Error disabling community features: $e');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      // Reset local storage
      await _localStorageService.clearUserData();

      // Reset database
      await _databaseService.clearUserData(userId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
      rethrow;
    }
  }
}

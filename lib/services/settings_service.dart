import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/time_model.dart';
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

  final _settings = ReactiveValue<List<SettingModel>>([]);
  Stream<List<SettingModel>> get settingsStream => _settings.values;
  List<SettingModel> get settings => _settings.value;

  SettingsService() {
    listenToReactiveValues([_settings]);
    debugPrint('SettingsService initialized');
    // Load settings immediately
    loadSettings().then((_) {
      debugPrint('Initial settings loaded: ${_settings.value.length} settings');
    });
  }

  // Add debug helper
  void _logSettings(String context) {
    debugPrint('[$context] Settings count: ${_settings.value.length}');
    debugPrint('[$context] Settings:');
    for (var s in _settings.value) {
      debugPrint('- ${s.settingName}: ${s.settingValue}');
    }
  }

  Future<void> loadSettings() async {
    debugPrint('Loading settings...');
    _logSettings('Before Load');

    final isConnected = _networkService.isConnected;

    // Load local first
    await loadFromLocal();
    await _databaseService.setSettings(
        _authService.currentUser!.uid, _settings.value);

    // Only load remote if connected and local is empty
    // if (isConnected && _settings.value.whereType<SettingModel>().isEmpty) {
    // if (true) {
    //   await loadFromRemote();
    // }

    _logSettings('After Load');
  }

  // add a method to reset settings to defaults (in Local storage, database, and reactive value)

  Future<void> resetSettingsToDefaults() async {
    debugPrint('Resetting settings to defaults...');
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    // Reset local storage
    await _localStorageService.resetSettingsToDefaults();

    // Reset database
    await _databaseService.resetUserSettings(userId);

    // Reset reactive value
    _settings.value = kDefaultSettings;

    notifyListeners();
  }

  // Add validation helper
  bool _isValidSetting(SettingModel setting) {
    return setting.settingName.isNotEmpty && (setting.settingValue is String ? setting.settingValue.isNotEmpty : setting.settingValue != null);
  }

  // Add helper method
  List<SettingModel> _mergeWithDefaults(List<SettingModel> currentSettings) {
    final mergedSettings = List<SettingModel>.from(currentSettings);

    for (var defaultSetting in kDefaultSettings) {
      if (!mergedSettings
          .any((s) => s.settingName == defaultSetting.settingName)) {
        debugPrint('Adding missing setting: ${defaultSetting.settingName}');
        mergedSettings.add(defaultSetting);
      }
    }

    return mergedSettings;
  }

  Future<void> loadFromRemote() async {
    debugPrint('Loading settings from DB...');
    final String? userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID == null) throw Exception('User ID is null');

    final tempSettings = await _databaseService.getSettings(userID);
    String tempSettingsString = '';
    for (SettingModel s in tempSettings) {
      tempSettingsString += '${s.settingName}=${s.settingValue}, ';
    }
    debugPrint('temp settingss: $tempSettingsString');
    var validSettings = tempSettings.where(_isValidSetting).toList();

    debugPrint('Raw DB settings: ${tempSettings.length}');
    debugPrint('Valid DB settings: ${validSettings.length}');

    // Merge with defaults
    _settings.value = _mergeWithDefaults(validSettings);
    if (validSettings != tempSettings) {
      await _databaseService.setSettings(userID, _settings.value);
    }
    debugPrint('Final settings count after merge: ${_settings.value.length}');

    await _localStorageService.saveSettings(_settings.value);
  }

  Future<void> loadFromLocal() async {
    debugPrint('Loading from local storage...');
    final localSettings = await _localStorageService.getSettings();
    var validSettings =
        localSettings.where((s) => s.settingName.isNotEmpty).toList();

    debugPrint('Raw local settings: ${localSettings.length}');
    for (var s in localSettings) {
      debugPrint('--> ${s.settingName}');
    }
    debugPrint('Valid local settings: ${validSettings.length}');

    // Merge with defaults
    _settings.value = _mergeWithDefaults(validSettings);
    debugPrint('Final settings count after merge: ${_settings.value.length}');

    _logSettings('Local Load Complete');
  }

  Future<void> updateSetting(SettingModel setting) async {
    debugPrint(
        'Updating setting: ${setting.settingName}=${setting.settingValue}');
    _logSettings('Before Update');

    if (setting.settingName.isEmpty) {
      throw Exception('Invalid setting name');
    }

    // Create new list and update
    final newSettings = List<SettingModel>.from(_settings.value);
    final index =
        newSettings.indexWhere((s) => s.settingName == setting.settingName);

    if (index != -1) {
      newSettings[index] = setting;
    } else {
      newSettings.add(setting);
    }

    // Update reactive value
    _settings.value = newSettings;

    _logSettings('After Update');

    // Save changes
    await _localStorageService.saveSettings(_settings.value);
    debugPrint('Settings saved to local storage: ${_settings.value.length}');

    final userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID != null) {
      await _databaseService.updateSetting(userID, setting);
    }
  }

  SettingModel? getSetting(String name) {
    debugPrint('Getting setting: $name');
    debugPrint(
        'Available settings: ${_settings.value.map((s) => s.settingName).join(', ')}');

    try {
      final setting = _settings.value.firstWhere((s) => s.settingName == name);
      debugPrint(
          'Found setting: ${setting.settingName} = ${setting.settingValue}');
      return setting;
    } catch (e) {
      debugPrint('Setting not found: $name');
      return null;
    }
  }

  bool getCommunityFeaturesEnabled() {
    final setting = _settings.value.firstWhere(
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

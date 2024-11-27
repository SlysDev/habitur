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

    if (isConnected) {
      futures.add(loadFromRemote());
    }
    futures.add(loadFromLocal());

    await Future.wait(futures);
  }

  Future<void> loadFromRemote() async {
    final String? userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID == null) throw Exception('User ID is null');

    _settings = await _databaseService.getSettings(userID);
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

    final userID =
        _authService.currentUser?.uid ?? _userService.currentUser?.uid;
    if (userID != null) {
      await _databaseService.updateSettings(userID, setting);
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
}

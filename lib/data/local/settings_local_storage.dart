import 'package:flutter/material.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:collection';
import '../../models/setting.dart';

class SettingsLocalStorage extends ChangeNotifier {
  dynamic _settingsBox;

  Setting get dailyReminders {
    return getSettingByName('Daily Reminders')!;
  }

  Setting get numberOfReminders {
    return getSettingByName('Number of Reminders')!;
  }

  Future<void> init(context) async {
    try {
      debugPrint('are we initing settings?');
      if (Hive.isBoxOpen('settings')) {
        debugPrint('settingsBox is open');
        _settingsBox = Hive.box('settings');
      } else {
        debugPrint('settingsBox must be newly opened');
        _settingsBox = await Hive.openBox('settings');
        if (_settingsBox.values.toList().isEmpty) {
          populateDefaultSettingsData();
        }
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> syncLastUpdated() async {
    await _settingsBox.put('lastUpdated', DateTime.now());
  }

  List<Setting> get settingsList {
    if (_settingsBox == null) {
      debugPrint('settingsBox is null');
      return [];
    }
    if (_settingsBox.values.isEmpty) {
      populateDefaultSettingsData();
    }
    List values = _settingsBox.values.toList();
    List<Setting> settings = [];
    for (dynamic value in values) {
      if (value is Setting) {
        settings.add(value);
      }
    }
    return settings;
  }

  get lastUpdated => _settingsBox.get('lastUpdated');

  Setting? getSettingByName(String settingName) {
    try {
      return _settingsBox.get(settingName);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return null;
    }
  }

  Future<void> populateDefaultSettingsData() async {
    List<Setting> defaultSettings = [
      Setting(settingValue: true, settingName: 'Daily Reminders'),
      Setting(settingValue: 3, settingName: 'Number of Reminders'),
      Setting(
          settingValue: TimeModel(hour: 10, minute: 0),
          settingName: '1st Reminder Time'),
      Setting(
          settingValue: TimeModel(hour: 16, minute: 0),
          settingName: '2nd Reminder Time'),
      Setting(
          settingValue: TimeModel(hour: 22, minute: 0),
          settingName: '3rd Reminder Time'),
    ];
    for (Setting setting in defaultSettings) {
      _settingsBox.put(setting.settingName, setting);
    }
    await syncLastUpdated();
  }

  Future<void> updateSetting(
      String settingName, dynamic newSettingValue) async {
    Setting setting = getSettingByName(settingName)!;
    setting.settingValue = newSettingValue;
    _settingsBox.put(settingName, setting);
    await syncLastUpdated();
  }

  void updateSettings() {
    notifyListeners();
  }
}

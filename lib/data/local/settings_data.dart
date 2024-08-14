import 'package:flutter/material.dart';
import 'package:habitur/models/time_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:collection';
import '../../models/setting.dart';

class SettingsData extends ChangeNotifier {
  dynamic _settingsBox;

  Setting get dailyReminders {
    return getSettingByName('Daily Reminders');
  }

  Setting get numberOfReminders {
    return getSettingByName('Number of Reminders');
  }

  Future<void> init() async {
    print('are we initing settings?');
    if (Hive.isBoxOpen('settings')) {
      print('settingsBox is open');
      _settingsBox = Hive.box<Setting>('settings');
    } else {
      print('settingsBox must be newly opened');
      _settingsBox = await Hive.openBox<Setting>('settings');
      if (_settingsBox.values.toList().isEmpty) {
        populateDefaultSettingsData();
      }
    }
  }

  List<Setting> get settingsList {
    if (_settingsBox == null) {
      print('settingsBox is null');
      return [];
    }
    if (_settingsBox.values.isEmpty) {
      populateDefaultSettingsData();
    }
    return _settingsBox.values.toList();
  }

  Setting getSettingByName(String settingName) {
    return _settingsBox.get(settingName);
  }

  void populateDefaultSettingsData() {
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
  }

  void updateSetting(String settingName, dynamic newSettingValue) {
    Setting newSettingValues = getSettingByName(settingName);
    newSettingValues.settingValue = newSettingValue;
    _settingsBox.put(settingName, newSettingValues);
  }

  void updateSettings() {
    notifyListeners();
  }
}

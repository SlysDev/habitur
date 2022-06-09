import 'package:flutter/material.dart';
import 'dart:collection';
import '../models/setting.dart';

class SettingsData extends ChangeNotifier {
  List<Setting> _settingsList = [
    Setting(settingName: 'Test setting', settingValue: false),
    Setting(settingName: 'Test setting 2', settingValue: true),
  ];
  UnmodifiableListView<Setting> get settingsList {
    return UnmodifiableListView(_settingsList);
  }

  void updateSettings() {
    notifyListeners();
  }
}

import 'package:stacked/stacked.dart';

class SmartNotificationsToggleModel extends BaseViewModel {
  bool _smartNotificationsEnabled = false;

  bool get smartNotificationsEnabled => _smartNotificationsEnabled;

  void initialize(bool value) {
    _smartNotificationsEnabled = value;
  }

  void toggleSmartNotifications(bool value) {
    _smartNotificationsEnabled = value;
    rebuildUi();
  }
}

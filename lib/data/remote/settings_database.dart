import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/time_model.dart';
import 'package:provider/provider.dart';

class SettingsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<void> updateSetting(
      String settingName, dynamic newSettingValue) async {
    CollectionReference users = _firestore.collection('users');
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
    DocumentSnapshot userSnapshot = await userReference.get();
    List<Setting> settings =
        dataConverter.dbListToSettings(userSnapshot.get('settings'));
    for (Setting setting in settings) {
      if (setting.settingName == settingName) {
        setting.settingValue = newSettingValue;
      }
    }
    await userReference.set(
        {'settings': dataConverter.dbSettingsToMap(settings)},
        SetOptions(merge: true));
  }

  Future<void> loadData(context) async {
    CollectionReference users = _firestore.collection('users');
    DocumentSnapshot userSnapshot =
        await users.doc(_auth.currentUser!.uid.toString()).get();
    if (userSnapshot.exists) {
      Provider.of<UserLocalStorage>(context, listen: false).updateUserProperty(
          'settings',
          dataConverter.dbListToSettings(userSnapshot.get('settings')));
    }
  }

  Future<void> uploadData(context) async {
    LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
    CollectionReference users = _firestore.collection('users');
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
    List<Setting> settings =
        Provider.of<SettingsLocalStorage>(context, listen: false).settingsList;
    await userReference.set(
        {'settings': dataConverter.dbSettingsToMap(settings)},
        SetOptions(merge: true));
  }

  Future<void> populateDefaultSettingsData() async {
    // TODO 9/2/24: implement (or not)
    CollectionReference users = _firestore.collection('users');
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
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
    await userReference.set(
      {'settings': dataConverter.dbSettingsToMap(defaultSettings)},
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';

class SettingsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<void> updateSetting(
      String settingName, dynamic newSettingValue, context) async {
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
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
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> loadData(context) async {
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentSnapshot userSnapshot =
          await users.doc(_auth.currentUser!.uid.toString()).get();
      List<Setting> settings;
      try {
        userSnapshot.get('settings');
        settings = dataConverter.dbListToSettings(userSnapshot.get('settings'));
      } catch (e, s) {
        settings = kDefaultSettings;
        await populateDefaultSettingsData(context);
      }

      if (userSnapshot.exists) {
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty('settings', settings);
      }
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadData(context) async {
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      List<Setting> settings =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .settingsList;
      await userReference.set(
          {'settings': dataConverter.dbSettingsToMap(settings)},
          SetOptions(merge: true));
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> populateDefaultSettingsData(context) async {
    // TODO: Write commit saying that you fixed settings overwriting user data
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      await userReference.set(
        {'settings': dataConverter.dbSettingsToMap(kDefaultSettings)},
        SetOptions(merge: true),
      );
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }
}

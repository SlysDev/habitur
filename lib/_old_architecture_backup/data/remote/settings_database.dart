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

import '../../models/habit_visibility.dart';
import '../../models/privacy_settings.dart';
import '../../providers/habit_manager.dart';

class SettingsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<void> updateSetting(
      String settingName, dynamic newSettingValue, context) async {
    await showStatusOverlay(context, 'Loading...', () async {
      try {
        UserDatabase userDatabase = UserDatabase();
        if (!userDatabase.isLoggedIn) {
          throw Exception('User is not logged in');
        }
        CollectionReference users = _firestore.collection('users');
        DocumentReference userReference =
            users.doc(_auth.currentUser!.uid.toString());
        DocumentSnapshot userSnapshot = await userReference.get();
        List<SettingModel> settings =
            dataConverter.dbListToSettings(userSnapshot.get('settings'));
        for (SettingModel setting in settings) {
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
    });
  }

  Future<void> loadData(BuildContext context) async {
    try {
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      final user = userStorage.currentUser;
      if (user == null) return;

      // Load settings
      List<SettingModel> settings;
      DocumentSnapshot? userSnapshot;

      CollectionReference users = _firestore.collection('users');
      userSnapshot = await users.doc(_auth.currentUser!.uid.toString()).get();

      try {
        settings = dataConverter.dbListToSettings(userSnapshot.get('settings'));
      } catch (e, s) {
        settings = kDefaultSettings;
        await populateDefaultSettingsData(context);
      }

      if (userSnapshot.exists) {
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty('settings', settings);

        // Load privacy settings
        try {
          final privacySettingsMap = userSnapshot.get('privacySettings');
          if (privacySettingsMap != null) {
            final privacySettings = PrivacySettings.fromMap(
                privacySettingsMap as Map<String, dynamic>);
            final user = Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser;
            Provider.of<UserLocalStorage>(context, listen: false).currentUser =
                user.copyWith(privacySettings: privacySettings);
          }
        } catch (e) {
          debugPrint('No privacy settings found, using defaults');
        }
      }

      // Load habit visibility settings
      final visibilitySettings = await loadHabitVisibility(user.uid);
      final habitManager = Provider.of<HabitManager>(context, listen: false);

      // Update habit visibility in local storage
      for (final visibility in visibilitySettings) {
        final habit = habitManager.habits.firstWhere(
          (h) => h.id.toString() == visibility.habitId,
          orElse: () => throw Exception('Habit not found'),
        );

        habitManager.updateHabit(
          habit.copyWith(isVisible: visibility.isVisible),
        );
      }

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e) {
      debugPrint('Error loading settings: $e');
      if (e is Exception) {
        Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
            false;
      }
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

      // Upload settings
      List<SettingModel> settings =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .settingsList;
      await userReference.set(
          {'settings': dataConverter.dbSettingsToMap(settings)},
          SetOptions(merge: true));

      // Upload privacy settings
      final privacySettings =
          Provider.of<UserLocalStorage>(context, listen: false)
              .currentUser
              .privacySettings;
      if (privacySettings != null) {
        await userReference.set(
          {'privacySettings': privacySettings.toMap()},
          SetOptions(merge: true),
        );
      }

      await lastUpdatedManager.syncLastUpdated(context, _auth.currentUser!.uid);
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

  Future<void> updatePrivacySettings(
      BuildContext context, PrivacySettings newSettings) async {
    await showStatusOverlay<void>(context, 'Updating privacy settings...',
        () async {
      try {
        UserDatabase userDatabase = UserDatabase();
        if (!userDatabase.isLoggedIn) {
          throw Exception('User is not logged in');
        }

        CollectionReference users = _firestore.collection('users');
        DocumentReference userReference =
            users.doc(_auth.currentUser!.uid.toString());

        await userReference.set(
          {'privacySettings': newSettings.toMap()},
          SetOptions(merge: true),
        );

        // Update local storage
        final user =
            Provider.of<UserLocalStorage>(context, listen: false).currentUser;
        Provider.of<UserLocalStorage>(context, listen: false).currentUser =
            user.copyWith(privacySettings: newSettings);
      } catch (e, s) {
        debugPrint(e.toString());
        if (!e.toString().contains('User is not logged in')) {
          debugPrint(s.toString());
          showDebugErrorSnackbar(context, e, s);
        }
        Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
            false;
      }
    }, successMessage: 'Privacy data updated successfully');
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

  Future<void> updateHabitVisibility(
    BuildContext context,
    HabitVisibility visibility,
  ) async {
    try {
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      final user = userStorage.currentUser;
      if (user == null) return;

      // Update habit visibility in Firebase
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habitVisibility')
          .doc(visibility.habitId)
          .set(visibility.toMap());

      // Update local habit
      final habitManager = Provider.of<HabitManager>(context, listen: false);
      final habit = habitManager.habits.firstWhere(
        (h) => h.id.toString() == visibility.habitId,
        orElse: () => throw Exception('Habit not found'),
      );

      habitManager.updateHabit(
        habit.copyWith(isVisible: visibility.isVisible),
      );
    } catch (e) {
      debugPrint('Error updating habit visibility: $e');
      rethrow;
    }
  }

  Future<List<HabitVisibility>> loadHabitVisibility(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habitVisibility')
          .get();

      return snapshot.docs
          .map((doc) => HabitVisibility.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading habit visibility: $e');
      return [];
    }
  }
}

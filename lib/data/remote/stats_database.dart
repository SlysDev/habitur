import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/modules/summary_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';

class StatsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<void> loadStatistics(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentSnapshot userSnapshot =
          await users.doc(_auth.currentUser!.uid.toString()).get();
      if (userSnapshot.exists) {
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty(
                'stats',
                dataConverter.dbListToStatPoints(
                    userSnapshot.get('stats')['statPoints']));
        ;
      } else {
        debugPrint('User doc does not exist.');
      }

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadStatistics(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      await userReference.set({
        'habiturRating': Provider.of<UserLocalStorage>(context, listen: false)
            .currentUser
            .userXP,
      }, SetOptions(merge: true));

      await userReference.set({
        'stats': {
          // Converting confidenceStats into an array of normal objects
          'statPoints': dataConverter.dbStatPointsToMap(
              Provider.of<UserLocalStorage>(context, listen: false)
                  .currentUser
                  .stats),
        }
      }, SetOptions(merge: true));

      debugPrint('stats uploaded');
      await lastUpdatedManager.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> clearStatistics(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      var habitsCollectionSnapshot =
          await userReference.collection('habits').get();
      userReference.set({
        'userLevel': 1,
        'userXP': 0,
        'stats': {
          'totalHabitsCompleted': 0,
          'statPoints': [],
        }
      }, SetOptions(merge: true));

      for (var doc in habitsCollectionSnapshot.docs) {
        doc.reference.set({
          'completionsToday': 0,
          'streak': 0,
          'confidenceLevel': 0,
          'highestStreak': 0,
          'totalCompletions': 0,
          'dateCreated': DateTime.now(),
          'daysCompleted': [],
          'stats': {},
          'lastSeen': DateTime.now(),
          'resetPeriod': 0,
        }, SetOptions(merge: true));
      }
      lastUpdatedManager.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }
}

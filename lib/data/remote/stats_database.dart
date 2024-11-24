import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
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
      debugPrint('Starting stats database load');
      final stopwatch = Stopwatch()..start();
      
      final uid = _auth.currentUser!.uid.toString();
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      
      // Single document read
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        debugPrint('User doc exists');
        final loadStart = stopwatch.elapsedMilliseconds;
        final stats = dataConverter.dbListToStatPoints(userDoc.get('stats')['statPoints']);
        debugPrint('Stats conversion took: ${stopwatch.elapsedMilliseconds - loadStart}ms');
        
        final updateStart = stopwatch.elapsedMilliseconds;
        userStorage.updateUserProperty('stats', stats);
        debugPrint('Stats update took: ${stopwatch.elapsedMilliseconds - updateStart}ms');
        
        debugPrint('Stats loaded');
      } else {
        debugPrint('User doc does not exist.');
      }

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = false;
    }
  }

  Future<void> uploadStatistics(context) async {
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('Starting stats database upload');
      
      final userStorage = Provider.of<UserLocalStorage>(context, listen: false);
      final user = userStorage.currentUser;
      final uid = _auth.currentUser!.uid.toString();
      
      final prepStart = stopwatch.elapsedMilliseconds;

      // Pre-calculate stats conversion
      final convertStart = stopwatch.elapsedMilliseconds;
      final convertedStats = dataConverter.dbStatPointsToMap(user.stats);
      debugPrint('Stats conversion took: ${stopwatch.elapsedMilliseconds - convertStart}ms');

      // Combine all updates into a single operation
      final updateData = {
        'habiturRating': user.userXP,
        'stats': {
          'statPoints': convertedStats,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Single batch write
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(uid);
      batch.set(userRef, updateData, SetOptions(merge: true));
      
      debugPrint('Stats batch preparation took: ${stopwatch.elapsedMilliseconds - prepStart}ms');

      final commitStart = stopwatch.elapsedMilliseconds;
      await batch.commit();
      debugPrint('Stats batch commit took: ${stopwatch.elapsedMilliseconds - commitStart}ms');
      
      debugPrint('Total stats upload took: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('stats uploaded');
      
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = false;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> clearStatistics(context) async {
    final stopwatch = Stopwatch()..start();
    try {
      debugPrint('Starting stats database clear');
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

      final prepStart = stopwatch.elapsedMilliseconds;
      for (var doc in habitsCollectionSnapshot.docs) {
        doc.reference.set({
          'currentProgress': 0,
          'streak': 0,
          'confidenceLevel': 0,
          'highestStreak': 0,
          'totalProgress': 0,
          'dateCreated': DateTime.now(),
          'daysCompleted': [],
          'stats': {},
          'lastSeen': DateTime.now(),
          'resetPeriod': 0,
        }, SetOptions(merge: true));
      }
      debugPrint('Stats batch preparation took: ${stopwatch.elapsedMilliseconds - prepStart}ms');

      final commitStart = stopwatch.elapsedMilliseconds;
      debugPrint('Stats batch commit took: ${stopwatch.elapsedMilliseconds - commitStart}ms');
      
      debugPrint('Total stats clear took: ${stopwatch.elapsedMilliseconds}ms');
      await lastUpdatedManager.syncLastUpdated(context, _auth.currentUser!.uid);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    } finally {
      stopwatch.stop();
    }
  }
}

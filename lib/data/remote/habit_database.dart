import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/data/remote/user_database.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';

class HabitDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _usersCollection;
  late final DocumentReference _userDoc;
  late final CollectionReference _habitsCollection;
  final LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  final DataConverter dataConverter = DataConverter();

  HabitDatabase() {
    _usersCollection = _firestore.collection('users');
    _initializeCollections();
  }

  void _initializeCollections() {
    if (_auth.currentUser != null) {
      _userDoc = _usersCollection.doc(_auth.currentUser!.uid);
      _habitsCollection = _userDoc.collection('habits');
    }
  }

  bool get isInitialized => _auth.currentUser != null;

  Future<List<Habit>> loadHabits(context, {String? userID}) async {
    try {
      await clearDuplicateHabits(context);
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      CollectionReference habitsReference = _habitsCollection;
      QuerySnapshot habitsSnapshot = await habitsReference.get();

      // Get data from docs and convert map to List
      final habitDocs = habitsSnapshot.docs;
      List<Habit> habitList = [];
      for (var habit in habitDocs) {
        // Converting all arrays back into their datatypes
        List<dynamic> requiredDatesOfCompletionRaw =
            habit.get('requiredDatesOfCompletion');

        List<String> requiredDatesOfCompletionFormatted =
            requiredDatesOfCompletionRaw
                .map<String>((dynamic date) => date.toString())
                .toList();

        List<DateTime> daysCompletedFormatted =
            dataConverter.dbListToDates(habit.get('daysCompleted'));

        Habit loadedHabit = Habit(
          title: habit.get('title'),
          resetPeriod: habit.get('resetPeriod'),
          // Converts timestamp to DateTime
          dateCreated: habit.get('dateCreated').toDate(),
          currentProgress: habit.get('currentProgress'),
          id: habit.get('id'),
          lastSeen: habit.get('lastSeen').toDate(),
          smartNotifsEnabled: habit.get('smartNotifsEnabled') ?? false,
          totalProgress: habit.get('totalProgress'),
          streak: habit.get('streak'),
          highestStreak: habit.get('highestStreak'),
          confidenceLevel: habit.get('confidenceLevel').toDouble(),
          // Converts timestamp to DateTime
          targetGoal: habit.get('targetGoal'),
          requiredDatesOfCompletion: requiredDatesOfCompletionFormatted,
        );
        loadedHabit.stats =
            dataConverter.dbListToStatPoints(habit.get('stats'));
        loadedHabit.daysCompleted = daysCompletedFormatted;
        habitList.add(loadedHabit);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = true;
      return habitList;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = false;
      return [];
    }
  }

  Future<void> uploadHabits(context, {String? userID}) async {
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      var habitsCollectionRef = _habitsCollection;
      var habitsCollectionSnapshot =
          await _habitsCollection.get();

      for (var habit
          in Provider.of<HabitManager>(context, listen: false).habits) {
        if (habitsCollectionSnapshot.size == 0) {
          await addHabit(habit, context);
        } else {
          bool found = false;
          for (var doc in habitsCollectionSnapshot.docs) {
            if (doc.get('id') == habit.id) {
              found = true;
              await _updateHabitDoc(habit, doc);
            }
          }
          if (!found) {
            await addHabit(habit, context);
          }
        }
      }
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
    }
  }

  Future<void> _updateHabitDoc(Habit habit, DocumentSnapshot doc) async {
    await doc.reference.update({
      'title': habit.title,
      'currentProgress': habit.currentProgress,
      'dateCreated': habit.dateCreated,
      'resetPeriod': habit.resetPeriod,
      'id': habit.id,
      'streak': habit.streak,
      'confidenceLevel': habit.confidenceLevel,
      'highestStreak': habit.highestStreak,
      'requiredDatesOfCompletion': habit.requiredDatesOfCompletion,
      'targetGoal': habit.targetGoal,
      'totalProgress': habit.totalProgress,
      'lastSeen': habit.lastSeen,
      'smartNotifsEnabled': habit.smartNotifsEnabled,
      'daysCompleted': habit.daysCompleted
          .map((completedDate) => {
                'date': completedDate,
              })
          .toList(),
      'stats': dataConverter.dbStatPointsToMap(habit.stats),
    });
  }

  Future<void> addHabit(Habit habit, context) async {
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      var habitsCollectionRef = _habitsCollection;
      await habitsCollectionRef.add({
        'title': habit.title,
        'currentProgress': habit.currentProgress,
        'dateCreated': habit.dateCreated,
        'resetPeriod': habit.resetPeriod,
        'id': habit.id,
        'streak': habit.streak,
        'confidenceLevel': habit.confidenceLevel,
        'highestStreak': habit.highestStreak,
        'requiredDatesOfCompletion': habit.requiredDatesOfCompletion,
        'targetGoal': habit.targetGoal,
        'totalProgress': habit.totalProgress,
        'lastSeen': habit.lastSeen,
        'smartNotifsEnabled': habit.smartNotifsEnabled,
        'daysCompleted': habit.daysCompleted
            .map((completedDate) => {
                  'date': completedDate,
                })
            .toList(),
        'stats': dataConverter.dbStatPointsToMap(habit.stats),
      });
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
    }
  }

  Future<void> updateHabit(Habit habit, context) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      
      // Track query time
      final queryStart = stopwatch.elapsedMilliseconds;
      final habitQuery = await _habitsCollection.where('id', isEqualTo: habit.id).limit(1).get();
      debugPrint('DB Query took: ${stopwatch.elapsedMilliseconds - queryStart}ms');
      
      if (habitQuery.docs.isEmpty) return;
      
      final batch = _firestore.batch();
      final habitDoc = habitQuery.docs.first;
      
      // Track batch preparation time
      final batchStart = stopwatch.elapsedMilliseconds;
      batch.update(habitDoc.reference, {
        'currentProgress': habit.currentProgress,
        'streak': habit.streak,
        'confidenceLevel': habit.confidenceLevel,
        'highestStreak': habit.highestStreak,
        'totalProgress': habit.totalProgress,
        'lastSeen': habit.lastSeen,
        'daysCompleted': habit.daysCompleted.map((date) => {'date': date}).toList(),
        'stats': dataConverter.dbStatPointsToMap(habit.stats),
      });
      
      batch.update(_userDoc, {
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint('Batch preparation took: ${stopwatch.elapsedMilliseconds - batchStart}ms');
      
      // Track commit time
      final commitStart = stopwatch.elapsedMilliseconds;
      await batch.commit();
      debugPrint('Batch commit took: ${stopwatch.elapsedMilliseconds - commitStart}ms');
      
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = true;
      debugPrint('Total database operation took: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e, s) {
      debugPrint('Database error after ${stopwatch.elapsedMilliseconds}ms: $e');
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected = false;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> deleteHabit(context, int id) async {
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      List<QueryDocumentSnapshot> docs = await getHabitByID(id, context);
      for (var doc in docs) {
        await doc.reference.delete();
      }
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
    }
  }

  Future<List<QueryDocumentSnapshot>> getHabitByID(int id, context) async {
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      QuerySnapshot foundHabit =
          await _habitsCollection.where('id', isEqualTo: id).get();
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
      return foundHabit.docs;
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    return Future.error('No Habit Found for id:' + id.toString());
  }

  Future<void> clearDuplicateHabits(context) async {
    debugPrint('clearing duplicate habits');
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      QuerySnapshot foundHabits = await _habitsCollection.get();

      Set<int> uniqueHabitIds = {}; // To track unique habit IDs

      for (var doc in foundHabits.docs) {
        int habitId = doc.get('id'); // Use 'id' as the unique identifier

        // If the habit ID is already in the set, it's a duplicate
        if (uniqueHabitIds.contains(habitId)) {
          // Delete the duplicate habit
          await _habitsCollection.doc(doc.id).delete();
        } else {
          // Add the habit ID to the set if it's unique
          uniqueHabitIds.add(habitId);
        }
      }
    } catch (e, s) {
      debugPrint(e.toString());
      if (!e.toString().contains('User is not logged in')) {
        debugPrint(s.toString());
        showDebugErrorSnackbar(context, e, s);
      }
    }
  }

  Future<void> clearHabits(context) async {
    try {
      if (!isInitialized) {
        throw Exception('User is not logged in');
      }
      await _habitsCollection.get().then((value) {
        for (var doc in value.docs) {
          doc.reference.delete();
        }
      });
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
    }
  }
}

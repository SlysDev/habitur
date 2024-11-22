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
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<List<Habit>> loadHabits(context, {String? userID}) async {
    try {
      await clearDuplicateHabits(context);
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(userID ?? _auth.currentUser!.uid.toString());
      CollectionReference habitsReference = userReference.collection('habits');
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
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(userID ?? _auth.currentUser!.uid.toString());

      var habitsCollectionRef = userReference.collection('habits');
      var habitsCollectionSnapshot =
          await userReference.collection('habits').get();

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
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      var habitsCollectionRef = userReference.collection('habits');
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
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      List<QueryDocumentSnapshot> docs = await getHabitByID(habit.id, context);
      for (var doc in docs) {
        await _updateHabitDoc(habit, doc);
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

  Future<void> deleteHabit(context, int id) async {
    try {
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
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
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      var habitsCollectionRef = userReference.collection('habits');

      QuerySnapshot foundHabit =
          await habitsCollectionRef.where('id', isEqualTo: id).get();
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
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      var habitsCollectionRef = userReference.collection('habits');
      QuerySnapshot foundHabits = await habitsCollectionRef.get();

      Set<int> uniqueHabitIds = {}; // To track unique habit IDs

      for (var doc in foundHabits.docs) {
        int habitId = doc.get('id'); // Use 'id' as the unique identifier

        // If the habit ID is already in the set, it's a duplicate
        if (uniqueHabitIds.contains(habitId)) {
          // Delete the duplicate habit
          await habitsCollectionRef.doc(doc.id).delete();
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
      UserDatabase userDatabase = UserDatabase();
      if (!userDatabase.isLoggedIn) {
        throw Exception('User is not logged in');
      }
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      var habitsCollectionRef = userReference.collection('habits');
      await habitsCollectionRef.get().then((value) {
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

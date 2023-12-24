import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/leveling_system.dart';
import 'package:habitur/providers/statistics_display_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class Database extends ChangeNotifier {
  CollectionReference users = _firestore.collection('users');
  Future<void> userSetup(String username, String email) async {
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
    userDoc.set({
      'username': username,
      'email': email,
      'uid': uid,
    });
    return;
  }

  get userData async {
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot;
  }

  get currentUser {
    return _auth.currentUser;
  }

  void loadHabits(context) async {
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
    CollectionReference habitsReference = userReference.collection('habits');
    QuerySnapshot habitsSnapshot = await habitsReference.get();
    DocumentSnapshot userSnapshot = await userReference.get();
    Provider.of<LevelingSystem>(context, listen: false).habiturRating =
        userSnapshot.get('habiturRating');
    Provider.of<UserData>(context, listen: false).username =
        userSnapshot.get('username');

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

      List<dynamic> daysCompletedRaw = habit.get('daysCompleted');
      List<DateTime> daysCompletedFormatted = daysCompletedRaw
          .map<DateTime>((dynamic date) => date.toDate())
          .toList();
      List<dynamic> confidenceStatsRaw = habit.get('confidenceStats');
      List<DataPoint> confidenceStatsFormatted = confidenceStatsRaw
          .map<DataPoint>(
              (dynamic stat) => DataPoint(date: stat.date, value: stat.value))
          .toList();

      List<dynamic> completionStatsRaw = habit.get('completionStats');
      List<DataPoint> completionStatsFormatted = completionStatsRaw
          .map<DataPoint>(
              (dynamic stat) => DataPoint(date: stat.date, value: stat.value))
          .toList();

      Habit loadedHabit = Habit(
        title: habit.get('title'),
        resetPeriod: habit.get('resetPeriod'),
        // Converts timestamp to DateTime
        dateCreated: habit.get('dateCreated').toDate(),
        completionsToday: habit.get('completionsToday'),
        totalCompletions: habit.get('totalCompletions'),
        streak: habit.get('streak'),
        highestStreak: habit.get('highestStreak'),
        confidenceLevel: habit.get('confidenceLevel'),
        // Converts timestamp to DateTime
        lastSeen: habit.get('lastSeen').toDate(),
        requiredCompletions: habit.get('requiredCompletions'),
        requiredDatesOfCompletion: requiredDatesOfCompletionFormatted,
        daysCompleted: daysCompletedFormatted,
        confidenceStats: confidenceStatsFormatted,
        completionStats: completionStatsFormatted,
      );
      habitList.add(loadedHabit);
    }
    Provider.of<HabitManager>(context, listen: false).loadHabits(habitList);
    Provider.of<HabitManager>(context, listen: false).resetDailyHabits();
    print('data loaded.');
  }

  void uploadHabits(context) async {
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());

    // First clear the collection
    var habitsCollection = await userReference.collection('habits').get();
    for (var habitDoc in habitsCollection.docs) {
      habitDoc.reference.delete();
    }
    // Then add all of the habits from the local array to the database
    for (var habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
      print(habit.title + ': ' + habit.confidenceStats.toString());
      print(habit.title + ': ' + habit.completionStats.toString());
      userReference.collection('habits').add({
        'title': habit.title,
        'completionsToday': habit.completionsToday,
        'dateCreated': habit.dateCreated,
        'resetPeriod': habit.resetPeriod,
        'streak': habit.streak,
        'confidenceLevel': habit.confidenceLevel,
        'highestStreak': habit.highestStreak,
        'requiredDatesOfCompletion': habit.requiredDatesOfCompletion,
        'requiredCompletions': habit.requiredCompletions,
        'totalCompletions': habit.totalCompletions,
        'lastSeen': habit.lastSeen,
        'daysCompleted': habit.daysCompleted
            .map((completedDate) => {
                  'date': completedDate,
                })
            .toList(growable: true),
        'confidenceStats': habit.confidenceStats
            .map((stat) => {
                  'date': stat.date,
                  'value': stat.value,
                })
            .toList(growable: true),
        'completionStats': habit.completionStats
            .map((stat) => {
                  'date': stat.date,
                  'value': stat.value,
                })
            .toList(growable: true),
      });
    }
    print('uploaded to database.');
    //// TODO: Upload hive's storage of the habit list to Firebase  <22-12-22, slys> //
  }

  void loadStatistics(context) async {
    DocumentSnapshot userSnapshot =
        await users.doc(_auth.currentUser!.uid.toString()).get();
    List<DataPoint> tempConfidenceList = [];
    List confidenceStats = userSnapshot.get('stats')['confidenceStats'];
    for (var dataPoint in confidenceStats) {
      tempConfidenceList.add(DataPoint(
          date: dataPoint['date'].toDate(), value: dataPoint['value']));
    }
    Provider.of<SummaryStatisticsRepository>(context, listen: false)
        .confidenceStats = tempConfidenceList;
    Provider.of<StatisticsDisplayManager>(context, listen: false)
        .initStatsDisplay(context);

    Provider.of<SummaryStatisticsRepository>(context, listen: false)
            .totalHabitsCompleted =
        userSnapshot.get('stats')['totalHabitsCompleted'];
    Provider.of<SummaryStatisticsRepository>(context, listen: false)
        .notifyListeners();
  }

  void uploadStatistics(context) async {
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());

    userReference.set({
      'habiturRating':
          Provider.of<LevelingSystem>(context, listen: false).habiturRating,
    }, SetOptions(merge: true));

    DocumentSnapshot userSnapshot = await userReference.get();
    userReference.set({
      'stats': {
        'totalHabitsCompleted':
            Provider.of<SummaryStatisticsRepository>(context, listen: false)
                .totalHabitsCompleted,
        // Converting confidenceStats into an array of normal objects
        'confidenceStats':
            Provider.of<SummaryStatisticsRepository>(context, listen: false)
                .confidenceStats
                .map((dataPoint) => {
                      'value': dataPoint.value,
                      'date': dataPoint.date,
                    })
                .toList(),
        'completionStats':
            Provider.of<SummaryStatisticsRepository>(context, listen: false)
                .completionStats
                .map((dataPoint) => {
                      'value': dataPoint.value,
                      'date': dataPoint.date,
                    })
                .toList(),
      }
    }, SetOptions(merge: true));

    print('stats uploaded');
  }

  void loadData(context) async {
    loadHabits(context);
    loadStatistics(context);
  }

  void uploadData(context) async {
    uploadHabits(context);
    uploadStatistics(context);
  }
}

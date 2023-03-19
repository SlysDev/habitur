import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/leveling_system.dart';
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

  void loadData(context) async {
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
      // Converting the date from a Timestamp to a DateTime data type.
      Habit loadedHabit = Habit(
          title: habit.get('title'),
          resetPeriod: habit.get('resetPeriod'),
          // Converts timestamp to DateTime
          dateCreated: habit.get('dateCreated').toDate(),
          completionsToday: habit.get('completionsToday'),
          requiredDatesOfCompletion: habit.get('requiredDatesOfCompletion'),
          totalCompletions: habit.get('totalCompletions'),
          streak: habit.get('streak'),
          highestStreak: habit.get('highestStreak'),
          confidenceLevel: habit.get('confidenceLevel'),
          lastSeen: habit.get('lastSeen').toDate(),
          requiredCompletions: habit.get('requiredCompletions'));
      habitList.add(loadedHabit);
    }
    Provider.of<HabitManager>(context, listen: false).loadHabits(habitList);
    Provider.of<HabitManager>(context, listen: false).resetDailyHabits();
    print('data loaded.');
  }

  void uploadData(context) async {
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
    userReference.update({
      'habiturRating':
          Provider.of<LevelingSystem>(context, listen: false).habiturRating
    });

    // First clear the collection
    var habitsCollection = await userReference.collection('habits').get();
    for (var habitDoc in habitsCollection.docs) {
      habitDoc.reference.delete();
    }
    // Then add all of the habits from the local array to the database
    for (var habit
        in Provider.of<HabitManager>(context, listen: false).habits) {
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
      });
    }
    print('uploaded to database.');
    //// TODO: Upload hive's storage of the habit list to Firebase  <22-12-22, slys> //
  }
}

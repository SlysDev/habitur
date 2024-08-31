import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/data/remote/last_updated_manager.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class HabitDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  LastUpdatedManager lastUpdatedManager = LastUpdatedManager();
  DataConverter dataConverter = DataConverter();
  Future<void> loadHabits(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
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
          completionsToday: habit.get('completionsToday'),
          id: habit.get('id'),
          lastSeen: habit.get('lastSeen').toDate(),
          totalCompletions: habit.get('totalCompletions'),
          streak: habit.get('streak'),
          highestStreak: habit.get('highestStreak'),
          confidenceLevel: habit.get('confidenceLevel').toDouble(),
          // Converts timestamp to DateTime
          requiredCompletions: habit.get('requiredCompletions'),
          requiredDatesOfCompletion: requiredDatesOfCompletionFormatted,
        );
        loadedHabit.stats =
            dataConverter.dbListToStatPoints(habit.get('stats'));
        loadedHabit.daysCompleted = daysCompletedFormatted;
        habitList.add(loadedHabit);
      }
      Provider.of<HabitManager>(context, listen: false).loadHabits(habitList);
      await Provider.of<HabitManager>(context, listen: false)
          .resetDailyHabits(context);
      await Provider.of<HabitManager>(context, listen: false)
          .resetWeeklyHabits(context);
      await Provider.of<HabitManager>(context, listen: false)
          .resetMonthlyHabits(context);
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .uploadAllHabits(habitList);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadHabits(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      var habitsCollectionRef = userReference.collection('habits');
      var habitsCollectionSnapshot =
          await userReference.collection('habits').get();

      for (var habit
          in Provider.of<HabitManager>(context, listen: false).habits) {
        if (habitsCollectionSnapshot.size == 0) {
          addHabit(habit, context);
        } else {
          bool found = false;
          for (var doc in habitsCollectionSnapshot.docs) {
            if (doc.get('id') == habit.id) {
              found = true;
              await _updateHabitDoc(habit, doc);
            }
          }
          if (!found) {
            addHabit(habit, context);
          }
        }
        //// TODO: Upload hive's storage of the habit list to Firebase  <22-12-22, slys> //
      }
      lastUpdatedManager.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> _updateHabitDoc(Habit habit, DocumentSnapshot doc) async {
    await doc.reference.update({
      'title': habit.title,
      'completionsToday': habit.completionsToday,
      'dateCreated': habit.dateCreated,
      'resetPeriod': habit.resetPeriod,
      'id': habit.id,
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
          .toList(),
      'stats': dataConverter.dbStatPointsToMap(habit.stats),
    });
  }

  Future<void> addHabit(Habit habit, context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      var habitsCollectionRef = userReference.collection('habits');
      await habitsCollectionRef.add({
        'title': habit.title,
        'completionsToday': habit.completionsToday,
        'dateCreated': habit.dateCreated,
        'resetPeriod': habit.resetPeriod,
        'id': habit.id,
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
            .toList(),
        'stats': dataConverter.dbStatPointsToMap(habit.stats),
      });
      lastUpdatedManager.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> updateHabit(Habit habit, context) async {
    try {
      await _updateHabitDoc(habit, await getHabitByID(habit.id, context));
      lastUpdatedManager.syncLastUpdated(context);

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> deleteHabit(context, int id) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      var habitsCollectionRef = userReference.collection('habits');

      QueryDocumentSnapshot doc = await getHabitByID(id, context);

      await habitsCollectionRef.doc(doc.id).delete();
      await lastUpdatedManager.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<QueryDocumentSnapshot> getHabitByID(int id, context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());
      var habitsCollectionRef = userReference.collection('habits');

      QuerySnapshot foundHabit =
          await habitsCollectionRef.where('id', isEqualTo: id).get();
      if (foundHabit.docs.length > 0) {
        return foundHabit.docs[0];
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    return Future.error('No Habit Found for id:' + id.toString());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/data/remote/data_converter.dart';
import 'package:habitur/modules/summary_stats_calculator.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class StatsDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Database db = Database();
  Future<void> loadStatistics(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentSnapshot userSnapshot =
          await users.doc(_auth.currentUser!.uid.toString()).get();
      if (userSnapshot.exists) {
        Provider.of<UserLocalStorage>(context, listen: false)
            .updateUserProperty(
                'stats',
                db.dataConverter.dbListToStatPoints(
                    userSnapshot.get('stats')['statPoints']));
        ;
      } else {
        print('User doc does not exist.');
      }

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void uploadStatistics(context) async {
    SummaryStatsCalculator summaryStatsCalculator = SummaryStatsCalculator();
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentReference userReference =
          users.doc(_auth.currentUser!.uid.toString());

      userReference.set({
        'habiturRating': Provider.of<UserLocalStorage>(context, listen: false)
            .currentUser
            .userXP,
      }, SetOptions(merge: true));

      userReference.set({
        'stats': {
          'totalHabitsCompleted':
              summaryStatsCalculator.getTotalHabitsCompleted(context),
          // Converting confidenceStats into an array of normal objects
          'statPoints': db.dataConverter.dbStatPointsToMap(
              Provider.of<UserLocalStorage>(context, listen: false)
                  .currentUser
                  .stats),
        }
      }, SetOptions(merge: true));

      print('stats uploaded');
      db.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void clearStatistics(context) async {
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
      db.syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(e);
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }
}

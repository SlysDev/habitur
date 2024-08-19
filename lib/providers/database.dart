import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class Database extends ChangeNotifier {
  Future<void> userSetup(String username, String email) async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid); // create a new doc w/ uid.
    userDoc.set({
      'username': username,
      'bio': '',
      'email': email,
      'uid': uid,
      'stats': {'totalHabitsCompleted': 0, 'statPoints': []},
      'userLevel': 1,
      'userXP': 0,
      'isAdmin': false,
      'lastUpdated': DateTime.now()
    });
    return;
  }

  get userData async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot;
  }

  get currentUser {
    return _auth.currentUser;
  }

  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  Future<DateTime> get lastUpdated async {
    CollectionReference users = _firestore.collection('users');
    String uid = _auth.currentUser!.uid.toString();
    DocumentReference userDoc = users.doc(uid);
    DocumentSnapshot userSnapshot = await userDoc.get();
    return userSnapshot['lastUpdated'].toDate();
  }
  // Helper Functions

  List<DataPoint> dbListToDataPoints(input) {
    if (input.isNotEmpty) {
      return input.map<DataPoint>((element) {
        if (element is Map<String, dynamic>) {
          dynamic date = element['date'];
          DateTime dateTime;
          if (date is Timestamp) {
            dateTime = date.toDate();
          } else {
            dateTime = DateTime.now(); // Handle unexpected format
            print('weird formatting, used DateTime.now() for this one.');
          }
          return DataPoint(date: dateTime, value: element['value']);
        } else {
          print('input was empty');
          return DataPoint(
              date: DateTime.now(), value: 0); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }

  List<StatPoint> dbListToStatPoints(input) {
    if (input.isNotEmpty) {
      return input.map<StatPoint>((element) {
        if (element is Map<String, dynamic>) {
          dynamic date = element['date'];
          DateTime dateTime;
          if (date is Timestamp) {
            dateTime = date.toDate();
          } else {
            dateTime = DateTime.now(); // Handle unexpected format
            print('weird formatting, used DateTime.now() for this one.');
          }
          return StatPoint(
            date: dateTime,
            completions: element['completions'] ?? 0,
            confidenceLevel: element['confidenceLevel'] != null
                ? element['confidenceLevel'].toDouble()
                : 0,
            streak: element['streak'] ?? 0,
            difficultyRating: (element['difficultyRating'] ?? 0).toDouble(),
            slopeCompletions: (element['slopeCompletions'] ?? 0).toDouble(),
            slopeConfidenceLevel:
                (element['slopeConfidenceLevel'] ?? 0).toDouble(),
            slopeConsistency: (element['slopeConsistency'] ?? 0).toDouble(),
            slopeDifficultyRating:
                (element['slopeDifficultyRating'] ?? 0).toDouble(),
          );
        } else {
          print('input was empty');
          return StatPoint(
              date: DateTime.now(),
              completions: 0,
              confidenceLevel: 1,
              streak: 0); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }

  List<Map<String, dynamic>> dbStatPointsToMap(List<StatPoint> statPoints) {
    return statPoints
        .map<Map<String, dynamic>>((statPoint) => {
              'date': Timestamp.fromDate(statPoint.date),
              'completions': statPoint.completions,
              'confidenceLevel': statPoint.confidenceLevel,
              'streak': statPoint.streak,
              'difficultyRating': statPoint.difficultyRating,
              'slopeCompletions': statPoint.slopeCompletions,
              'slopeConfidenceLevel': statPoint.slopeConfidenceLevel,
              'slopeConsistency': statPoint.slopeConsistency,
              'slopeDifficultyRating': statPoint.slopeDifficultyRating,
            })
        .toList();
  }

  List<DateTime> dbListToDates(input) {
    if (input.isNotEmpty) {
      return input.map<DateTime>((date) {
        if (date is Map<String, dynamic>) {
          return date['date'].toDate() as DateTime;
        } else {
          print('weird formatting, used DateTime.now() for this one.');
          return DateTime.now(); // Handle unexpected format
        }
      }).toList();
    } else {
      return [];
    }
  }

// Database functions

  Future<void> loadUserData(context) async {
    // throw Error(); // just mocking an error
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      String uid = _auth.currentUser!.uid.toString();
      for (var user in usersSnapshot.docs) {
        if (user.get('uid') == uid) {
          print('loading user...');
          Provider.of<UserLocalStorage>(context, listen: false).currentUser =
              UserModel(
                  username: user.get('username'),
                  bio: user.get('bio'),
                  email: user.get('email'),
                  uid: user.get('uid'),
                  userLevel: user.get('userLevel'),
                  userXP: user.get('userXP'),
                  isAdmin: user.get('isAdmin'));
          Provider.of<UserLocalStorage>(context, listen: false)
              .notifyListeners();
        }
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> uploadUserData(context) async {
    // throw Error();
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var user in usersSnapshot.docs) {
        if (user.get('uid') ==
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .uid) {
          await user.reference.set({
            'username': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .username,
            'bio': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .bio,
            'email': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .email,
            'userLevel': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userLevel,
            'userXP': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .userXP,
            'isAdmin': Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .isAdmin,
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
        print('isAdmin: ' +
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .isAdmin
                .toString());
        syncLastUpdated(context);
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> syncLastUpdated(context) async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var user in usersSnapshot.docs) {
        if (user.get('uid') ==
            Provider.of<UserLocalStorage>(context, listen: false)
                .currentUser
                .uid) {
          await user.reference.set({
            'lastUpdated': DateTime.now(),
          }, SetOptions(merge: true));
        }
      }
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  // void loadHabits2(context) async {
  //   if (HabitRepository.getHabitData().isNotEmpty) {
  //     HabitRepository.loadData(context);
  //     Provider.of<HabitManager>(context, listen: false).sortHabits();
  //     for (Habit habit
  //         in Provider.of<HabitManager>(context, listen: false).habits) {
  //       print(habit.title);
  //       print(habit.streak);
  //     }
  //   } else {
  //     loadHabits(context);
  //   }
  // }

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
            dbListToDates(habit.get('daysCompleted'));

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
        loadedHabit.stats = dbListToStatPoints(habit.get('stats'));
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
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
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
      'stats': dbStatPointsToMap(habit.stats),
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
        'stats': dbStatPointsToMap(habit.stats),
      });
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> updateHabit(Habit habit, context) async {
    try {
      await _updateHabitDoc(habit, await getHabitByID(habit.id, context));
      syncLastUpdated(context);

      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
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

      habitsCollectionRef.doc(doc.id).delete();
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> loadStatistics(context) async {
    try {
      CollectionReference users = _firestore.collection('users');
      DocumentSnapshot userSnapshot =
          await users.doc(_auth.currentUser!.uid.toString()).get();
      if (userSnapshot.exists) {
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
                .statPoints =
            dbListToStatPoints(userSnapshot.get('stats')['statPoints']);
        Provider.of<SummaryStatisticsRepository>(context, listen: false)
                .totalHabitsCompleted =
            userSnapshot.get('stats')['totalHabitsCompleted'];
      } else {
        print('User doc does not exist.');
      }

      Provider.of<SummaryStatisticsRepository>(context, listen: false)
          .notifyListeners();
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void uploadStatistics(context) async {
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
              Provider.of<SummaryStatisticsRepository>(context, listen: false)
                  .totalHabitsCompleted,
          // Converting confidenceStats into an array of normal objects
          'statPoints': dbStatPointsToMap(
              Provider.of<SummaryStatisticsRepository>(context, listen: false)
                  .statPoints),
        }
      }, SetOptions(merge: true));

      print('stats uploaded');
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
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
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  Future<void> loadCommunityChallenges(context) async {
    try {
      QuerySnapshot communityChallengesSnapshot =
          await _firestore.collection('community-challenges').get();
      List<CommunityChallenge> newChallenges = [];
      var communityChallengesDocs = communityChallengesSnapshot.docs;
      for (var doc in communityChallengesDocs) {
        CommunityChallenge loadedChallenge = CommunityChallenge(
          description: doc.get("description"),
          id: doc.get("id"),
          startDate: doc.get("startDate").toDate(),
          endDate: doc.get("endDate").toDate(),
          requiredFullCompletions: doc.get("requiredFullCompletions"),
          currentFullCompletions: doc.get("currentFullCompletions"),
          habit: Habit(
            title: doc.get("habit")["title"],
            requiredCompletions: doc.get("habit")["requiredCompletions"],
            lastSeen: DateTime.now(),
            isCommunityHabit: true,
            id: doc.get("habit")["id"],
            resetPeriod: doc.get("habit")["resetPeriod"],
            dateCreated: doc.get("habit")["dateCreated"].toDate(),
          ),
        );
        List<ParticipantData> participantList = doc
            .get("participantDataList")
            .map<ParticipantData>(
              (element) => ParticipantData(
                user: UserModel(
                  username: element["user"]["username"],
                  bio: element["user"]["bio"] != null
                      ? element["user"]["bio"]
                      : "",
                  email: element["user"]["email"],
                  uid: element["user"]["uid"],
                  userLevel: element["user"]["userLevel"],
                  userXP: element["user"]["userXP"],
                ),
                lastSeen: element["lastSeen"].toDate(),
                fullCompletionCount: element["fullCompletionCount"],
                currentCompletions: element["currentCompletions"],
              ),
            )
            .toList();
        loadedChallenge.loadParticipants(participantList);
        for (ParticipantData participant in loadedChallenge.participants) {
          if (participant.user.uid == _auth.currentUser!.uid.toString()) {
            loadedChallenge.habit.completionsToday =
                participant.currentCompletions;
            break;
          }
        }
        newChallenges.add(loadedChallenge);
      }
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .setChallenges(newChallenges);
      UserModel currentUser =
          Provider.of<UserLocalStorage>(context, listen: false).currentUser;
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .resetDailyChallenges(context, currentUser);
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .resetWeeklyChallenges(context, currentUser);
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .resetMonthlyChallenges(context, currentUser);
      Provider.of<CommunityChallengeManager>(context, listen: false)
          .updateChallenges(context);
      print('Community challenges loaded');
      print(Provider.of<CommunityChallengeManager>(context, listen: false)
          .challenges
          .last
          .habit
          .title);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void uploadCommunityChallenges(context) async {
    try {
      CollectionReference communityChallenges =
          _firestore.collection('community-challenges');

      QuerySnapshot communityChallengesSnapshot =
          await _firestore.collection('community-challenges').get();
      for (CommunityChallenge challenge
          in Provider.of<CommunityChallengeManager>(context, listen: false)
              .challenges) {
        for (var doc in communityChallengesSnapshot.docs) {
          if (doc.get('id') == challenge.id) {
            await doc.reference.update({
              'description': challenge.description,
              'id': challenge.id,
              'startDate': challenge.startDate,
              'endDate': challenge.endDate,
              'requiredFullCompletions': challenge.requiredFullCompletions,
              'currentFullCompletions': challenge.currentFullCompletions,
              'participantDataList': challenge.participants.isNotEmpty
                  ? challenge.participants.map((element) => {
                        'user': {
                          'username': element.user.username,
                          'description': element.user.bio,
                          'email': element.user.email,
                          'uid': element.user.uid,
                          'userLevel': element.user.userLevel,
                          'userXP': element.user.userXP,
                        },
                        'lastSeen': element.lastSeen,
                        'fullCompletionCount': element.fullCompletionCount,
                        'currentCompletions': element.currentCompletions,
                      })
                  : [],
              'habit': {
                'title': challenge.habit.title,
                'requiredCompletions': challenge.habit.requiredCompletions,
                'resetPeriod': challenge.habit.resetPeriod,
                'id': challenge.habit.id,
                'dateCreated': challenge.habit.dateCreated
              },
            });
          }
        }
      }
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void addCommunityChallenge(Map<String, dynamic> newChallenge, context) async {
    try {
      CollectionReference communityChallengesRef =
          _firestore.collection('community-challenges');
      await communityChallengesRef.add(newChallenge);

      loadCommunityChallenges(context);
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void removeCommunityChallenge(int id, context) async {
    try {
      print("Removing community challenge with id: " + id.toString());
      CollectionReference communityChallengesRef =
          _firestore.collection('community-challenges');
      QuerySnapshot communityChallengesSnapshot =
          await communityChallengesRef.get();
      for (var doc in communityChallengesSnapshot.docs) {
        if (doc.get("id") == id) {
          doc.reference.delete();
        }
      }

      loadCommunityChallenges(context);
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
  }

  void editCommunityChallenge(
      int id, Map<String, dynamic> newChallenge, context) async {
    try {
      CollectionReference communityChallengesRef =
          _firestore.collection('community-challenges');
      QuerySnapshot communityChallengesSnapshot =
          await communityChallengesRef.get();
      for (var doc in communityChallengesSnapshot.docs) {
        if (doc.get("id") == id) {
          doc.reference.update(newChallenge);
        }
      }

      loadCommunityChallenges(context);
      syncLastUpdated(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          true;
    } catch (e, s) {
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
      print(s);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    return Future.error('No Habit Found for id:' + id.toString());
  }

  Future<void> loadData(context) async {
    await loadUserData(context);
    await loadHabits(context);
    await loadStatistics(context);
    await loadCommunityChallenges(context);
  }

  void uploadData(context) async {
    uploadUserData(context);
    uploadHabits(context);
    uploadStatistics(context);
    uploadCommunityChallenges(context);
  }
}

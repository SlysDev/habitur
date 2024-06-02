import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/statistics_display_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:habitur/providers/user_data.dart';
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
      'email': email,
      'uid': uid,
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

  void loadUserData(context) async {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    String uid = _auth.currentUser!.uid.toString();
    for (var user in usersSnapshot.docs) {
      if (user.get('uid') == uid) {
        print('loading user...');
        Provider.of<UserData>(context, listen: false).currentUser = UserModel(
          username: user.get('username'),
          bio: user.get('bio'),
          email: user.get('email'),
          uid: user.get('uid'),
          userLevel: int.parse(user.get('userLevel')),
          userXP: int.parse(user.get('userXP')),
        );
        Provider.of<UserData>(context, listen: false).notifyListeners();
      }
    }
  }

  void uploadUserData(context) async {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    for (var user in usersSnapshot.docs) {
      if (user.get('uid') ==
          Provider.of<UserData>(context, listen: false).currentUser.uid) {
        await user.reference.update({
          'username': Provider.of<UserData>(context, listen: false)
              .currentUser
              .username,
          'bio': Provider.of<UserData>(context, listen: false).currentUser.bio,
          'email':
              Provider.of<UserData>(context, listen: false).currentUser.email,
          'userLevel': Provider.of<UserData>(context, listen: false)
              .currentUser
              .userLevel,
          'userXP':
              Provider.of<UserData>(context, listen: false).currentUser.userXP,
        });
      }
    }
  }

  void loadHabits(context) async {
    CollectionReference users = _firestore.collection('users');
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());
    CollectionReference habitsReference = userReference.collection('habits');
    QuerySnapshot habitsSnapshot = await habitsReference.get();
    DocumentSnapshot userSnapshot = await userReference.get();
    Provider.of<UserData>(context, listen: false).currentUser.userLevel =
        userSnapshot.get('habiturRating');
    Provider.of<UserData>(context, listen: false).currentUser.username =
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

      List<DateTime> daysCompletedFormatted =
          rawListToDates(habit.get('daysCompleted'));
      List<DataPoint> confidenceStatsFormatted =
          rawListToDataPoints(habit.get('confidenceStats'));
      List<DataPoint> completionStatsFormatted =
          rawListToDataPoints(habit.get('completionStats'));

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
        requiredCompletions: habit.get('requiredCompletions'),
        requiredDatesOfCompletion: requiredDatesOfCompletionFormatted,
      );
      loadedHabit.confidenceStats = confidenceStatsFormatted;
      loadedHabit.completionStats = completionStatsFormatted;
      loadedHabit.daysCompleted = daysCompletedFormatted;
      habitList.add(loadedHabit);
    }
    Provider.of<HabitManager>(context, listen: false).loadHabits(habitList);
    Provider.of<HabitManager>(context, listen: false).resetDailyHabits();
    Provider.of<HabitManager>(context, listen: false).resetWeeklyHabits();
    Provider.of<HabitManager>(context, listen: false).resetMonthlyHabits();
  }

  void uploadHabits(context) async {
    CollectionReference users = _firestore.collection('users');
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
            .toList(),
        'confidenceStats': habit.confidenceStats
            .map((stat) => {
                  'date': stat.date,
                  'value': stat.value,
                })
            .toList(),
        'completionStats': habit.completionStats
            .map((stat) => {
                  'date': stat.date,
                  'value': stat.value,
                })
            .toList(),
      });
    }
    print('uploaded to database.');
    //// TODO: Upload hive's storage of the habit list to Firebase  <22-12-22, slys> //
  }

  void loadStatistics(context) async {
    CollectionReference users = _firestore.collection('users');
    DocumentSnapshot userSnapshot =
        await users.doc(_auth.currentUser!.uid.toString()).get();
    if (userSnapshot.exists) {
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
              .confidenceStats =
          rawListToDataPoints(userSnapshot.get('stats')['confidenceStats']);
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
              .completionStats =
          rawListToDataPoints(userSnapshot.get('stats')['completionStats']);
      Provider.of<SummaryStatisticsRepository>(context, listen: false)
              .totalHabitsCompleted =
          userSnapshot.get('stats')['totalHabitsCompleted'];
    } else {
      print('User doc does not exist.');
    }

    Provider.of<SummaryStatisticsRepository>(context, listen: false)
        .notifyListeners();
    Provider.of<StatisticsDisplayManager>(context, listen: false)
        .initStatsDisplay(context);
  }

  void uploadStatistics(context) async {
    CollectionReference users = _firestore.collection('users');
    DocumentReference userReference =
        users.doc(_auth.currentUser!.uid.toString());

    userReference.set({
      'habiturRating':
          Provider.of<UserData>(context, listen: false).currentUser.userXP,
    }, SetOptions(merge: true));

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

  void addCommunityChallenge(Map<String, dynamic> newChallenge, context) async {
    CollectionReference communityChallengesRef =
        _firestore.collection('community-challenges');
    await communityChallengesRef.add(newChallenge);

    loadCommunityChallenges(context);
  }

  void removeCommunityChallenge(int id, context) async {
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
  }

  void editCommunityChallenge(
      int id, Map<String, dynamic> newChallenge, context) async {
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
  }

  void loadCommunityChallenges(context) async {
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
              fullCompletionCount: element["fullCompletionCount"],
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
      print(
          'Latest challenge: ${newChallenges.last.habit.title}, ${newChallenges.last.id}');
    }
    Provider.of<CommunityChallengeManager>(context, listen: false)
        .resetDailyChallenges();
    Provider.of<CommunityChallengeManager>(context, listen: false)
        .resetWeeklyChallenges();
    Provider.of<CommunityChallengeManager>(context, listen: false)
        .resetMonthlyChallenges();
    Provider.of<CommunityChallengeManager>(context, listen: false)
        .setChallenges(newChallenges);
    Provider.of<CommunityChallengeManager>(context, listen: false)
        .updateChallenges(context);
    print('Community challenges loaded');
    print(Provider.of<CommunityChallengeManager>(context, listen: false)
        .challenges
        .last
        .habit
        .title);
  }

  void uploadCommunityChallenges(context) async {
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
                      'fullCompletionCount': element.fullCompletionCount,
                      'currentCompletions': element.currentCompletions,
                    })
                : [],
            'habit': {
              'title': challenge.habit.title,
              'requiredCompletions': challenge.habit.requiredCompletions,
              'resetPeriod': challenge.habit.resetPeriod,
              'dateCreated': challenge.habit.dateCreated
            },
          });
        }
      }
    }
    // first clear the collection
    // for (var doc in communityChallengesSnapshot.docs) {
    //   doc.reference.delete();
    // }
    // print('here are the challenges to be uploaded:');
    // print(Provider.of<CommunityChallengeManager>(context, listen: false)
    //     .challenges);
    // for (var challenge
    //     in Provider.of<CommunityChallengeManager>(context, listen: false)
    //         .challenges) {
    //   communityChallenges.add({
    //     'description': challenge.description,
    //     'id': challenge.id,
    //     'startDate': challenge.startDate,
    //     'endDate': challenge.endDate,
    //     'requiredFullCompletions': challenge.requiredFullCompletions,
    //     'currentFullCompletions': challenge.currentFullCompletions,
    //     'participantDataList': challenge.participants.map((element) => {
    //           'user': {
    //             'username': element.user.username,
    //             'description': element.user.description,
    //             'email': element.user.email,
    //             'uid': element.user.uid,
    //             'userLevel': element.user.userLevel,
    //             'userXP': element.user.userXP
    //           },
    //           'fullCompletionCount': element.fullCompletionCount,
    //           'currentCompletions': element.currentCompletions
    //         }),
    //     'habit': {
    //       'title': challenge.habit.title,
    //       'requiredCompletions': challenge.habit.requiredCompletions,
    //       'resetPeriod': challenge.habit.resetPeriod,
    //       'dateCreated': challenge.habit.dateCreated
    //     },
    //   });
    // }
  }

  void loadData(context) async {
    loadUserData(context);
    loadHabits(context);
    loadStatistics(context);
    loadCommunityChallenges(context);
  }

  void uploadData(context) async {
    uploadUserData(context);
    uploadHabits(context);
    uploadStatistics(context);
    uploadCommunityChallenges(context);
  }
}

List<DataPoint> rawListToDataPoints(input) {
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

List<DateTime> rawListToDates(input) {
  if (input.isNotEmpty) {
    return input.map<DateTime>((date) {
      if (date is Timestamp) {
        return date.toDate();
      } else {
        return DateTime.now(); // Handle unexpected format
      }
    }).toList();
  } else {
    return [];
  }
}

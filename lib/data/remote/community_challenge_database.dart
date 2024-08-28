import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class CommunityChallengeDatabase {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Database db = Database();
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
      print(e);
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

  void addCommunityChallenge(Map<String, dynamic> newChallenge, context) async {
    try {
      CollectionReference communityChallengesRef =
          _firestore.collection('community-challenges');
      await communityChallengesRef.add(newChallenge);

      loadCommunityChallenges(context);
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

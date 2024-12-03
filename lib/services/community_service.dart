import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../models/habit.dart';

class CommunityService with ListenableServiceMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = locator<AuthService>();
  final UserService _userService = locator<UserService>();

  CommunityService();

  List<CommunityChallenge> _challenges = [];
  DateTime _lastUpdated = DateTime.now();

  // Stream of all challenges
  Stream<List<CommunityChallenge>> get challengesStream => _firestore
          .collection('community-challenges')
          .snapshots()
          .asyncMap((snapshot) async {
        final challenges = <CommunityChallenge>[];
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            debugPrint(data.toString());
            final participants = await _loadParticipants(data['id'].toString());
            data['participantDataList'] = participants;
            CommunityChallenge challenge = CommunityChallenge(
              description: data['description'],
              id: data['id'],
              startDate: (data['startDate'] as Timestamp).toDate(),
              endDate: (data['endDate'] as Timestamp).toDate(),
              requiredFullCompletions: data['requiredFullCompletions'],
              currentFullCompletions: data['currentFullCompletions'] ?? 0,
              habit: Habit(
                title: data['habit']['title'],
                targetGoal: data['habit']['targetGoal'],
                lastSeen: DateTime.now(),
                isCommunityHabit: true,
                id: data['habit']['id'],
                resetPeriod: data['habit']['resetPeriod'],
                dateCreated:
                    (data['habit']['dateCreated'] as Timestamp).toDate(),
              ),
            );
            debugPrint(
                'community_service.dart: trying to load participants: $participants of length ${participants.length}');
            challenge.loadParticipants(participants);
            challenges.add(challenge);
          } catch (e, s) {
            debugPrint('Error loading challenge: $e, $s');
          }
        }
        return challenges;
      });

  // Stream of active challenges
  Stream<List<CommunityChallenge>> get activeChallengesStream =>
      challengesStream.map((challenges) {
        final now = DateTime.now();
        return challenges
            .where((challenge) =>
                challenge.startDate.isBefore(now) &&
                challenge.endDate.isAfter(now))
            .toList();
      });

  // Stream of a specific challenge
  Stream<CommunityChallenge> getChallengeByIdStream(String challengeId) =>
      _firestore
          .collection('community-challenges')
          .where('id', isEqualTo: int.parse(challengeId))
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isEmpty) {
          throw Exception('Challenge not found');
        }
        final doc = snapshot.docs.first;
        final data = doc.data()!;
        final participants = await _loadParticipants(data['id'].toString());
        data['participantDataList'] = participants;
        CommunityChallenge challenge = CommunityChallenge(
          description: data['description'],
          id: data['id'],
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          requiredFullCompletions: data['requiredFullCompletions'],
          currentFullCompletions: data['currentFullCompletions'] ?? 0,
          habit: Habit(
            title: data['habit']['title'],
            targetGoal: data['habit']['targetGoal'],
            lastSeen: DateTime.now(),
            isCommunityHabit: true,
            id: data['habit']['id'],
            resetPeriod: data['habit']['resetPeriod'],
            dateCreated: (data['habit']['dateCreated'] as Timestamp).toDate(),
          ),
        );
        challenge.loadParticipants(participants);
        debugPrint('Challenge loaded:');
        debugPrint(challenge
            .toString()
            .split('\n')
            .map((line) => '  $line')
            .join('\n'));
        return challenge;
      });

  Future<List<ParticipantData>> _loadParticipants(String challengeId) async {
    final participantsList = await _firestore
        .collection('community-challenges')
        .where('id', isEqualTo: int.parse(challengeId))
        .get()
        .then((snapshot) => snapshot.docs.first)
        .then((doc) => doc.get('participantDataList') as List<dynamic>);

    debugPrint(
        'Participant data from Firestore: ${participantsList.toString()}');

    final participants = participantsList
        .map((participantData) {
          try {
            final userData = participantData['user'] as Map<String, dynamic>;
            return ParticipantData(
              user: UserModel.fromMap(userData),
              currentCompletions: participantData['currentCompletions'] ?? 0,
              fullCompletionCount: participantData['fullCompletionCount'] ?? 0,
              lastSeen: participantData['lastSeen'] != null
                  ? (participantData['lastSeen'] as Timestamp).toDate()
                  : DateTime.now(),
            );
          } catch (e) {
            debugPrint('Error parsing participant data: $e');
            return null;
          }
        })
        .where((participant) => participant != null)
        .cast<ParticipantData>()
        .toList();

    debugPrint('Parsed ${participants.length} participants');
    return participants;
  }
  // for (var doc in participantsSnapshot.docs) {
  //   try {
  //     final data = doc.data();
  //     final user = await _userService.getUserById(data['user']['uid']);
  //     if (user != null) {
  //       participants.add(ParticipantData(
  //         user: user,
  //         currentCompletions: data['currentCompletions'] ?? 0,
  //         fullCompletionCount: data['fullCompletionCount'] ?? 0,
  //         lastSeen: data['lastSeen'] ?? DateTime.now(),
  //       ));
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading participant: $e');
  //   }
  // }

  Future<void> updateChallengeProgress(
      String challengeId, int newProgress) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }

    final userId = _authService.userId;
    await _firestore
        .collection('community-challenges')
        .doc(challengeId)
        .collection('participantDataList')
        .doc(userId)
        .set({
      'currentCompletions': newProgress,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> joinChallenge(String challengeId) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }

    final userId = _authService.userId;
    await _firestore
        .collection('community-challenges')
        .doc(challengeId)
        .collection('participantDataList')
        .doc(userId)
        .set({
      'currentCompletions': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> leaveChallenge(String challengeId) async {
    if (!_authService.isLoggedIn) {
      throw Exception('User not logged in');
    }

    final userId = _authService.userId;
    await _firestore
        .collection('community-challenges')
        .doc(challengeId)
        .collection('participantDataList')
        .doc(userId)
        .delete();
  }

  Future<void> loadChallenges() async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final challengesSnapshot =
          await _firestore.collection('community-challenges').get();

      _challenges = await Future.wait(
        challengesSnapshot.docs.map((doc) async {
          final data = doc.data();
          final challenge = CommunityChallenge(
            description: data['description'],
            id: data['id'],
            startDate: (data['startDate'] as Timestamp).toDate(),
            endDate: (data['endDate'] as Timestamp).toDate(),
            requiredFullCompletions: data['requiredFullCompletions'],
            currentFullCompletions: data['currentFullCompletions'] ?? 0,
            habit: Habit(
              title: data['habit']['title'],
              targetGoal: data['habit']['targetGoal'],
              lastSeen: DateTime.now(),
              isCommunityHabit: true,
              id: data['habit']['id'],
              resetPeriod: data['habit']['resetPeriod'],
              dateCreated: (data['habit']['dateCreated'] as Timestamp).toDate(),
            ),
          );

          // Load participants
          final participants = await _loadParticipants(data['id'].toString());
          challenge.loadParticipants(participants);
          return challenge;
        }),
      );

      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      rethrow;
    }
  }

  int getActiveChallengeCount() {
    return _challenges.where((challenge) {
      final now = DateTime.now();
      return challenge.startDate.isBefore(now) &&
          challenge.endDate.isAfter(now);
    }).length;
  }

  List<CommunityChallenge> getActiveChallenges() {
    return _challenges.where((challenge) {
      final now = DateTime.now();
      return challenge.startDate.isBefore(now) &&
          challenge.endDate.isAfter(now);
    }).toList();
  }

  CommunityChallenge getChallengeById(int id) {
    return _challenges.firstWhere((challenge) => challenge.id == id);
  }

  Future<void> createChallenge({
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int requiredFullCompletions,
    required Habit habit,
  }) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('User not logged in');
      }

      final challenge = CommunityChallenge(
        description: description,
        id: DateTime.now().millisecondsSinceEpoch,
        startDate: startDate,
        endDate: endDate,
        requiredFullCompletions: requiredFullCompletions,
        habit: habit,
      );

      await _firestore.collection('community-challenges').add({
        'description': challenge.description,
        'id': challenge.id,
        'startDate': Timestamp.fromDate(challenge.startDate),
        'endDate': Timestamp.fromDate(challenge.endDate),
        'requiredFullCompletions': challenge.requiredFullCompletions,
        'currentFullCompletions': 0,
        'createdBy': _authService.userId,
        'habit': {
          'title': habit.title,
          'targetGoal': habit.targetGoal,
          'id': habit.id,
          'resetPeriod': habit.resetPeriod,
          'dateCreated': Timestamp.fromDate(habit.dateCreated),
        },
      });

      await loadChallenges();
    } catch (e) {
      debugPrint('Error creating challenge: $e');
      rethrow;
    }
  }

  List<ParticipantData> getTopParticipants(int challengeId) {
    try {
      final challenge = _challenges.firstWhere((c) => c.id == challengeId);
      return challenge.getTopThreeParticipants();
    } catch (e) {
      debugPrint('Error getting top participants: $e');
      return [];
    }
  }
}

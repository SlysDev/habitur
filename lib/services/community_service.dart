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
              participants: participants,
            );
            debugPrint(
                'community_service.dart: trying to load participants: $participants of length ${participants.length}');
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
          participants: participants,
        );
        debugPrint('Challenge loaded:');
        debugPrint(challenge
            .toString()
            .split('\n')
            .map((line) => '  $line')
            .join('\n'));
        return challenge;
      });
  Future<ParticipantData> getCurrentUserParticipantData(
      String challengeId) async {
    final user = await _userService.getCurrentUser();
    if (user == null) throw Exception('Current user not found');
    List<ParticipantData> participants =
        await _loadParticipants(challengeId.toString());

    if (participants.isEmpty) {
      debugPrint('No participants found');
      CommunityChallenge challenge = getChallengeById(int.parse(challengeId));
      return ParticipantData(
        username: user.username,
        userId: user.uid,
        habit: Habit(
          title: challenge.title,
          targetGoal: challenge.targetGoal,
          lastSeen: challenge.lastSeen,
          isCommunityHabit: true,
          id: challenge.id,
          resetPeriod: challenge.resetPeriod,
          dateCreated: DateTime.now(),
        ),
      );
    }

    return participants
        .firstWhere((participant) => participant.userId == user.uid);
  }

  Future<void> updateParticipantProgress(
      {required ParticipantData participant,
      required String challengeId}) async {
    debugPrint('Updating participant progress: ${participant.toString()}');
    CommunityChallenge challenge = getChallengeById(int.parse(challengeId));
    DocumentReference doc = await getChallengeDocById(challengeId);
    DocumentSnapshot snapshot = await doc.get();
    List<ParticipantData> participants = await _loadParticipants(challengeId);

    int participantIndex =
        participants.indexWhere((p) => p.userId == participant.userId);
    if (participantIndex != -1) {
      participants[participantIndex] = participant;
    } else {
      participants.add(participant);
    }

    List<Map<String, dynamic>> participantsFormatted =
        participants.map((p) => p.toMap()).toList();
    doc.set({
      'participantDataList': participantsFormatted,
      'lastUpdated': DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<List<ParticipantData>> _loadParticipants(String challengeId) async {
    List participantsList;
    try {
      participantsList = await _firestore
          .collection('community-challenges')
          .where('id', isEqualTo: int.parse(challengeId))
          .get()
          .then((snapshot) => snapshot.docs.first)
          .then((doc) => doc.get('participantDataList'));
    } catch (e) {
      debugPrint('Error loading participants: $e');
      return [];
    }

    final participants = participantsList
        .map((participantData) {
          try {
            return ParticipantData(
              username: participantData['username'],
              userId: participantData['userId'],
              habit: Habit.fromMap(participantData['habit']),
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
    DocumentReference doc = await getChallengeDocById(challengeId);
    DocumentSnapshot docSnapshot = await doc.get();
    doc.set({
      'currentFullCompletions': newProgress,
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
            participants: await _loadParticipants(data['id'].toString()),
          );

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

  Future<DocumentReference> getChallengeDocById(String id) async {
    QuerySnapshot snapshot = await _firestore
        .collection('community-challenges')
        .where('id', isEqualTo: int.parse(id))
        .get();
    if (snapshot.size > 0) {
      return snapshot.docs.first.reference;
    } else {
      throw Exception('No challenge found with id: $id');
    }
  }

  Future<CommunityChallenge> createChallenge({
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int requiredFullCompletions,
    required Habit habit,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final challengeData = {
      'description': description,
      'id': id,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'requiredFullCompletions': requiredFullCompletions,
      'currentFullCompletions': 0,
      'habit': habit.toMap(),
      'participantDataList': [],
    };

    // Save challenge to Firestore
    await _firestore
        .collection('community-challenges')
        .doc(id.toString())
        .set(challengeData);

    // Create CommunityChallenge
    return CommunityChallenge(
      description: description,
      id: id,
      startDate: startDate,
      endDate: endDate,
      requiredFullCompletions: requiredFullCompletions,
      currentFullCompletions: 0,
      habit: habit,
      participants: [], // Start with empty participants list
    );
  }

  List<ParticipantData> getTopThreeParticipants(String challengeId) {
    final challenge =
        _challenges.firstWhere((c) => c.id.toString() == challengeId);
    final sortedParticipants = List<ParticipantData>.from(
        challenge.participantData)
      ..sort((a, b) => b.habit.totalProgress.compareTo(a.habit.totalProgress));
    return sortedParticipants.take(3).toList();
  }

  // Removed methods `enableCommunityFeatures` and `disableCommunityFeatures` as they are now in `SettingsService`.
}

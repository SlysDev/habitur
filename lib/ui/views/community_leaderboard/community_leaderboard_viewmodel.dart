import 'dart:async';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.dialogs.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:confetti/confetti.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/community_challenge.dart';
import '../../../models/participant_data.dart';
import '../../../services/community_service.dart';
import '../../../services/habit_service.dart';
import '../../../services/friends_service.dart';

class CommunityLeaderboardViewModel
    extends StreamViewModel<CommunityChallenge> {
  final _communityService = locator<CommunityService>();
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _habitStatsService = locator<HabitStatsService>();
  final _authService = locator<AuthService>();
  final _friendsService = locator<FriendsService>();
  late final ConfettiController _controller;

  String? _challengeId;

  void initialize({String? challengeId}) {
    debugPrint('Initializing leaderboard view model...');
    debugPrint('This is what\'s coming in: $challengeId');
    _challengeId = challengeId;
    debugPrint('Challenge id: $_challengeId');
    _controller = ConfettiController(duration: const Duration(seconds: 1));
    initialise();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Stream<CommunityChallenge> get stream => _challengeId != null
      ? _communityService.getChallengeByIdStream(_challengeId!)
      : _communityService.activeChallengesStream.map((challenges) {
          if (challenges.isEmpty) throw Exception('No active challenges');
          debugPrint('Here is the challenge: ${challenges.first}');
          return challenges.first;
        });

  CommunityChallenge? get currentChallenge => data;

  List<ParticipantData> get participants {
    return data?.participantData ?? [];
  }

  List<ParticipantData> get sortedParticipants {
    List<ParticipantData> sortedList = List.from(participants);
    sortedList.sort(
        (a, b) => b.habit.totalProgress.compareTo(a.habit.totalProgress));
    return sortedList;
  }

  Future<List<ParticipantData>> get friendsProgress async {
    if (data == null) return [];
    return Future.wait(data!.participantData.map((participant) async {
      bool isFriend = await _friendsService.isFriend(participant.userId);
      return isFriend ? participant : null;
    })).then((list) => list.where((participant) => participant != null).cast<ParticipantData>().toList());
  }

  double get totalProgress {
    if (data == null) return 0;
    return data!.currentFullCompletions / data!.requiredFullCompletions;
  }

  ParticipantData? get currentUserParticipantData {
    if (data == null) return null;
    return data!.participantData.firstWhere(
      (participant) => participant.userId == _authService.currentUser!.uid,
      orElse: () => ParticipantData(
        userId: '',
        username: '',
        habit: Habit(
          id: 0,
          title: '',
          currentProgress: 0,
          targetGoal: data!.targetGoal,
          resetPeriod: 'Daily',
          lastSeen: DateTime.now(),
          dateCreated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> incrementProgress() async {
    if (data == null) return;
    int challengeCurrentFullCompletions = data!.currentFullCompletions;
    if (challengeCurrentFullCompletions == data!.requiredFullCompletions) {
      return;
    }
    setBusy(true);
    try {
      ParticipantData participantData = await _communityService
          .getCurrentUserParticipantData(data!.id.toString());
      if (participantData.habit.currentProgress == data!.targetGoal) {
        return;
      }
      // increment current completions first
      if (participantData.habit.currentProgress < data!.targetGoal) {
        participantData.habit = await _habitStatsService.processHabitIncrement(
            participantData.habit,
            amount: 1,
            difficultyRating: 5) as Habit;
        if (participantData.habit.currentProgress == data!.targetGoal) {
          // update challenge completions
          challengeCurrentFullCompletions += 1;
          await _communityService.updateChallengeProgress(
            data!.id.toString(),
            challengeCurrentFullCompletions,
          );
          _controller.play();
        }
      }
      await _communityService.updateParticipantProgress(
          challengeId: data!.id.toString(), participant: participantData);
      // what is this doing?
      // await _habitService.incrementHabit(data!.id.toString(), 0);
    } catch (e, s) {
      setBusy(false);
      await _dialogService.showCustomDialog(
        title: 'Error',
        description: 'Failed to update progress: ${e.toString()}',
        variant: DialogType.modern,
      );
      debugPrint(e.toString());
      debugPrint(s.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> decrementProgress() async {
    if (data == null) return;

    setBusy(true);
    try {
      await _communityService.updateChallengeProgress(
        data!.id.toString(),
        data!.currentFullCompletions - 1,
      );
      await _habitService.decrementHabit(data!.id.toString());
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update progress: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  void navigateBack() {
    _navigationService.back();
  }

  ConfettiController get controller => _controller;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/community_challenge.dart';
import '../../../models/participant_data.dart';
import '../../../services/community_service.dart';
import '../../../services/habit_service.dart';

class CommunityLeaderboardViewModel
    extends StreamViewModel<CommunityChallenge> {
  final _communityService = locator<CommunityService>();
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  String? _challengeId;

  void initialize({String? challengeId}) {
    debugPrint('Initializing leaderboard view model...');
    debugPrint('This is what\'s coming in: $challengeId');
    _challengeId = challengeId;
    debugPrint('Challenge id: $_challengeId');
    initialise();
  }

  @override
  Stream<CommunityChallenge> get stream => _challengeId != null
      ? _communityService.getChallengeByIdStream(_challengeId!)
      : _communityService.activeChallengesStream.map((challenges) {
          if (challenges.isEmpty) throw Exception('No active challenges');
          return challenges.first;
        });

  CommunityChallenge? get currentChallenge => data;

  List<ParticipantData> get participants {
    return data?.participantData ?? [];
  }

  double get totalProgress {
    if (data == null) return 0;
    return data!.currentFullCompletions / data!.requiredFullCompletions;
  }

  Future<void> incrementProgress() async {
    if (data == null) return;
    int challengeCurrentFullCompletions = data!.currentFullCompletions;
    setBusy(true);
    try {
      ParticipantData participantData = await _communityService
          .getCurrentUserParticipantData(data!.id.toString());
      if (participantData.habit.currentProgress == data!.targetGoal) {
        return;
      }
      // increment current completions first
      if (participantData.habit.currentProgress < data!.targetGoal) {
        participantData.habit.currentProgress += 1;
        if (participantData.habit.currentProgress == data!.targetGoal) {
          // update participant full completions
          participantData.habit.totalProgress += 1;
          // update challenge completions
          challengeCurrentFullCompletions += 1;
          await _communityService.updateChallengeProgress(
            data!.id.toString(),
            challengeCurrentFullCompletions,
          );
        }
      }
      await _communityService.updateParticipantProgress(
          challengeId: data!.id.toString(), participant: participantData);
      await _habitService.incrementHabit(data!.id.toString(), 0);
    } catch (e, s) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update progress: ${e.toString()}',
      );
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
}

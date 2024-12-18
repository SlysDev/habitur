import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/community_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/network_service.dart';
import 'package:habitur/services/user_service.dart';

class CommunityChallengeCardViewModel extends BaseViewModel {
  final _communityService = locator<CommunityService>();
  final _habitService = locator<HabitService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userService = locator<UserService>();
  final _networkService = locator<NetworkService>();

  final CommunityChallenge challenge;

  CommunityChallengeCardViewModel({required this.challenge});

  List<ParticipantData> get participants => challenge.participantData;

  bool get isJoined =>
      participants.any((p) => p.userId == _authService.currentUser?.uid);

  List<ParticipantData> get topParticipants {
    final sorted = List<ParticipantData>.from(participants)
      ..sort(
          (a, b) => b.habit.currentProgress.compareTo(a.habit.currentProgress));
    return sorted.take(3).toList();
  }

  double get totalProgress {
    return challenge.currentFullCompletions / challenge.requiredFullCompletions;
  }

  bool get isConnected => _networkService.isConnected;

  double get userProgress {
    final user = _userService.currentUser;
    if (user == null) {
      return 0.0;
    }
    final currentCompletions = challenge.currentFullCompletions;
    final requiredCompletions = challenge.requiredFullCompletions;
    return currentCompletions / requiredCompletions;
  }

  bool get isCompletedByCurrentUser {
    final currentUserParticipant = participants.firstWhere(
      (p) => p.userId == _authService.currentUser?.uid,
      orElse: () => ParticipantData(
        username: '',
        userId: '',
        habit: Habit.fromSharedHabit(challenge),
      ),
    );
    return currentUserParticipant.habit.totalProgress > 0;
  }

  double get currentUserCompletionProgress {
    final currentUserParticipant = participants.firstWhere(
      (p) => p.userId == _authService.currentUser?.uid,
      orElse: () => ParticipantData(
        username: '',
        userId: '',
        habit: Habit.fromSharedHabit(challenge),
      ),
    );
    final targetGoal = challenge.targetGoal;
    final currentProgress = currentUserParticipant.habit.currentProgress;
    return currentProgress / targetGoal;
  }

  Future<void> navigateToChallengeOverview() async {
    debugPrint(
        'Navigating to challenge overview... w/ challenge id: ${challenge.id}');
    await _navigationService.navigateToCommunityLeaderboardView(
      challengeId: challenge.id.toString(),
    );
  }

  Future<void> joinChallenge() async {
    if (!_networkService.isConnected) {
      await _dialogService.showDialog(
        title: 'No Internet Connection',
        description: 'Please check your connection and try again.',
      );
      return;
    }

    try {
      setBusy(true);
      await _communityService.joinChallenge(challenge.id.toString());
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to join challenge: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> leaveChallenge() async {
    if (!_networkService.isConnected) {
      await _dialogService.showDialog(
        title: 'No Internet Connection',
        description: 'Please check your connection and try again.',
      );
      return;
    }

    try {
      setBusy(true);
      await _communityService.leaveChallenge(challenge.id.toString());
      notifyListeners();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to leave challenge: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }
}

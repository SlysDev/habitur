import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
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

  bool get isJoined => challenge.participants
      .any((p) => p.user.uid == _authService.currentUser?.uid);

  List<ParticipantData> get topParticipants {
    final sorted = List<ParticipantData>.from(challenge.participants)
      ..sort((a, b) => b.currentCompletions.compareTo(a.currentCompletions));
    return sorted.take(3).toList();
  }

  double get totalProgress {
    return challenge.currentFullCompletions / challenge.requiredFullCompletions;
  }

  bool get isConnected => _networkService.isConnected;

  double get userProgress {
    final user = _userService.currentUser;
    final habit = challenge.habit;
    final habitId = challenge.habit.id;
    if (user == null || habit == null || habitId == null) {
      return 0.0;
    }
    final currentCompletions = habit.currentProgress;
    final requiredCompletions = habit.targetGoal;
    return currentCompletions / requiredCompletions;
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

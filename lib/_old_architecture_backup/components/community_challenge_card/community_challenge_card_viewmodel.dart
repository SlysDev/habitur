import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/community_challenge.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/community_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/ui/views/community_leaderboard/community_leaderboard_view.dart';

import '../../services/network_service.dart';
import '../../services/user_service.dart';

class CommunityChallengeCardViewModel
    extends StreamViewModel<CommunityChallenge> {
  final _communityService = locator<CommunityService>();
  final _habitService = locator<HabitService>();
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _userService = locator<UserService>();
  final _networkService = locator<NetworkService>();

  final String challengeId;

  CommunityChallengeCardViewModel({required this.challengeId});

  @override
  Stream<CommunityChallenge> get stream =>
      _communityService.getChallengeByIdStream(challengeId);

  CommunityChallenge get challenge => data!;

  bool get isJoined =>
      data?.participants
          .any((p) => p.user.uid == _authService.currentUser?.uid) ??
      false;

  List<ParticipantData> get topParticipants {
    if (data == null) return [];
    final sorted = List<ParticipantData>.from(data!.participants)
      ..sort((a, b) => b.currentCompletions.compareTo(a.currentCompletions));
    return sorted.take(3).toList();
  }

  double get totalProgress {
    if (data == null) return 0;
    return data!.currentFullCompletions / data!.requiredFullCompletions;
  }

  double get userProgress => (_currentParticipant?.currentCompletions ??
          0 / challenge.habit.targetGoal)
      .toDouble();

  ParticipantData? _currentParticipant;

  ParticipantData? get currentParticipant => _currentParticipant;

  bool get isConnected => _networkService.isConnected;

  Future<void> initialize() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        _currentParticipant = challenge.participants
            .firstWhere((p) => p.user.uid == currentUser.uid);
        notifyListeners();
      }
    } catch (e) {
      // User is not a participant
      _currentParticipant = null;
      notifyListeners();
    }
  }

  Future<void> joinChallenge() async {
    if (!_authService.isLoggedIn) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'You must be logged in to join a challenge',
      );
      return;
    }

    setBusy(true);
    try {
      await _communityService.joinChallenge(challengeId);
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
    setBusy(true);
    try {
      await _communityService.leaveChallenge(challengeId);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to leave challenge: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> completeChallenge() async {
    try {
      setBusy(true);
      await _communityService.updateChallengeProgress(
          challenge.id.toString(), challenge.currentFullCompletions + 1);
      await _habitService.completeHabit(challenge.habit.id.toString());
      await initialize();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to complete challenge: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> decrementProgress() async {
    try {
      setBusy(true);
      await _communityService.updateChallengeProgress(
          challenge.id.toString(), challenge.currentFullCompletions - 1);
      await _habitService.uncompleteHabit(challenge.habit.id.toString());
      await initialize();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to decrement progress: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> navigateToLeaderboard() async {
    await _navigationService.navigateToView(
      CommunityLeaderboardView(challengeId: challengeId),
    );
  }

  void navigateToEdit() {
    _navigationService.navigateTo(
      '/edit-community-challenge',
      arguments: challenge,
    );
  }

  void navigateToChallengeOverview() {
    _navigationService.navigateTo(
      '/community-challenge-overview',
      arguments: challenge,
    );
  }
}

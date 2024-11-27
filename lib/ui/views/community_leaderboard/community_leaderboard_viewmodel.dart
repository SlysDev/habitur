import 'dart:async';
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
    _challengeId = challengeId;
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

  List<ParticipantData> get participants => data?.participants ?? [];

  double get totalProgress {
    if (data == null) return 0;
    return data!.currentFullCompletions / data!.requiredFullCompletions;
  }

  Future<void> incrementProgress() async {
    if (data == null) return;

    setBusy(true);
    try {
      await _communityService.updateChallengeProgress(
        data!.id.toString(),
        data!.currentFullCompletions + 1,
      );
      await _habitService.completeHabit(data!.habit.id.toString());
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update progress: ${e.toString()}',
      );
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
      await _habitService.uncompleteHabit(data!.habit.id.toString());
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to update progress: ${e.toString()}',
      );
    } finally {
      setBusy(false);
    }
  }

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        _navigationService.navigateTo(Routes.habitsView);
        break;
      case 1:
        _navigationService.navigateTo(Routes.statisticsView);
        break;
      case 2:
        // Already on community
        break;
      case 3:
        _navigationService.navigateTo(Routes.settingsView);
        break;
    }
  }
}

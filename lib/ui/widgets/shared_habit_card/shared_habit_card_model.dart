import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.dialogs.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/progress.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SharedHabitCardModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _statsCalculationService = locator<StatsCalculationService>();
  late final ConfettiController _controller;

  SharedHabit sharedHabit;
  double oldConfidenceLevel = 0;
  double newConfidenceLevel = 0;

  SharedHabitCardModel({required this.sharedHabit}) {
    _controller = ConfettiController(duration: const Duration(seconds: 1));
    oldConfidenceLevel = _getCurrentUserConfidenceLevel();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gets the current progress of the shared habit
  Progress get userProgress => sharedHabit.participantData
      .where((p) => p.userId == _userService.currentUser?.uid)
      .first
      .habit
      .progress;

  /// Gets the completion percentage for UI display
  double get userProgressPercentage => userProgress.percentage;

  /// Gets a formatted string representation of the progress
  String get userProgressText => userProgress.toString();

  bool get hasCurrentUserCompleted => sharedHabit.participantData
      .where((p) => p.userId == _userService.currentUser?.uid)
      .first
      .habit
      .isCompleted;

  bool get isCurrentUserAuthor =>
      sharedHabit.author?.uid == _userService.currentUser?.uid;

  Future<void> incrementSharedHabit() async {
    try {
      if (sharedHabit
              .getParticipantHabitById(_userService.currentUser?.uid ?? '')
              ?.isCompleted ??
          false) return;
      setBusy(true);
      final difficulty = await showDifficultyPopup();
      debugPrint('Incrementing shared habit with difficulty: $difficulty');
      final currentUser = _userService.currentUser;
      if (currentUser == null) return;
      try {
        UserModel? userPreCompletion = _userService.currentUser;
        int initialUserLevel = userPreCompletion?.userLevel ?? 1;
        final currentCompletions = _getCurrentUserProgress();
        debugPrint('Current completions: $currentCompletions');
        if (currentCompletions < sharedHabit.targetGoal) {
          _sharedHabitsService.incrementHabit(
              sharedHabit.id.toString(), difficulty);
          await loadSharedHabitData(sharedHabit.id.toString());
        }
        UserModel? userPostCompletion = _userService.currentUser;
        if (initialUserLevel < (userPostCompletion?.userLevel ?? 1)) {
          // show level up dialog
          _dialogService.showCustomDialog(
              variant: DialogType.levelUp,
              data: {"level": userPostCompletion!.userLevel});
        }

        if (sharedHabit.getParticipantHabitById(currentUser.uid)?.isCompleted ??
            false) {
          _controller.play();
        }
        newConfidenceLevel = _getCurrentUserConfidenceLevel();

        if (_statsCalculationService.isStreakMilestone(sharedHabit.streak)) {
          await _dialogService.showCustomDialog(
            variant: DialogType.streakMilestone,
            data: {"streak": sharedHabit.streak},
          );
        }
        rebuildUi();
      } catch (e) {
        debugPrint('Error incrementing shared habit: $e');
        setError(e);
      }
    } catch (e, s) {
      final error = Exception(e.toString());
      debugPrint('Error in incrementSharedHabit: $error');
      debugPrint(s.toString());
      setError(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> decrementSharedHabit() async {
    try {
      setBusy(true);
      debugPrint('Uncompleting shared habit ID: ${sharedHabit.id}');
      await _sharedHabitsService.decrementHabit(sharedHabit.id.toString());
      debugPrint('new progress: ${_getCurrentUserProgress()}');
    } catch (e) {
      final error = Exception(e.toString());
      debugPrint('Error uncompleting shared habit: $error');
      setError(error);
      await showErrorDialog(error.toString());
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> deleteSharedHabit() async {
    try {
      setBusy(true);
      debugPrint('Deleting shared habit ID: ${sharedHabit.id}');
      await _sharedHabitsService.deleteSharedHabit(sharedHabit.id.toString());
    } catch (e) {
      final error = Exception(e.toString());
      debugPrint('Error deleting shared habit: $error');
      setError(error);
      await showErrorDialog('Unable to delete shared habit. Please try again.');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> editSharedHabit() async {
    await _navigationService.navigateToEditSharedHabitView(
        habitId: sharedHabit.id.toString());
    rebuildUi();
  }

  Future<void> navigateToSharedHabitDashboard() async {
    debugPrint(
        'Navigating to shared habit dashboard for habit ID: ${sharedHabit.id}');
    _navigationService.navigateToSharedHabitDashboardView(
        sharedHabit: sharedHabit);
  }

  Future<void> showErrorDialog(String errorMessage) async {
    await _dialogService.showDialog(
      title: 'Error',
      description: errorMessage,
      buttonTitle: 'OK',
    );
    rebuildUi();
  }

  Future<double> showDifficultyPopup() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.difficultyPopup,
    );

    return response?.data ?? 5.0;
  }

  ConfettiController get controller => _controller;

  Habit getCurrentUserHabit() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) throw Exception('User not found');
    final participant = sharedHabit.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: sharedHabit));
    return participant.habit;
  }

  int _getCurrentUserProgress() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return 0;

    final participant = sharedHabit.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: sharedHabit));
    return participant.habit.currentProgress;
  }

  double _getCurrentUserConfidenceLevel() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return 0;

    final participant = sharedHabit.participantData.firstWhere(
        (p) => p.userId == currentUser.uid,
        orElse: () => ParticipantData(
            username: currentUser.username,
            userId: currentUser.uid,
            habit: sharedHabit));
    return participant.habit.confidenceLevel;
  }

  Future<void> loadSharedHabitData(String id) async {
    setBusy(true);
    try {
      debugPrint('Loading shared habit data for ID: $id');
      final updatedHabit =
          await _sharedHabitsService.getSharedHabitById(int.parse(id));
      if (updatedHabit != null) {
        sharedHabit = updatedHabit;
        debugPrint('Shared habit data loaded: ${sharedHabit.toMap()}');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading shared habit data: $e');
      setError(e);
    } finally {
      setBusy(false);
    }
  }
}

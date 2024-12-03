import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/progress.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitCardModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _activityService = locator<ActivityService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  late final ConfettiController _controller;

  Habit habit;
  bool _completed = false;
  bool get completed => _completed;

  HabitCardModel({required this.habit}) {
    _completed = habit.isCompleted;
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    _completed = habit.isCompleted;
    notifyListeners();
  }

  /// Gets the current progress of the habit
  Progress get progress => habit.progress;

  /// Gets the completion percentage for UI display
  double get progressPercentage => progress.percentage;

  /// Gets a formatted string representation of the progress
  String get progressText => progress.toString();

  Future<void> incrementHabit() async {
    if (habit.isCompleted) return;

    try {
      setBusy(true);
      final difficulty = await showDifficultyPopup();
      await _habitService.incrementHabit(habit.id.toString(), difficulty);
      debugPrint('Habit ${habit.id} completed. Adding activity...');
      await _activityService.createActivityForEvent(
          _userService.currentUser!.uid,
          _userService.currentUser!.username,
          ActivityType.habitProgress,
          habit.id.toString(),
          habit.title);
      _completed = habit.isCompleted;
      notifyListeners();

      final updatedHabit = await _habitService.getHabit(habit.id.toString());
      if (_completed && updatedHabit!.isCompleted) {
        _controller.play();
      }
    } catch (e, s) {
      final error = Exception(e.toString());
      debugPrint(error.toString());
      debugPrint(s.toString());
      setError(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> uncompleteHabit() async {
    try {
      setBusy(true);
      await _habitService.decrementHabit(habit.id.toString());
      _completed = habit.isCompleted;
      notifyListeners();
    } catch (e) {
      final error = Exception(e.toString());
      setError(error);
      await showErrorDialog(error.toString());
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> deleteHabit() async {
    try {
      setBusy(true);
      // Check if habit still exists in service before trying to delete
      final habits = _habitService.habits;
      final habitExists =
          habits.any((h) => h.id.toString() == habit.id.toString());

      if (!habitExists) {
        debugPrint('Habit ${habit.id} no longer exists in service');
        // Just rebuild UI since habit is already gone
        rebuildUi();
        return;
      }

      await _habitService.deleteHabit(habit.id.toString());
    } catch (e) {
      final error = Exception(e.toString());
      setError(error);
      await showErrorDialog('Unable to delete habit. Please try again.');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> editHabit() async {
    await _navigationService.navigateTo(Routes.editHabitView,
        arguments: EditHabitViewArguments(habitId: habit.id.toString()));
    rebuildUi();
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
}

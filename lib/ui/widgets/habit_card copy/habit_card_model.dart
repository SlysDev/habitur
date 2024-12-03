import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitCardModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  late final ConfettiController _controller;

  Habit? _habit;
  Habit get habit => _habit!;

  bool _completed = false;
  bool get completed => _completed;

  double _progress = 0.0;
  double get progress => _progress;

  ConfettiController get controller => _controller;

  HabitCardModel({
    required Habit habit,
  }) : _habit = habit {
    _completed = habit.isCompleted;
    _progress = habit.currentProgress / habit.targetGoal;
    _controller = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      _updateProgress();
    } catch (e) {
      final error = Exception(e.toString());
      setError(error);
    }
  }

  void _updateProgress() {
    if (_habit == null) return;
    _completed = _habit!.isCompleted;
    _progress = _habit!.currentProgress / _habit!.targetGoal;
    rebuildUi();
    notifyListeners();
  }

  Future<void> incrementHabit() async {
    if (_habit == null) return;

    if (_habit!.isCompleted) return;

    try {
      setBusy(true);
      final difficulty = await showDifficultyPopup();
      await _habitService.incrementHabit(_habit!.id.toString(), difficulty);
      _updateProgress();

      if (_completed && !_habit!.isCompleted) {
        _controller.play();
      }
    } catch (e) {
      final error = Exception(e.toString());
      setError(error);
      await showErrorDialog(error.toString());
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> uncompleteHabit() async {
    if (_habit == null) return;

    try {
      setBusy(true);
      await _habitService.decrementHabit(_habit!.id.toString());
      _updateProgress();
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
    if (_habit == null) return;

    try {
      setBusy(true);
      await _habitService.deleteHabit(_habit!.id.toString());
    } catch (e) {
      final error = Exception(e.toString());
      setError(error);
      await showErrorDialog(error.toString());
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> editHabit() async {
    if (_habit == null) return;
    await _navigationService.navigateTo(Routes.editHabitView,
        arguments: _habit);
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
}

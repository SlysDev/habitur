import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitCardModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  late final ConfettiController _controller;

  Habit? _habit;
  Habit get habit => _habit!;

  bool _completed = false;
  bool get completed => _completed;

  double _progress = 0.0;
  double get progress => _progress;

  ConfettiController get controller => _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> init(int index) async {
    try {
      setBusy(true);
      _controller = ConfettiController(duration: const Duration(seconds: 1));
      _habit = await _habitService.habits[index];
      _updateProgress();
    } catch (e) {
      setError(Exception(e.toString()));
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void _updateProgress() {
    if (_habit == null) return;
    _completed = _habit!.isCompleted;
    _progress = _habit!.currentProgress / _habit!.targetGoal;
    notifyListeners();
  }

  Future<void> completeHabit() async {
    if (_habit == null) return;

    try {
      setBusy(true);
      await _habitService.completeHabit(_habit!.id.toString());
      _updateProgress();

      if (_completed && !_habit!.isCompleted) {
        _controller.play();
      }
    } catch (e) {
      setError(Exception(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  Future<void> uncompleteHabit() async {
    if (_habit == null) return;

    try {
      setBusy(true);
      await _habitService.uncompleteHabit(_habit!.id.toString());
      _updateProgress();
    } catch (e) {
      setError(Exception(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteHabit() async {
    if (_habit == null) return;

    try {
      setBusy(true);
      await _habitService.deleteHabit(_habit!.id.toString());
    } catch (e) {
      setError(Exception(e.toString()));
    } finally {
      setBusy(false);
    }
  }

  Future<void> editHabit() async {
    if (_habit == null) return;
    await _navigationService.navigateTo(Routes.editHabitView,
        arguments: _habit);
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/app/app.router.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class InactiveHabitCardModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();

  Habit? _habit;
  Habit get habit => _habit!;

  double _progress = 0.0;
  double get progress => _progress;

  bool _completed = false;
  bool get completed => _completed;

  Future<void> init(int index) async {
    try {
      setBusy(true);
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

  Future<void> navigateToOverview() async {
    if (_habit == null) return;
    await _navigationService.navigateTo(Routes.habitOverviewView,
        arguments: _habit);
  }
}

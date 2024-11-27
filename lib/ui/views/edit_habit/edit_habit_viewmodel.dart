import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';

import '../../../app/app.locator.dart';

class EditHabitViewModel extends BaseViewModel {
  final String habitId;
  final _habitService = locator<HabitService>();

  final TextEditingController titleController = TextEditingController();
  String resetPeriod = 'Daily';
  int targetGoal = 1;
  bool smartNotifsEnabled = true;

  EditHabitViewModel({required this.habitId}) {
    _initializeHabit();
  }

  Future<void> _initializeHabit() async {
    if (habitId.isNotEmpty) {
      setBusy(true);
      try {
        final habit = await _habitService.getHabit(habitId);
        if (habit != null) {
          titleController.text = habit.title;
          resetPeriod = habit.resetPeriod;
          targetGoal = habit.targetGoal;
          smartNotifsEnabled = habit.smartNotifsEnabled;
        }
      } catch (e) {
        setError(e);
      }
      setBusy(false);
    }
  }

  void setResetPeriod(String period) {
    resetPeriod = period;
    notifyListeners();
  }

  void setTargetGoal(int goal) {
    targetGoal = goal;
    notifyListeners();
  }

  void setSmartNotifs(bool enabled) {
    smartNotifsEnabled = enabled;
    notifyListeners();
  }

  Future<void> saveHabit() async {
    if (titleController.text.isEmpty) {
      setError('Please enter a habit title');
      return;
    }

    setBusy(true);
    try {
      final habit = Habit(
        id: int.parse(habitId),
        title: titleController.text,
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
        resetPeriod: resetPeriod,
        targetGoal: targetGoal,
        smartNotifsEnabled: smartNotifsEnabled,
      );

      if (habitId.isEmpty) {
        await _habitService.addHabit(habit);
      } else {
        await _habitService.updateHabit(habit);
      }

      // Navigate back after successful save
      notifyListeners();
    } catch (e) {
      setError(e);
    }
    setBusy(false);
  }

  Future<void> deleteHabit() async {
    if (habitId.isEmpty) return;

    setBusy(true);
    try {
      await _habitService.deleteHabit(habitId);
      notifyListeners();
    } catch (e) {
      setError(e);
    }
    setBusy(false);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}

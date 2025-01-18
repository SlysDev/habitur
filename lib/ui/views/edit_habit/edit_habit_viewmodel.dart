import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class EditHabitViewModel extends BaseViewModel {
  final String habitId;
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();

  final TextEditingController titleController = TextEditingController();
  String resetPeriod = 'Daily';
  int targetGoal = 1;
  bool smartNotificationsEnabled = true;
  final List<String> selectedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  bool _usesMeasurement = false;
  String _measurementUnit = '';

  bool get usesMeasurement => _usesMeasurement;
  String get measurementUnit => _measurementUnit;

  String get resetPeriodNoun {
    switch (resetPeriod) {
      case 'Daily':
        return 'day';
      case 'Weekly':
        return 'week';
      case 'Monthly':
        return 'month';
      default:
        return 'day';
    }
  }

  EditHabitViewModel({required this.habitId}) {
    _initializeHabit();
  }

  Future<void> _initializeHabit() async {
    if (habitId.isNotEmpty) {
      setBusy(true);
      try {
        final habit = await _habitService.getHabit(habitId);
        if (habit != null) {
          selectedDays.clear();
          selectedDays.addAll(habit.requiredDatesOfCompletion);
          titleController.text = habit.title;
          resetPeriod = habit.resetPeriod;
          targetGoal = habit.targetGoal;
          smartNotificationsEnabled = habit.smartNotifsEnabled;
          _usesMeasurement = habit.usesMeasurement;
          _measurementUnit = habit.measurementUnit;
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

  void adjustTargetGoal(int adjustment) {
    targetGoal = (targetGoal + adjustment).clamp(1, 10);
    notifyListeners();
  }

  void setSmartNotifications(bool enabled) {
    smartNotificationsEnabled = enabled;
    notifyListeners();
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    notifyListeners();
  }

  void resetActiveDaysToDefault() {
    selectedDays.clear();
    selectedDays.addAll([
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ]);
    notifyListeners();
  }

  void setUsesMeasurement(bool value) {
    _usesMeasurement = value;
    notifyListeners();
  }

  void setMeasurementUnit(String value) {
    _measurementUnit = value;
    notifyListeners();
  }

  Future<void> saveHabit() async {
    if (titleController.text.isEmpty) {
      setError('Please enter a habit title');
      return;
    }

    setBusy(true);
    try {
      Habit originalHabit = await _habitService.getHabit(habitId) as Habit;
      final habit = originalHabit.copyWith(
        id: int.parse(habitId),
        title: titleController.text,
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
        resetPeriod: resetPeriod,
        targetGoal: targetGoal,
        smartNotifsEnabled: smartNotificationsEnabled,
        requiredDatesOfCompletion: selectedDays,
        usesMeasurement: _usesMeasurement,
        measurementUnit: _measurementUnit,
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

  navigateBack() async {
    _navigationService.back();
  }
}

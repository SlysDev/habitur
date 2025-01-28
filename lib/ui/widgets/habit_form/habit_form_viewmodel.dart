import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitFormViewModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final TextEditingController titleController = TextEditingController();

  // Initialize immediately with empty data
  HabitInterface _habitData = HabitInterface.empty();
  String _habitId = '';
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Expose getters for UI consumption
  String get resetPeriod => _habitData.resetPeriod;
  int get targetGoal => _habitData.targetGoal;
  bool get smartNotificationsEnabled => _habitData.smartNotifsEnabled;
  List<String> get selectedDays => _habitData.requiredDatesOfCompletion;
  bool get usesMeasurement => _habitData.usesMeasurement;
  String get measurementUnit => _habitData.measurementUnit;

  String get resetPeriodNoun {
    switch (_habitData.resetPeriod) {
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

  Future<void> initializeHabit(String? habitId) async {
    _habitId = habitId ?? '';
    setBusy(true);

    if (_habitId.isNotEmpty) {
      final existingHabit = await _habitService.getHabit(_habitId);
      if (existingHabit != null) {
        _habitData = existingHabit;
      }
    }

    titleController.text = _habitData.title;
    _isInitialized = true;
    setBusy(false);
    notifyListeners();
  }

  Future<void> saveHabit() async {
    setBusy(true);
    if (_habitId.isEmpty) {
      await _habitService.addHabit(_habitData as Habit);
    } else {
      await _habitService.updateHabit(_habitData as Habit);
    }
    _navigationService.back();
    setBusy(false);
  }

  void setTitle(String title) {
    _habitData.title = title;
    rebuildUi();
  }

  void setResetPeriod(String period) {
    if (period != 'Daily') {
      resetActiveDaysToDefault();
    }
    _habitData.resetPeriod = period;
    rebuildUi();
  }

  void adjustTargetGoal(int adjustment) {
    _habitData.targetGoal = (_habitData.targetGoal + adjustment).clamp(1, 10);
    rebuildUi();
  }

  void setSmartNotifications(bool enabled) {
    _habitData.smartNotifsEnabled = enabled;
    rebuildUi();
  }

  void toggleDay(String day) {
    final days = List<String>.from(_habitData.requiredDatesOfCompletion);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    _habitData.requiredDatesOfCompletion = days;
    rebuildUi();
  }

  void resetActiveDaysToDefault() {
    _habitData.requiredDatesOfCompletion = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    rebuildUi();
  }

  void setUsesMeasurement(bool value) {
    _habitData.usesMeasurement = value;
    rebuildUi();
  }

  void setMeasurementUnit(String value) {
    _habitData.measurementUnit = value;
    rebuildUi();
  }

  // Update getFormData to create a new instance
  HabitInterface getFormData() {
    return Habit(
      id: _habitData.id,
      title: titleController.text,
      dateCreated: _habitData.dateCreated,
      resetPeriod: _habitData.resetPeriod,
      targetGoal: _habitData.targetGoal,
      lastSeen: _habitData.lastSeen,
      requiredDatesOfCompletion: _habitData.requiredDatesOfCompletion,
      smartNotifsEnabled: _habitData.smartNotifsEnabled,
      usesMeasurement: _habitData.usesMeasurement,
      measurementUnit: _habitData.measurementUnit,
      streak: _habitData.streak,
      currentProgress: _habitData.currentProgress,
      totalProgress: _habitData.totalProgress,
      highestStreak: _habitData.highestStreak,
      confidenceLevel: _habitData.confidenceLevel,
    );
  }

  bool isValid() {
    return titleController.text.isNotEmpty &&
        _habitData.requiredDatesOfCompletion.isNotEmpty;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}

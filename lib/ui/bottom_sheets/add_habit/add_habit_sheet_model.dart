import 'package:flutter/material.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked_services/stacked_services.dart';

class AddHabitSheetModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _userService = locator<UserService>();
  final _activityService = locator<ActivityService>();

  final titleController = TextEditingController();

  String _resetPeriod = 'Daily';
  String get resetPeriod => _resetPeriod;

  String get resetPeriodNoun {
    switch (_resetPeriod) {
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

  final Set<String> _selectedDays = {
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  };
  Set<String> get selectedDays => _selectedDays;

  int _targetGoal = 1;
  int get targetGoal => _targetGoal;

  bool _smartNotificationsEnabled = false;
  bool get smartNotificationsEnabled => _smartNotificationsEnabled;

  void setResetPeriod(String period) {
    if (period != 'Daily') {
      resetActiveDaysToDefault();
    }
    _resetPeriod = period;
    rebuildUi();
  }

  void resetActiveDaysToDefault() {
    _selectedDays.clear();
    _selectedDays.addAll({
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    });
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    rebuildUi();
  }

  void adjustTargetGoal(int adjustment) {
    _targetGoal = (_targetGoal + adjustment).clamp(1, 10);
    rebuildUi();
  }

  void setSmartNotifications(bool enabled) {
    _smartNotificationsEnabled = enabled;
    rebuildUi();
  }

  Future<void> createHabit() async {
    if (titleController.text.isEmpty) {
      // Show error
      return;
    }

    if (_selectedDays.isEmpty) {
      // Show error
      return;
    }

    setBusy(true);

    debugPrint(
        'Creating habit that has to be completed $_targetGoal times a $_resetPeriod');

    try {
      final habit = Habit(
        title: titleController.text,
        dateCreated: DateTime.now(),
        resetPeriod: _resetPeriod,
        id: int.parse(generateUniqueId()),
        lastSeen: DateTime.now(),
        targetGoal: _targetGoal,
        requiredDatesOfCompletion: _selectedDays.toList(),
        smartNotifsEnabled: _smartNotificationsEnabled,
      );

      await _habitService.addHabit(habit);
      await _activityService.createActivityForEvent(
          _userService.currentUser!.uid,
          _userService.currentUser!.username,
          ActivityType.newHabit,
          habit.id.toString(),
          habit.title,
          metadata: {
            'targetGoal': _targetGoal,
            'frequency': _resetPeriod,
          });
      _bottomSheetService.completeSheet(SheetResponse(confirmed: true));
    } catch (e) {
      debugPrint('Error creating habit: $e');
      // Show error
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/enums/activity_type.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/activity_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/util_functions.dart';
import 'package:habitur/models/habit_interface.dart';

class AddHabitSheetModel extends BaseViewModel {
  final _habitService = locator<HabitService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _userService = locator<UserService>();
  final _activityService = locator<ActivityService>();
  final _snackbarService = locator<SnackbarService>();

  Future<void> createHabit(HabitInterface formData) async {
    if (formData.title.isEmpty) {
      _snackbarService.showCustomSnackBar(
        message: 'Title is empty',
        variant: SnackbarType.error
      );
      return;
    }

    if (formData.requiredDatesOfCompletion.isEmpty) {
      return;
    }

    setBusy(true);

    try {
      final habit = Habit(
        title: formData.title,
        dateCreated: DateTime.now(),
        resetPeriod: formData.resetPeriod,
        id: int.parse(generateUniqueId()),
        lastSeen: DateTime.now(),
        targetGoal: formData.targetGoal,
        requiredDatesOfCompletion: formData.requiredDatesOfCompletion,
        smartNotifsEnabled: formData.smartNotifsEnabled,
        usesMeasurement: formData.usesMeasurement,
        measurementUnit: formData.measurementUnit,
      );

      await _habitService.addHabit(habit);
      await _activityService.createActivityForEvent(
        _userService.currentUser!.uid,
        _userService.currentUser!.username,
        ActivityType.newHabit,
        habit.id.toString(),
        habit.title,
        metadata: {
          'targetGoal': formData.targetGoal,
          'frequency': formData.resetPeriod,
        }
      );
      _bottomSheetService.completeSheet(SheetResponse(confirmed: true));
    } catch (e) {
      debugPrint('Error creating habit: $e');
    }
    
    setBusy(false);
  }
}

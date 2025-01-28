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

  // Remove createHabit, now handled in HabitFormViewModel
}

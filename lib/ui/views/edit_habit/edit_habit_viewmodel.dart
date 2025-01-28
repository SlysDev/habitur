import 'package:flutter/material.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class EditHabitViewModel extends BaseViewModel {
  final String habitId;
  final _navigationService = locator<NavigationService>();

  EditHabitViewModel({required this.habitId});

  void navigateBack() => _navigationService.back();
}

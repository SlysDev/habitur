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
  final _habitService = locator<HabitService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  HabitInterface? habitData;

  EditHabitViewModel({required this.habitId}) {
    _initializeHabit();
  }

  Future<void> _initializeHabit() async {
    if (habitId.isNotEmpty) {
      setBusy(true);
      try {
        final habit = await _habitService.getHabit(habitId);
        if (habit != null) {
          habitData = habit;
          debugPrint('Loaded habit: ${habit.title}');
        }
        rebuildUi();
      } catch (e) {
        setError(e);
      }
      setBusy(false);
    }
  }

  Future<void> saveHabit(HabitInterface formData) async {
    debugPrint('Saving habit with title: ${formData.title}');
    setBusy(true);
    try {
      await _habitService.updateHabit(formData);
      // Update local state to reflect changes
      habitData = formData;
      rebuildUi();
      _navigationService.back();
    } catch (e) {
      setError(e);
      _snackbarService.showCustomSnackBar(
        message: 'Failed to save habit',
        variant: SnackbarType.error,
      );
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
    super.dispose();
  }

  navigateBack() async {
    _navigationService.back();
  }
}

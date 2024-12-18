import 'package:flutter/material.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class EditSharedHabitViewModel extends BaseViewModel {
  final String habitId;
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String resetPeriod = 'Daily';
  int targetGoal = 1;
  bool smartNotificationsEnabled = false;
  final List<String> selectedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<ParticipantData> selectedParticipants = [];

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

  String get currentUserId => _userService.currentUser?.uid ?? '';

  EditSharedHabitViewModel({required this.habitId}) {
    _initializeHabit();
  }

  Future<void> _initializeHabit() async {
    if (habitId.isNotEmpty) {
      setBusy(true);
      try {
        final habit =
            await _sharedHabitsService.getSharedHabitById(int.parse(habitId));
        if (habit != null) {
          selectedDays.clear();
          selectedDays.addAll(habit.requiredDatesOfCompletion);
          titleController.text = habit.title;
          descriptionController.text = habit.description ?? '';
          resetPeriod = habit.resetPeriod;
          targetGoal = habit.targetGoal;
          smartNotificationsEnabled = habit.smartNotifsEnabled;
          selectedParticipants = habit.participantData;
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

  Future<void> selectParticipants() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.selectFriends,
      data: {
        'preSelectedUsers': selectedParticipants,
      },
    );

    if (response?.confirmed == true && response?.data != null) {
      selectedParticipants = List<ParticipantData>.from(response!.data);
      notifyListeners();
    }
  }

  void removeParticipant(ParticipantData participant) {
    selectedParticipants.remove(participant);
    notifyListeners();
  }

  Future<void> saveHabit() async {
    if (titleController.text.isEmpty) {
      setError('Please enter a habit title');
      return;
    }

    setBusy(true);
    try {
      final habit = SharedHabit(
        id: int.parse(habitId),
        title: titleController.text,
        description: descriptionController.text,
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
        resetPeriod: resetPeriod,
        targetGoal: targetGoal,
        smartNotifsEnabled: smartNotificationsEnabled,
        requiredDatesOfCompletion: selectedDays,
        participantData: selectedParticipants,
        author: _userService.currentUser,
      );

      if (habitId.isEmpty) {
        await _sharedHabitsService.createSharedHabit(habit);
      } else {
        await _sharedHabitsService.updateSharedHabit(habit);
      }

      // Navigate back after successful save
      notifyListeners();
      navigateBack();
    } catch (e) {
      setError(e);
      showErrorSnackbar('Error saving habit. Please try again.');
    }
    setBusy(false);
  }

  Future<void> deleteHabit() async {
    if (habitId.isEmpty) return;

    setBusy(true);
    try {
      await _sharedHabitsService.deleteSharedHabit(habitId);
      notifyListeners();
    } catch (e) {
      setError(e);
    }
    setBusy(false);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  navigateBack() async {
    _navigationService.back();
  }
}

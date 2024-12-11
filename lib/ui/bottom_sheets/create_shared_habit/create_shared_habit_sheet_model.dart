import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CreateSharedHabitSheetModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _userService = locator<UserService>();
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _habitService = locator<HabitService>();

  String _habitName = '';
  String get habitName => _habitName;

  String _habitDescription = '';
  String get habitDescription => _habitDescription;

  String _selectedHabitType = 'Personal';
  String get selectedHabitType => _selectedHabitType;

  String _selectedResetPeriod = 'Daily';
  String get selectedResetPeriod => _selectedResetPeriod;

  bool _smartNotifsEnabled = false;
  bool get smartNotifsEnabled => _smartNotifsEnabled;

  int _targetGoal = 1;
  int get targetGoal => _targetGoal;

  List<UserModel> _selectedParticipants = [];
  List<UserModel> get selectedParticipants => _selectedParticipants;

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

  void setHabitType(String type) {
    _selectedHabitType = type;
    rebuildUi();
  }

  void setFrequency(String frequency) {
    _selectedResetPeriod = frequency;
    rebuildUi();
  }

  void setHabitName(String name) {
    _habitName = name;
    rebuildUi();
  }

  void setHabitDescription(String description) {
    _habitDescription = description;
    rebuildUi();
  }

  void setSmartNotifs(bool notifsEnabled) {
    _smartNotifsEnabled = notifsEnabled;
    rebuildUi();
  }

  void setTargetGoal(int newTargetGoal) {
    _targetGoal = newTargetGoal;
    rebuildUi();
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    rebuildUi();
  }

  void selectParticipants() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.selectFriends,
      data: {
        'preSelectedUsers': _selectedParticipants,
      },
    );

    if (response?.confirmed == true && response?.data != null) {
      _selectedParticipants = List<UserModel>.from(response!.data);
      rebuildUi();
    }
  }

  void removeParticipant(UserModel participant) {
    _selectedParticipants.remove(participant);
    rebuildUi();
  }

  Future<bool> createSharedHabit() async {
    if (_habitName.isEmpty) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Please enter a habit name',
      );
      return false;
    }

    if (_selectedParticipants.isEmpty) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Please select at least one participant',
      );
      return false;
    }

    try {
      setBusy(true);

      final currentUser = _userService.currentUser;
      if (currentUser == null) return false;

      final participantData = _selectedParticipants
          .map((user) => ParticipantData(
                user: user,
                fullCompletionCount: 0,
                lastSeen: DateTime.now(),
              ))
          .toList();

      // Add current user as a participant
      participantData.add(ParticipantData(
        user: currentUser,
        fullCompletionCount: 0,
        lastSeen: DateTime.now(),
      ));

      final sharedHabit = SharedHabit(
        title: _habitName,
        description: _habitDescription,
        participantData: participantData,
        author: currentUser,
        id: int.parse(generateUniqueId()),
        targetGoal: _targetGoal,
        resetPeriod: _selectedResetPeriod,
        dateCreated: DateTime.now(),
        lastSeen: DateTime.now(),
        requiredDatesOfCompletion: _selectedDays.toList(),
        smartNotifsEnabled: _smartNotifsEnabled,
      );

      await _sharedHabitsService.createSharedHabit(sharedHabit);
      return true;
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: 'Failed to create shared habit: $e',
      );
      return false;
    } finally {
      setBusy(false);
    }
  }

  void testHabitMixedStorage() async {
    // Create a regular habit
    final regularHabit = Habit(
      title: 'Regular Exercise',
      id: DateTime.now().millisecondsSinceEpoch,
      targetGoal: 30,
      streak: 0,
      currentProgress: 0,
      totalProgress: 0,
      resetPeriod: 'daily',
      dateCreated: DateTime.now(),
      confidenceLevel: 0.5,
      lastSeen: DateTime.now(),
      isShared: false,
    );

    // Create a shared habit
    final sharedHabit = SharedHabit(
      title: 'Group Workout',
      id: DateTime.now().millisecondsSinceEpoch + 1,
      targetGoal: 45,
      streak: 0,
      currentProgress: 0,
      totalProgress: 0,
      resetPeriod: 'daily',
      dateCreated: DateTime.now(),
      confidenceLevel: 0.7,
      lastSeen: DateTime.now(),
      participantData: [], // Empty for this example
    );

    // Create a list with mixed habit types
    final mixedHabits = <HabitInterface>[regularHabit, sharedHabit];

    // Add mixed habits to service
    await _habitService.saveInterfaceHabits(mixedHabits);

    // Verify by printing
    debugPrint(
        'Regular Habit: ${regularHabit.title}, Shared: ${regularHabit.isShared}');
    debugPrint(
        'Shared Habit: ${sharedHabit.title}, Shared: ${sharedHabit.isShared}');
    debugPrint('Habits in service: ${_habitService.habits.length}');
    debugPrint(
        'Habit Types: ${_habitService.habits.map((h) => h.runtimeType)}');
  }
}

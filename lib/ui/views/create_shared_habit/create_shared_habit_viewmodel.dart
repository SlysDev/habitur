import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/services/shared_habits_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/services/navigation_service.dart';
import 'package:stacked/stacked.dart';

class CreateSharedHabitViewModel extends BaseViewModel {
  final _sharedHabitsService = locator<SharedHabitsService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final targetGoalController = TextEditingController(text: '1');

  final List<String> habitTypes = ['Exercise', 'Study', 'Meditation', 'Reading', 'Other'];
  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly'];

  String _selectedHabitType = 'Exercise';
  String get selectedHabitType => _selectedHabitType;

  String _selectedFrequency = 'Daily';
  String get selectedFrequency => _selectedFrequency;

  final List<User> _selectedParticipants = [];
  List<User> get selectedParticipants => _selectedParticipants;

  void setHabitType(String type) {
    _selectedHabitType = type;
    notifyListeners();
  }

  void setFrequency(String? frequency) {
    if (frequency != null) {
      _selectedFrequency = frequency;
      notifyListeners();
    }
  }

  Future<void> addParticipants() async {
    final selectedUsers = await _navigationService.navigateToSelectFriendsView();
    if (selectedUsers != null && selectedUsers is List<User>) {
      for (final user in selectedUsers) {
        if (!_selectedParticipants.contains(user)) {
          _selectedParticipants.add(user);
        }
      }
      notifyListeners();
    }
  }

  void removeParticipant(User user) {
    _selectedParticipants.remove(user);
    notifyListeners();
  }

  Future<void> createSharedHabit() async {
    if (!_validateInputs()) return;

    setBusy(true);
    try {
      final currentUser = _userService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch,
        title: titleController.text,
        type: selectedHabitType,
        targetGoal: int.parse(targetGoalController.text),
        frequency: _parseFrequency(selectedFrequency),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: currentUser.uid,
      );

      final participantData = [
        ParticipantData(
          user: currentUser,
          fullCompletionCount: 0,
          currentCompletions: 0,
          lastSeen: DateTime.now(),
        ),
        ..._selectedParticipants.map((user) => ParticipantData(
              user: user,
              fullCompletionCount: 0,
              currentCompletions: 0,
              lastSeen: DateTime.now(),
            )),
      ];

      final sharedHabit = SharedHabit(
        id: habit.id,
        habit: habit,
        description: descriptionController.text,
        participantData: participantData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _sharedHabitsService.createSharedHabit(sharedHabit);
      _navigationService.back(result: sharedHabit);
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  bool _validateInputs() {
    if (titleController.text.isEmpty) {
      setError('Please enter a habit name');
      return false;
    }

    final targetGoal = int.tryParse(targetGoalController.text);
    if (targetGoal == null || targetGoal < 1) {
      setError('Please enter a valid target goal');
      return false;
    }

    if (_selectedParticipants.isEmpty) {
      setError('Please add at least one participant');
      return false;
    }

    return true;
  }

  HabitFrequency _parseFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return HabitFrequency.daily;
      case 'weekly':
        return HabitFrequency.weekly;
      case 'monthly':
        return HabitFrequency.monthly;
      default:
        return HabitFrequency.daily;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    targetGoalController.dispose();
    super.dispose();
  }
}

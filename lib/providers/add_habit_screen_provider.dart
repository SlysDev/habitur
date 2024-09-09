import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class AddHabitScreenProvider extends ChangeNotifier {
  Habit _habit = Habit(
      title: '',
      dateCreated: DateTime.now(),
      id: Random().nextInt(100000),
      resetPeriod: 'Daily',
      lastSeen: DateTime.now(),
      requiredDatesOfCompletion: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ],
      requiredCompletions: 1);

  // TextEditingController for habit title
  TextEditingController titleController = TextEditingController();
  TextEditingController requiredCompletionsController = TextEditingController();

  Habit get habit => _habit;

  set habit(Habit habit) {
    _habit = habit;
    titleController.text =
        habit.title; // Keep the controller in sync with the habit state
    notifyListeners();
  }

  void updateTitle(String newTitle) {
    _habit.title = newTitle;
    notifyListeners();
  }

  void reset() {
    _habit = Habit(
        title: '',
        dateCreated: DateTime.now(),
        id: Random().nextInt(100000),
        resetPeriod: 'Daily',
        lastSeen: DateTime.now(),
        requiredDatesOfCompletion: [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        requiredCompletions: 1);

    titleController.clear();
    requiredCompletionsController.clear();

    notifyListeners();
  }

  // Dispose the controller when not needed
  @override
  void dispose() {
    titleController.dispose();
    requiredCompletionsController.dispose();
    super.dispose();
  }
}

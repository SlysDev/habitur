import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import 'dart:collection';

class HabitManager extends ChangeNotifier {
  final List<Habit> _habits = [];
  late String weekDay;
  late String date;
  void getDay() {
    weekDay = DateFormat('EEEE').format(DateTime.now());
  }

  UnmodifiableListView<Habit> get habits {
    return UnmodifiableListView(_habits);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    updateHabits();
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    updateHabits();
  }

  void updateHabits() {
    notifyListeners();
  }

  void resetDailyHabits() {
    print(_habits);
    _habits.forEach((element) {
      if (element.resetPeriod == 'Daily') {
        element.resetHabitCompletions();
        element.completionsToday = 0;
      } else {
        return;
      }
    });
    updateHabits();
  }

  void resetWeeklyHabits() {
    _habits.forEach((element) {
      if (element.resetPeriod == 'Weekly') {
        element.resetHabitCompletions();
      } else {
        return;
      }
    });
    notifyListeners();
  }

  void resetMonthlyHabits() {
    _habits.forEach((element) {
      if (element.resetPeriod == 'Monthly') {
        element.resetHabitCompletions();
      } else {
        return;
      }
    });
    updateHabits();
  }

  bool checkDailyHabits() {
    if (weekDay != DateFormat('EEEE').format(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import 'database.dart';
import 'dart:collection';

class HabitManager extends ChangeNotifier {
  List<Habit> _habits = [];
  late List<Habit> _sortedHabits;
  late String weekDay;
  late String date;
  void getDay() {
    weekDay = DateFormat('EEEE').format(DateTime.now());
  }

  UnmodifiableListView<Habit> get habits {
    return UnmodifiableListView(_habits);
  }

  UnmodifiableListView<Habit> get sortedHabits {
    return UnmodifiableListView(_sortedHabits);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void sortHabits() {
    _sortedHabits = _habits;
    // Sorts the habits by urgency
    _sortedHabits.sort(((Habit a, Habit b) =>
        b.resetPeriod == 'Daily' && a.resetPeriod == 'Weekly' ||
                b.resetPeriod == 'Daily' && a.resetPeriod == 'Monthly' ||
                b.resetPeriod == 'Weekly' && a.resetPeriod == 'Monthly'
            ? 1
            : 0));
  }

  double calculateProgress(int habitIndex) {
    final habit = _habits[habitIndex];
    return habit.completionsToday / habit.requiredCompletions;
  }

  bool isHabitCompleted(int habitIndex) {
    final habit = _habits[habitIndex];
    return habit.completionsToday == habit.requiredCompletions;
  }

  void loadHabits(habitList) {
    _habits = habitList;
    notifyListeners();
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    notifyListeners();
  }

  void editHabit(int index, Habit newData) {
    _habits[index] = newData;
  }

  void updateHabits(context) {
    Provider.of<Database>(context, listen: false).uploadData(context);
    sortHabits();
    notifyListeners();
  }

  void resetDailyHabits() {
    _habits.forEach((element) {
      if (element.resetPeriod == 'Daily') {
        // If the task was not created today, make it incomplete
        if (DateFormat('d').format(element.lastSeen) !=
            DateFormat('d').format(DateTime.now())) {
          element.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    });
    notifyListeners();
  }

  void resetWeeklyHabits() {
    _habits.forEach((element) {
      if (element.resetPeriod == 'Weekly') {
        // If its monday but its not the same day as when the habit was last seen, reset
        if (DateFormat('d').format(element.lastSeen) == 'Monday' &&
            DateFormat('d').format(DateTime.now()) !=
                DateFormat('d').format(element.lastSeen)) {
          element.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    });
    notifyListeners();
  }

  void resetMonthlyHabits() {
    _habits.forEach((element) {
      if (element.resetPeriod == 'Monthly') {
        // If the task was not created this month, make it incomplete
        if (DateFormat('m').format(element.lastSeen) !=
            DateFormat('m').format(DateTime.now())) {
          element.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      } else {
        return;
      }
    });
    notifyListeners();
  }

  bool checkDailyHabits() {
    if (weekDay != DateFormat('EEEE').format(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
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

  void loadHabits(habitList) {
    _habits = habitList;
    notifyListeners();
  }

  void deleteHabit(context, int index) {
    int habitID = _habits[index].id;
    _habits.removeAt(index);
    Provider.of<Database>(context, listen: false).deleteHabit(context, habitID);
    notifyListeners();
  }

  void editHabit(int index, Habit newData) {
    _habits[index] = newData;
  }

  void updateHabits() {
    sortHabits();
    notifyListeners();
  }

  void resetDailyHabits(context) {
    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);
      if (element.resetPeriod == 'Daily') {
        // If the task was not created today, make it incomplete
        if (DateFormat('d').format(element.lastSeen) !=
            DateFormat('d').format(DateTime.now())) {
          if (element.completionsToday == 0) {
            element.streak = 0;
          }
          habitStatsHandler.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      }
    }

    notifyListeners();
    Provider.of<Database>(context, listen: false).uploadHabits(context);
  }

  void resetWeeklyHabits(context) {
    int getWeekOfYear(DateTime date) {
      // Adjust for potential differences in week number calculations across platforms
      // You might need to experiment with different calculations based on your requirements
      final startOfYear = DateTime(date.year, 1, 1);
      final weekNumber =
          ((date.difference(startOfYear).inDays + startOfYear.weekday) / 7)
                  .floor() +
              1;
      return weekNumber;
    }

    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);
      if (element.resetPeriod == 'Weekly') {
        final now = DateTime.now();
        final currentWeek = getWeekOfYear(now);
        final lastResetWeek = getWeekOfYear(element.lastSeen);
        if (currentWeek > lastResetWeek) {
          habitStatsHandler.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      }
    }
    notifyListeners();
    Provider.of<Database>(context, listen: false).uploadHabits(context);
  }

  void resetMonthlyHabits(context) {
    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);
      if (element.resetPeriod == 'Monthly') {
        // If the task was not created this month, make it incomplete
        if (DateFormat('m').format(element.lastSeen) !=
            DateFormat('m').format(DateTime.now())) {
          habitStatsHandler.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      }
    }
    notifyListeners();
    Provider.of<Database>(context, listen: false).uploadHabits(context);
  }

  bool checkDailyHabits() {
    if (weekDay != DateFormat('EEEE').format(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }
}

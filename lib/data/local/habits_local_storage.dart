// habit_repository.dart
import 'package:flutter/material.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';

class HabitsLocalStorage extends ChangeNotifier {
  dynamic _habitsBox;

  Future<void> init(context) async {
    try {
      print('are we initing?');
      if (Hive.isBoxOpen('habits')) {
        print('habitsBox is open');
        _habitsBox = Hive.box('habits');
      } else {
        print('habitsBox must be newly opened');
        _habitsBox = await Hive.openBox('habits');
      }
    } catch (e, s) {
      print(e);
      print(s);
      showErrorSnackbar(context, e, s);
    }
  }

  get lastUpdated => _habitsBox.get('lastUpdated');

  Future<void> deleteData(context) async {
    try {
      await Hive.deleteBoxFromDisk('habits');
    } catch (e, s) {
      print(e);
      print(s);
      showErrorSnackbar(context, e, s);
    }
  }

  Future<void> syncLastUpdated() async {
    await _habitsBox.put('lastUpdated', DateTime.now());
  }

  Future<void> addHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
    await syncLastUpdated();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
    await syncLastUpdated();
  }

  Future<void> deleteHabit(Habit habit) async {
    await _habitsBox.delete(habit.id);
    await syncLastUpdated();
  }

  List<Habit> getHabitData(context) {
    try {
      if (_habitsBox == null) {
        print('habitsBox is null');
        return [];
      }
      print(_habitsBox.values
          .toList()
          .where((element) => element is Habit)
          .toList());
      List<dynamic> allValues = _habitsBox.values.toList();
      return allValues.whereType<Habit>().toList();
    } catch (e, s) {
      print(e);
      print(s);
      showErrorSnackbar(context, e, s);
      return [];
    }
  }

  Future<void> uploadAllHabits(List<Habit> habits, context) async {
    try {
      if (_habitsBox == null) {
        await init(context);
      }
      for (Habit habit in habits) {
        await _habitsBox.put(habit.id, habit);
      }
      _habitsBox.put('lastUpdated', DateTime.now());
    } catch (e, s) {
      print(e);
      print(s);
      showErrorSnackbar(context, e, s);
    }
  }

  Future<void> loadData(context) async {
    await init(context);
    try {
      Provider.of<HabitManager>(context, listen: false)
          .loadHabits(getHabitData(context));
    } catch (e, s) {
      print(e);
      print(s);
      showErrorSnackbar(context, e, s);
    }
    Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    Provider.of<HabitManager>(context, listen: false).sortHabits();
    print('data loaded:');
    print(getHabitData(context).length);
    print(stringifyHabitData(context));
  }

  Habit? getHabitById(int id) {
    return _habitsBox.get(id);
  }

  Future<void> clearStats(context) async {
    for (Habit habit in getHabitData(context)) {
      Habit clearedHabit = habit;
      clearedHabit.completionsToday = 0;
      clearedHabit.streak = 0;
      clearedHabit.lastSeen = DateTime.now();
      clearedHabit.daysCompleted = [];
      clearedHabit.stats = [];
      clearedHabit.confidenceLevel = 0;
      clearedHabit.highestStreak = 0;
      clearedHabit.totalCompletions = 0;

      updateHabit(clearedHabit);
    }
    await syncLastUpdated();
  }

  String stringifyHabitData(context) {
    String output = "";
    for (Habit habit in getHabitData(context)) {
      print(habit.title);
      output += "${habit.title}:\n";
      output += "Completions: ${habit.completionsToday}\n";
      output += "Streak: ${habit.streak}\n";
      output += "Last seen: ${habit.lastSeen}\n";
      output += "Days Completed: ${habit.daysCompleted}\n";
    }
    return output;
  }
}

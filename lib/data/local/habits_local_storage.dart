// habit_repository.dart
import 'package:flutter/material.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';

class HabitsLocalStorage extends ChangeNotifier {
  dynamic _habitsBox;

  Future<void> init() async {
    print('are we initing?');
    if (Hive.isBoxOpen('habits')) {
      print('habitsBox is open');
      _habitsBox = Hive.box('habits');
    } else {
      print('habitsBox must be newly opened');
      _habitsBox = await Hive.openBox('habits');
    }
  }

  get lastUpdated => _habitsBox.get('lastUpdated');

  Future<void> deleteData() async {
    await Hive.deleteBoxFromDisk('habits');
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
    print('deleted habit with id ${habit.id}');
    print('does it exist now? ${getHabitById(habit.id)}');
    await syncLastUpdated();
  }

  List<Habit> getHabitData() {
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
  }

  Future<void> uploadAllHabits(List<Habit> habits) async {
    if (_habitsBox == null) {
      await init();
    }
    for (Habit habit in habits) {
      await _habitsBox.put(habit.id, habit);
    }
    _habitsBox.put('lastUpdated', DateTime.now());
  }

  Future<void> loadData(context) async {
    await init();
    try {
      Provider.of<HabitManager>(context, listen: false)
          .loadHabits(getHabitData());
    } catch (e, s) {
      print(e);
      print(s);
    }
    Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    Provider.of<HabitManager>(context, listen: false).sortHabits();
    print('data loaded:');
    print(getHabitData().length);
    print(stringifyHabitData());
  }

  Habit? getHabitById(int id) {
    return _habitsBox.get(id);
  }

  Future<void> clearStats() async {
    for (Habit habit in getHabitData()) {
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

  String stringifyHabitData() {
    String output = "";
    for (Habit habit in getHabitData()) {
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

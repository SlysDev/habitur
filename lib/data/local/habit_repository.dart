// habit_repository.dart
import 'package:flutter/material.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';

class HabitRepository extends ChangeNotifier {
  dynamic _habitsBox;

  Future<void> init() async {
    print('are we initing?');
    if (Hive.isBoxOpen('habits')) {
      print('habitsBox is open');
      _habitsBox = Hive.box<Habit>('habits');
    } else {
      print('habitsBox must be newly opened');
      _habitsBox = await Hive.openBox<Habit>('habits');
    }
  }

  Future<void> close() async {
    await Hive.close();
  }

  Future<void> addHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(Habit habit) async {
    await _habitsBox.delete(habit.id);
    print('deleted habit with id ${habit.id}');
    print('does it exist now? ${getHabitById(habit.id)}');
  }

  List<Habit> getHabitData() {
    if (_habitsBox == null) {
      print('habitsBox is null');
      return [];
    }
    return _habitsBox.values.toList();
  }

  Future<void> uploadAllHabits(List<Habit> habits) async {
    print('uploading all habits');
    for (Habit habit in habits) {
      await _habitsBox.put(habit.id, habit);
    }
  }

  Future<void> loadData(context) async {
    await init();
    print('are we loading data?');
    Provider.of<HabitManager>(context, listen: false)
        .loadHabits(getHabitData());
    Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    print('data loaded:');
    print(getHabitData().length);
    print(stringifyHabitData());
  }

  Habit? getHabitById(int id) {
    return _habitsBox.get(id);
  }

  void clearStats() {
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

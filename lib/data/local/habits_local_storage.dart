// habit_repository.dart
import 'package:flutter/material.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/util_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';

class HabitsLocalStorage extends ChangeNotifier {
  Box<dynamic>? _habitsBox;

  Future<void> init(context) async {
    try {
      if (!Hive.isBoxOpen('habits')) {
        debugPrint('Opening habits box...');
        _habitsBox = await Hive.openBox('habits');
        
        debugPrint('\n=== HABITS BOX INITIAL STATE ===');
        debugPrint('Box opened: ${_habitsBox?.isOpen}');
        debugPrint('Box name: ${_habitsBox?.name}');
        debugPrint('Box length: ${_habitsBox?.length}');
        debugPrint('Box keys: ${_habitsBox?.keys.toList()}');
        
        if (_habitsBox != null) {
          debugPrint('\nRaw values:');
          for (var key in _habitsBox!.keys) {
            var value = _habitsBox!.get(key);
            debugPrint('Key: $key, Type: ${value.runtimeType}, Value: $value');
          }
        }
        debugPrint('===============================\n');
      }
    } catch (e, s) {
      debugPrint('Error initializing habits box: $e');
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  get lastUpdated {
    if (_habitsBox == null) {
      return DateTime.now();
    }
    if (_habitsBox!.get('lastUpdated') == null) {
      _habitsBox!.put('lastUpdated', DateTime.now());
    }
    return _habitsBox!.get('lastUpdated');
  }

  Future<void> deleteData(BuildContext context) async {
    try {
      if (Hive.isBoxOpen('habits')) {
        await Hive.box('habits').close();
      }
      await Hive.deleteBoxFromDisk('habits');
      debugPrint('Habits box deleted successfully.');
    } catch (e, s) {
      debugPrint('function "deleteData" failed');
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> syncLastUpdated() async {
    await _habitsBox!.put('lastUpdated', DateTime.now());
  }

  Future<void> addHabit(Habit habit) async {
    await _habitsBox!.put(habit.id, habit);
    await syncLastUpdated();
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox!.put(habit.id, habit);
    await syncLastUpdated();
  }

  Future<void> deleteHabit(Habit habit) async {
    await _habitsBox!.delete(habit.id);
    await syncLastUpdated();
  }

  List<Habit> getHabitData(context) {
    try {
      if (_habitsBox == null) {
        debugPrint('habitsBox is null');
        return [];
      }

      debugPrint('\n=== HABITS BOX DEBUG INFO ===');
      debugPrint('Box name: ${_habitsBox!.name}');
      debugPrint('Box length: ${_habitsBox!.length}');
      debugPrint('Box keys: ${_habitsBox!.keys.toList()}');
      
      // Print each habit's basic info
      _habitsBox!.values.whereType<Habit>().forEach((habit) {
        debugPrint('\nHabit: ${habit.title}');
        debugPrint('ID: ${habit.id}');
        debugPrint('isVisible: ${habit.isVisible}');
        debugPrint('smartNotifsEnabled: ${habit.smartNotifsEnabled}');
      });
      debugPrint('===========================\n');

      List<dynamic> allValues = _habitsBox!.values.toList();
      return allValues.whereType<Habit>().toList();
    } catch (e, s) {
      debugPrint('Error in getHabitData: ${e.toString()}');
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
      return [];
    }
  }

  Habit? getHabitById(int id) {
    return _habitsBox!.get(id);
  }

  Future<void> clearStats(context) async {
    for (Habit habit in getHabitData(context)) {
      Habit clearedHabit = habit;
      clearedHabit.currentProgress = 0;
      clearedHabit.streak = 0;
      clearedHabit.lastSeen = DateTime.now();
      clearedHabit.daysCompleted = [];
      clearedHabit.stats = [];
      clearedHabit.confidenceLevel = 0;
      clearedHabit.highestStreak = 0;
      clearedHabit.totalProgress = 0;

      updateHabit(clearedHabit);
    }
    await syncLastUpdated();
  }

  Future<void> clearDuplicateHabits(context) async {
    debugPrint('clearing duplicate habits');
    try {
      List<Habit> allHabits = getHabitData(context);
      for (Habit habit in allHabits) {
        if (allHabits.where((element) => element.id == habit.id).length > 1) {
          debugPrint('clearing a habit');
          Habit duplicateHabit =
              allHabits.where((element) => element.id == habit.id).first;
          await deleteHabit(duplicateHabit);
        }
      } // clears dups
      syncLastUpdated();
      uploadAllHabits(allHabits, context);
    } catch (e, s) {
      debugPrint(e.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  String stringifyHabitData(context) {
    String output = "";
    output += "----------------------------------\n";
    output += "LS Habits:\n";
    for (Habit habit in getHabitData(context)) {
      debugPrint(habit.title);
      output += " ${habit.title}:\n";
      output += " -> Completions: ${habit.currentProgress}\n";
      output += " -> Streak: ${habit.streak}\n";
      output += " -> Last seen: ${habit.lastSeen}\n";
      output += " -> Days Completed: ${habit.daysCompleted}\n";
    }
    output += "----------------------------------\n";
    return output;
  }

  Future<void> uploadAllHabits(List<Habit> habits, context) async {
    try {
      if (_habitsBox == null) {
        await init(context);
      }
      for (Habit habit in habits) {
        await _habitsBox!.put(habit.id, habit);
      }
      _habitsBox!.put('lastUpdated', DateTime.now());
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
  }

  Future<void> loadData(context) async {
    await init(context);
    try {
      await clearDuplicateHabits(context);
      Provider.of<HabitManager>(context, listen: false)
          .loadHabits(getHabitData(context));
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      showDebugErrorSnackbar(context, e, s);
    }
    Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    debugPrint('data loaded:');
    debugPrint(getHabitData(context).length.toString());
    debugPrint(stringifyHabitData(context));
  }

  Future<void> clearData() async {
    if (_habitsBox != null && _habitsBox!.isOpen) {
      debugPrint('Clearing habits box data...');
      await _habitsBox!.clear();
      notifyListeners();
    }
  }
}

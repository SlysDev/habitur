import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/stats/habit_stats_service.dart';
import 'package:habitur/services/stats/stats_orchestration_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:habitur/util_functions.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'dart:math' as math;
import 'package:habitur/ui/widgets/habit_difficulty_popup.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _statsOrchestrationService = locator<StatsOrchestrationService>();
  final _dialogService = locator<DialogService>();

  final ReactiveValue<List<Habit>> _habits = ReactiveValue<List<Habit>>([]);
  List<Habit> get habits => _habits.value;
  Stream<List<Habit>> get habitsStream => _habits.values;

  HabitService() {
    listenToReactiveValues([_habits]);
    _initHabits();
  }

  Future<void> _initHabits() async {
    await loadHabits(); // Replace 'userId' with actual user ID
  }

  Future<void> loadHabits() async {
    debugPrint('Loading habits...');
    // Try local storage first
    var localHabits = await _localStorageService.getHabitData();
    debugPrint(
        'Local habits: ${localHabits.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');

    // If empty or forced refresh, get from database
    if (localHabits.isEmpty) {
      debugPrint('No local habits, fetching from database...');
      localHabits =
          await _databaseService.getHabits(_authService.currentUser!.uid);
      await _localStorageService.saveHabits(localHabits);
      debugPrint(
          'Fetched habits from database: ${localHabits.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');
    }

    _habits.value = localHabits;
    await resetHabits();
    notifyListeners();
    debugPrint(
        'Finished loading habits. Current habits: ${_habits.value.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');
  }

  Future<void> loadFromRemote() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _habits.value = await _databaseService.getHabits(userId);
      await _localStorageService.saveHabits(_habits.value);
      notifyListeners();
    }
  }

  loadFromLocal() async {
    _habits.value = _localStorageService.getHabitData() ?? [];
    notifyListeners();
  }

  Future<List<Habit>> getUserHabits({String? userId}) async {
    if (userId != null) {
      return await _databaseService.getHabits(userId);
    }
    return _habits.value;
  }

  Future<List<Habit>> getVisibleHabits({String? userId}) async {
    return habits.where((habit) => habit.isVisible ?? true).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    _habits.value = habits;
    await _localStorageService.saveHabits(habits);
    await _databaseService.updateAllHabits(
        _authService.currentUser!.uid, habits);
  }

  Future<void> addHabit(Habit habit) async {
    _habits.value = [..._habits.value, habit];
    await _localStorageService.saveHabits(_habits.value);
    await _databaseService.updateAllHabits(
        _authService.currentUser!.uid, _habits.value);
    notifyListeners();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.value.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits.value = [
        ..._habits.value.sublist(0, index),
        updatedHabit,
        ..._habits.value.sublist(index + 1),
      ];
      await _localStorageService.saveHabits(_habits.value);
      await _databaseService.updateHabit(
          _authService.currentUser!.uid, updatedHabit);
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    debugPrint('Attempting to delete habit with ID: $habitId');
    debugPrint(
        'Current habits before deletion: ${_habits.value.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');

    // Convert string ID to int for comparison
    final habitIdInt = int.parse(habitId);
    final habitToDelete = _habits.value.firstWhere(
      (h) => h.id == habitIdInt,
      orElse: () => throw Exception('Habit not found with ID: $habitId'),
    );
    debugPrint(
        'Found habit to delete: ID: ${habitToDelete.id}, Title: ${habitToDelete.title}');

    _habits.value = _habits.value.where((h) => h.id != habitIdInt).toList();
    debugPrint(
        'Habits after deletion: ${_habits.value.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');

    await _localStorageService.deleteHabit(habitId);
    await _databaseService.deleteHabit(_authService.currentUser!.uid, habitId);
    notifyListeners();
  }

  Future<void> incrementHabit(String habitId, double difficultyRating,
      {int amount = 1}) async {
    // Convert string ID to int for comparison
    final habitIdInt = int.parse(habitId);
    final index = _habits.value.indexWhere((h) => h.id == habitIdInt);
    if (index != -1) {
      final habit = _habits.value[index];

      // Process stats (which will also save the habit changes)
      await _statsOrchestrationService.processHabitIncrement(
        habit: habit,
        amount: amount,
        difficultyRating: difficultyRating,
      );

      // Create a new list to trigger reactivity
      _habits.value = [
        ..._habits.value.sublist(0, index),
        habit,
        ..._habits.value.sublist(index + 1),
      ];

      notifyListeners();
    }
  }

  Future<void> decrementHabit(String habitId, {int amount = 1}) async {
    // Convert string ID to int for comparison
    final habitIdInt = int.parse(habitId);
    final index = _habits.value.indexWhere((h) => h.id == habitIdInt);
    if (index != -1) {
      final habit = _habits.value[index];

      // Process stats (which will also save the habit changes)
      await _statsOrchestrationService.processHabitDecrement(
        habit: habit,
        amount: amount,
      );

      // Create a new list to trigger reactivity
      _habits.value = [
        ..._habits.value.sublist(0, index),
        habit,
        ..._habits.value.sublist(index + 1),
      ];

      notifyListeners();
    }
  }

  Future<Habit?> getHabit(String habitId) async {
    final habits = await getUserHabits();
    try {
      return habits.firstWhere((h) => h.id.toString() == habitId);
    } catch (e) {
      debugPrint('Habit not found: $habitId');
      return null;
    }
  }

  Future<List<Habit>> getTodaysDueHabits() async {
    final habits = await getUserHabits();
    return habits.where((h) => !h.isCompleted && isDue(h)).toList();
  }

  bool isDue(Habit habit) {
    if (habit.requiredDatesOfCompletion.isEmpty) {
      return false;
    }
    return habit.requiredDatesOfCompletion
            .contains(DateFormat('EEEE').format(DateTime.now())) &&
        !habit.isCompleted;
  }

  Future<void> resetHabits() async {
    await resetDailyHabits();
    await resetWeeklyHabits();
    await resetMonthlyHabits();
    await calculateHabitStats();
  }

  Future<void> resetDailyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'daily' &&
          habit.currentProgress > 0) {
        habit.progress.reset();
        hasChanges = true;
      }
    }
    if (hasChanges) {
      await saveHabits(habits);
    }
  }

  Future<void> resetWeeklyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'weekly' && habit.isCompleted) {
        habit.progress.reset();
        hasChanges = true;
      }
    }
    if (hasChanges) {
      await saveHabits(habits);
    }
  }

  Future<void> resetMonthlyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'monthly' && habit.isCompleted) {
        habit.progress.reset();
        hasChanges = true;
      }
    }
    if (hasChanges) {
      await saveHabits(habits);
    }
  }

  Future<void> calculateHabitStats() async {
    final habits = await getUserHabits();
    bool hasChanges = false;

    for (var habit in habits) {
      bool habitChanged = false;

      // Calculate streak
      if (habit.lastSeen != null) {
        final daysSinceLastSeen =
            DateTime.now().difference(habit.lastSeen).inDays;
        if (daysSinceLastSeen > 1 && habit.streak != 0) {
          habit.streak = 0;
          habitChanged = true;
        }
      }

      if (habitChanged) {
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveHabits(habits);
    }
  }

  List<DateTime> getDaysCompleted(Habit habit) {
    return habit.daysCompleted;
  }

  double calculateConsistencyFactor(Habit habit) {
    if (habit.daysCompleted.isEmpty) return 0.0;

    // Sort days completed
    habit.daysCompleted.sort();

    // Calculate average gap between completions
    double totalGap = 0;
    int gapCount = 0;

    for (int i = 1; i < habit.daysCompleted.length; i++) {
      final gap =
          habit.daysCompleted[i].difference(habit.daysCompleted[i - 1]).inDays;
      totalGap += gap;
      gapCount++;
    }

    if (gapCount == 0) return 1.0; // Perfect consistency for single completion

    final averageGap = totalGap / gapCount;
    // Convert average gap to a 0-1 scale where smaller gaps mean higher consistency
    return 1.0 / (1.0 + averageGap);
  }
}

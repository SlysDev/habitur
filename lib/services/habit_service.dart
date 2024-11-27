import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/auth_service.dart';
import 'package:habitur/services/database_service.dart';
import 'package:habitur/services/local_storage_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:stacked/stacked.dart';

class HabitService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();

  final ReactiveValue<List<Habit>> _habits = ReactiveValue<List<Habit>>([]);
  List<Habit> get habits => _habits.value;

  HabitService() {
    listenToReactiveValues([_habits]);
    _initHabits();
  }

  Future<void> _initHabits() async {
    await loadHabits(); // Replace 'userId' with actual user ID
  }

  Future<void> loadHabits() async {
    // Try local storage first
    _habits.value = await _localStorageService.getHabits() ?? [];

    // If empty or forced refresh, get from database
    if (_habits.value.isEmpty) {
      _habits.value =
          await _databaseService.getHabits(_authService.currentUser!.uid);
      await _localStorageService.saveHabits(_habits.value);
    }
    notifyListeners();
  }

  Future<void> loadFromRemote() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _habits.value = await _databaseService.getHabits(userId);
      await _localStorageService.saveHabits(_habits.value);
      notifyListeners();
    }
  }

  Future<void> loadFromLocal() async {
    _habits.value = await _localStorageService.getHabits() ?? [];
    notifyListeners();
  }

  Future<List<Habit>> getUserHabits({String? userId}) async {
    if (userId != null) {
      return await _databaseService.getHabits(userId);
    }
    return habits;
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
    final habits = await getUserHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final habits = await getUserHabits();
    final index =
        habits.indexWhere((h) => h.id.toString() == updatedHabit.id.toString());
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = await getUserHabits();
    habits.removeWhere((h) => h.id.toString() == habitId);
    await saveHabits(habits);
  }

  Future<void> completeHabit(String habitId) async {
    final habits = await getUserHabits();
    final index = habits.indexWhere((h) => h.id.toString() == habitId);
    if (index != -1) {
      final habit = habits[index];
      habit.currentProgress = habit.targetGoal; // This will trigger isCompleted
      habit.lastSeen = DateTime.now();
      habit.totalProgress++;

      if (habit.streak == 0)
        habit.streak = 1;
      else
        habit.streak++;

      // Update highest streak if current streak is higher
      if (habit.streak > (habit.highestStreak)) {
        habit.highestStreak = habit.streak;
      }

      // Add completion date to days completed
      if (!habit.daysCompleted.contains(DateTime.now())) {
        habit.daysCompleted.add(DateTime.now());
      }

      habits[index] = habit;
      await saveHabits(habits);

      // Update stats
      await calculateHabitStats();
    }
  }

  Future<void> uncompleteHabit(String habitId) async {
    final habits = await getUserHabits();
    final index = habits.indexWhere((h) => h.id.toString() == habitId);
    if (index != -1) {
      final habit = habits[index];
      habit.currentProgress = 0; // This will trigger isCompleted
      if (habit.streak > 0) {
        habit.streak--;
      }
      habit.totalProgress--;

      // Remove today from days completed if it exists
      habit.daysCompleted
          .removeWhere((date) => isSameDay(date, DateTime.now()));

      habits[index] = habit;
      await saveHabits(habits);

      // Update stats
      await calculateHabitStats();
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
    return habits.where((h) => h.isCompleted).toList();
  }

  Future<void> resetDailyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'daily' && habit.isCompleted) {
        habit.currentProgress = 0;
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
        habit.currentProgress = 0;
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
        habit.currentProgress = 0;
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

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/shared_habit.dart';
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
import 'package:habitur/services/notification_scheduling_service.dart';

class HabitService with ListenableServiceMixin {
  final _databaseService = locator<DatabaseService>();
  final _localStorageService = locator<LocalStorageService>();
  final _authService = locator<AuthService>();
  final _statsOrchestrationService = locator<StatsOrchestrationService>();
  final _dialogService = locator<DialogService>();

  final ReactiveValue<List<HabitInterface>> _habits =
      ReactiveValue<List<HabitInterface>>([]);
  List<HabitInterface> get habits => _habits.value;
  Stream<List<HabitInterface>> get habitsStream =>
      _habits.values;

  HabitService() {
    listenToReactiveValues([_habits]);
    _initHabits();
  }

  Future<void> _initHabits() async {
    await loadHabits(); // Replace 'userId' with actual user ID
  }

  // Methods for NORMAL HABITS

  Future<void> loadHabits() async {
    debugPrint('Loading habits...');
    // Try local storage first
    var localHabits = _localStorageService.getHabitData();
    debugPrint(
        'Local habits: ${localHabits.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');

    // If empty or forced refresh, get from database
    if (localHabits.isEmpty) {
      debugPrint('No local habits, fetching from database...');
      localHabits = await _databaseService
          .getInterfaceHabits(_authService.currentUser!.uid);
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
      _habits.value = await getUserHabits(userId: userId);
      await _localStorageService.saveHabits(_habits.value);
      notifyListeners();
    }
  }

  loadFromLocal() async {
    _habits.value = _localStorageService.getHabitData();
    notifyListeners();
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

    _habits.value =
        _habits.value.where((h) => h.id != habitIdInt).toList();
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

  Future<List<HabitInterface>> getTodaysDueHabits() async {
    final habits = await getUserHabits();
    return habits.where((h) => !h.isCompleted && isDue(h)).toList();
  }

  bool isDue(HabitInterface habit) {
    if (habit.requiredDatesOfCompletion.isEmpty) {
      return false;
    }
    return habit.requiredDatesOfCompletion
            .contains(DateFormat('EEEE').format(DateTime.now())) &&
        !habit.isCompleted;
  }

  int getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return ((date.difference(startOfYear).inDays + startOfYear.weekday) / 7)
            .floor() +
        1;
  }

  Future<void> resetDailyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    bool needsNotificationReschedule = false;

    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'daily' &&
          habit.daysCompleted.isNotEmpty) {
        final lastCompletionDate = habit.daysCompleted.last;
        final today = DateTime.now();

        // Normalize dates to midnight
        final lastCompletionNormalized = DateTime(lastCompletionDate.year,
            lastCompletionDate.month, lastCompletionDate.day);
        final todayNormalized = DateTime(today.year, today.month, today.day);

        final daysDifference =
            todayNormalized.difference(lastCompletionNormalized).inDays;

        if (daysDifference > 0) {
          int missedRequiredDays = 0;

          // Check each missed day
          for (int i = 1; i <= daysDifference; i++) {
            final missedDay = todayNormalized.subtract(Duration(days: i));
            final dayOfWeek = DateFormat('EEEE').format(missedDay);

            if (habit.requiredDatesOfCompletion.contains(dayOfWeek)) {
              missedRequiredDays++;
            }
          }

          // Reset progress if any required days were missed
          if (missedRequiredDays >= 1) {
            habit.resetProgress();
            hasChanges = true;

            // If habit has smart notifications enabled, mark for rescheduling
            if (habit.smartNotifsEnabled) {
              needsNotificationReschedule = true;
            }
          }

          // Reset streak only if multiple required days were missed
          if (missedRequiredDays > 1) {
            habit.streak = 0;
            hasChanges = true;
          }
        }
      }
    }

    if (hasChanges) {
      await saveHabits(habits);

      // If any habits with smart notifications were reset, reschedule notifications
      if (needsNotificationReschedule) {
        await locator<NotificationSchedulingService>()
            .rescheduleNotifications();
      }
    }
  }

  Future<void> resetWeeklyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    bool needsNotificationReschedule = false;

    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'weekly' &&
          habit.daysCompleted.isNotEmpty) {
        final now = DateTime.now();
        final currentWeek = getWeekOfYear(now);
        final lastCompletedDay = habit.daysCompleted.last;
        final lastCompletedWeek = getWeekOfYear(lastCompletedDay);

        // Reset completions if we're in a new week
        if (currentWeek > lastCompletedWeek) {
          habit.resetProgress();
          hasChanges = true;

          if (habit.smartNotifsEnabled) {
            needsNotificationReschedule = true;
          }
        }

        // Reset streak if more than a week has passed
        if (now.difference(lastCompletedDay).inDays >= 7) {
          habit.streak = 0;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      await saveHabits(habits);

      if (needsNotificationReschedule) {
        await locator<NotificationSchedulingService>()
            .rescheduleNotifications();
      }
    }
  }

  Future<void> resetMonthlyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    bool needsNotificationReschedule = false;

    for (var habit in habits) {
      if (habit.resetPeriod.toLowerCase() == 'monthly' &&
          habit.daysCompleted.isNotEmpty) {
        final now = DateTime.now();
        final currentMonth = now.month;
        final lastCompletedDay = habit.daysCompleted.last;
        final lastCompletedMonth = lastCompletedDay.month;

        // Also check year to handle year transitions correctly
        bool isNewMonth = now.year > lastCompletedDay.year ||
            (now.year == lastCompletedDay.year &&
                currentMonth > lastCompletedMonth);

        // Reset completions if we're in a new month
        if (isNewMonth) {
          habit.resetProgress();
          hasChanges = true;

          if (habit.smartNotifsEnabled) {
            needsNotificationReschedule = true;
          }
        }

        // Reset streak if more than a month has passed
        if (now.difference(lastCompletedDay).inDays >= 30) {
          habit.streak = 0;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      await saveHabits(habits);

      if (needsNotificationReschedule) {
        await locator<NotificationSchedulingService>()
            .rescheduleNotifications();
      }
    }
  }

  Future<void> resetHabits() async {
    await resetDailyHabits();
    await resetWeeklyHabits();
    await resetMonthlyHabits();
    await calculateHabitStats();
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

  List<DateTime> getDaysCompleted(HabitInterface habit) {
    return habit.daysCompleted;
  }

  // Methods for INTERFACE HABITS

  Future<void> saveHabits(List<HabitInterface> habits) async {
    _habits.value = habits;
    for (HabitInterface habit in _habits.value) {
      debugPrint(habit.toString());
    }
    await _localStorageService.saveHabits(habits);
    await _databaseService.updateAllInterfaceHabits(
        _authService.currentUser!.uid, habits);
  }

  Future<List<HabitInterface>> getUserHabits({String? userId}) async {
    if (userId != null) {
      // Assuming _databaseService has a method to fetch interface habits
      return await _databaseService.getInterfaceHabits(userId);
    }
    return _habits.value;
  }

  Future<List<HabitInterface>> getVisibleHabits(
      {String? userId}) async {
    return _habits.value
        .where((habit) => habit.isVisible ?? true)
        .toList();
  }

  Future<void> addHabit(HabitInterface habit) async {
    _habits.value = [..._habits.value, habit];
    // Uncomment when implementations are ready
    // await _localStorageService.saveInterfaceHabits(_interfaceHabits.value);
    // await _databaseService.updateAllInterfaceHabits(
    //     _authService.currentUser!.uid, _interfaceHabits.value);
    notifyListeners();
  }

  Future<void> updateHabit(HabitInterface updatedHabit) async {
    final index =
        _habits.value.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits.value = [
        ..._habits.value.sublist(0, index),
        updatedHabit,
        ..._habits.value.sublist(index + 1)
      ];
      // Uncomment when implementations are ready
      // await _localStorageService.saveInterfaceHabits(_interfaceHabits.value);
      // await _databaseService.updateAllInterfaceHabits(
      //     _authService.currentUser!.uid, _interfaceHabits.value);
      notifyListeners();
    }
  }

  Future<HabitInterface?> getHabit(String habitId) async {
    final habits = await getUserHabits();
    try {
      return habits.firstWhere((h) => h.id.toString() == habitId);
    } catch (e) {
      return null;
    }
  }

  double calculateConsistencyFactor(HabitInterface habit) {
    if (habit.daysCompleted.isEmpty) return 0.0;

    // Sort days completed
    final sortedDays = List<DateTime>.from(habit.daysCompleted)..sort();

    // Calculate average gap between completions
    double totalGap = 0;
    int gapCount = 0;

    for (int i = 1; i < sortedDays.length; i++) {
      final gap = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      totalGap += gap;
      gapCount++;
    }

    if (gapCount == 0) return 1.0; // Perfect consistency for single completion

    final averageGap = totalGap / gapCount;
    // Convert average gap to a 0-1 scale where smaller gaps mean higher consistency
    return 1.0 / (1.0 + averageGap);
  }
}

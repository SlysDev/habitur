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

  final ReactiveValue<List<HabitInterface>> _habits =
      ReactiveValue<List<HabitInterface>>([]);
  List<HabitInterface> get habits => _habits.value;
  Stream<List<HabitInterface>> get habitsStream => _habits.values;

  HabitService() {
    listenToReactiveValues([_habits]);
    _initHabits();
  }

  Future<void> _initHabits() async {
    await loadHabits();
  }

  Future<void> loadHabits() async {
    debugPrint('Loading habits...');
    var localHabits = _localStorageService.getHabitData();
    debugPrint(
        'Local habits: ${localHabits.map((h) => 'ID: ${h.id}, Title: ${h.title}')}');

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
    if (habitToDelete.isShared && habitToDelete is SharedHabit) {
      await _databaseService.deleteSharedHabit(habitId);
    } else {
      await _databaseService.deleteHabit(
          _authService.currentUser!.uid, habitId);
    }
    notifyListeners();
  }

  Future<void> incrementHabit(String habitId, double difficultyRating,
      {int amount = 1}) async {
    try {
      final habitIdInt = int.parse(habitId);
      final index = _habits.value.indexWhere((h) => h.id == habitIdInt);
      if (index != -1) {
        final habit = _habits.value[index];

        final HabitInterface updatedHabit =
            await _statsOrchestrationService.processHabitIncrement(
          habit: habit,
          amount: amount,
          difficultyRating: difficultyRating,
        );

        updateHabit(updatedHabit);

        notifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error in incrementHabit: $e');
      debugPrint(s.toString());
    }
  }

  Future<void> decrementHabit(String habitId, {int amount = 1}) async {
    final habitIdInt = int.parse(habitId);
    final index = _habits.value.indexWhere((h) => h.id == habitIdInt);
    if (index != -1) {
      final habit = _habits.value[index];

      final HabitInterface updatedHabit =
          await _statsOrchestrationService.processHabitDecrement(
        habit: habit,
        amount: amount,
      );

      updateHabit(updatedHabit);

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

  /// Resets the progress of daily habits if they haven't been completed today.
  /// Also checks if notifications need to be rescheduled.
  Future<void> resetDailyHabits() async {
    final habits = await getUserHabits();
    bool hasChanges = false;
    bool needsNotificationReschedule = false;

    debugPrint('Starting resetDailyHabits...');
    debugPrint('Total habits to check: ${habits.length}');

    for (var habit in habits) {
      debugPrint('Checking habit: ID: ${habit.id}, Title: ${habit.title}');
      if (habit.resetPeriod.toLowerCase() == 'daily' &&
          habit.daysCompleted.isNotEmpty) {
        final lastCompletionDate = habit.daysCompleted.last;
        final today = DateTime.now();

        final lastCompletionNormalized = DateTime(lastCompletionDate.year,
            lastCompletionDate.month, lastCompletionDate.day);
        final todayNormalized = DateTime(today.year, today.month, today.day);

        final daysDifference =
            todayNormalized.difference(lastCompletionNormalized).inDays;

        debugPrint(
            'Habit ID: ${habit.id} - Days since last completion: $daysDifference');

        if (daysDifference > 0) {
          int missedRequiredDays = 0;

          for (int i = 1; i <= daysDifference; i++) {
            final missedDay = todayNormalized.subtract(Duration(days: i));
            final dayOfWeek = DateFormat('EEEE').format(missedDay);

            if (habit.requiredDatesOfCompletion.contains(dayOfWeek)) {
              missedRequiredDays++;
            }
          }

          debugPrint(
              'Habit ID: ${habit.id} - Missed required days: $missedRequiredDays');

          if (missedRequiredDays >= 1) {
            habit.resetProgress();
            hasChanges = true;
            debugPrint('Habit ID: ${habit.id} - Progress reset');

            if (habit.smartNotifsEnabled) {
              needsNotificationReschedule = true;
              debugPrint(
                  'Habit ID: ${habit.id} - Needs notification reschedule');
            }
          }

          if (missedRequiredDays > 1) {
            habit.streak = 0;
            hasChanges = true;
            debugPrint('Habit ID: ${habit.id} - Streak reset to 0');
          }
        }
      }
    }

    if (hasChanges) {
      await saveHabits(habits);
      debugPrint('Habits saved after reset');
      if (needsNotificationReschedule) {
        await locator<NotificationSchedulingService>()
            .rescheduleNotifications();
        debugPrint('Notifications rescheduled');
      }
    }

    debugPrint('Finished resetDailyHabits');
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

        if (currentWeek > lastCompletedWeek) {
          habit.resetProgress();
          hasChanges = true;

          if (habit.smartNotifsEnabled) {
            needsNotificationReschedule = true;
          }
        }

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

        bool isNewMonth = now.year > lastCompletedDay.year ||
            (now.year == lastCompletedDay.year &&
                currentMonth > lastCompletedMonth);

        if (isNewMonth) {
          habit.resetProgress();
          hasChanges = true;

          if (habit.smartNotifsEnabled) {
            needsNotificationReschedule = true;
          }
        }

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
      return await _databaseService.getInterfaceHabits(userId);
    }
    return _habits.value;
  }

  Future<List<HabitInterface>> getVisibleHabits({String? userId}) async {
    return _habits.value.where((habit) => habit.isVisible ?? true).toList();
  }

  Future<void> addHabit(HabitInterface habit) async {
    _habits.value = [..._habits.value, habit];
    notifyListeners();
  }

  Future<void> updateHabit(HabitInterface habit) async {
    debugPrint('()()()(): updating this dang habit ${habit.toString()}');
    // update the habit in _habits as well
    final index = _habits.value.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits.value = [
        ..._habits.value.sublist(0, index),
        habit,
        ..._habits.value.sublist(index + 1),
      ];
    }
    await _localStorageService.updateHabit(habit);
    if (habit is Habit) {
      await _databaseService.updateHabit(_authService.currentUser!.uid, habit);
    } else if (habit is SharedHabit) {
      await _databaseService.updateSharedHabit(habit);
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

    final sortedDays = List<DateTime>.from(habit.daysCompleted)..sort();

    double totalGap = 0;
    int gapCount = 0;

    for (int i = 1; i < sortedDays.length; i++) {
      final gap = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      totalGap += gap;
      gapCount++;
    }

    if (gapCount == 0) return 1.0;

    final averageGap = totalGap / gapCount;
    return 1.0 / (1.0 + averageGap);
  }
}

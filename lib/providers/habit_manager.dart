import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
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
  Database db = Database();
  void getDay() {
    weekDay = DateFormat('EEEE').format(DateTime.now());
  }

  UnmodifiableListView<Habit> get habits {
    return UnmodifiableListView(_habits);
  }

  UnmodifiableListView<Habit> get sortedHabits {
    return UnmodifiableListView(_sortedHabits);
  }

  Future<void> addHabit(Habit habit, context) async {
    NotificationManager notificationManager = NotificationManager();
    await notificationManager.cancelAllScheduledNotifications();
    NotificationScheduler notificationScheduler = NotificationScheduler();
    _habits.add(habit);
    bool notificationSetting =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .dailyReminders
            .settingValue;
    if (notificationSetting) {
      int numberOfReminders =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .numberOfReminders
              .settingValue;
      await notificationScheduler.scheduleDefaultTrack(
          context, numberOfReminders);
    }
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

  void loadHabits(List<Habit> habitList) {
    _habits = habitList;
    notifyListeners();
  }

  Future<void> deleteHabit(context, int index) async {
    NotificationManager notificationManager = NotificationManager();
    await notificationManager.cancelAllScheduledNotifications();
    NotificationScheduler notificationScheduler = NotificationScheduler();
    int habitID = _sortedHabits[index].id;
    _sortedHabits.removeAt(index);
    _habits.removeWhere((element) => element.id == habitID);
    bool notificationSetting =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .dailyReminders
            .settingValue;
    if (notificationSetting) {
      int numberOfReminders =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .numberOfReminders
              .settingValue;
      await notificationScheduler.scheduleDefaultTrack(
          context, numberOfReminders);
    }
    notifyListeners();
  }

  void editHabit(int index, Habit newData) {
    _habits[index] = newData;
    notifyListeners();
  }

  void updateHabits() {
    sortHabits();
    notifyListeners();
  }

  Future<void> resetDailyHabits(context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();
    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);
      if (element.resetPeriod == 'Daily') {
        if (element.smartNotifsEnabled) {
          await notificationScheduler.scheduleDayHabitReminderTrack(element);
        }
        // If the task was not created today, make it incomplete
        String currentDayOfWeek = DateFormat('EEEE').format(DateTime.now());
        element.lastSeen = DateTime.now();
        if (DateFormat('d').format(element.lastSeen) !=
                DateFormat('d').format(DateTime.now()) &&
            element.requiredDatesOfCompletion.contains(currentDayOfWeek)) {
          if (element.completionsToday == 0) {
            element.streak = 0;
          }
          habitStatsHandler.resetHabitCompletions();
        }
      }
    }
    bool notificationSetting =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .dailyReminders
            .settingValue;
    if (notificationSetting) {
      int numberOfReminders =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .numberOfReminders
              .settingValue;
      await notificationScheduler.scheduleDefaultTrack(
          context, numberOfReminders);
    }

    notifyListeners();
    db.habitDatabase.uploadHabits(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits);
  }

  Future<void> resetWeeklyHabits(context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();
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
        if (element.smartNotifsEnabled) {
          await notificationScheduler.scheduleWeekHabitReminderTrack(element);
        }
        final now = DateTime.now();
        final currentWeek = getWeekOfYear(now);
        final lastResetWeek = getWeekOfYear(element.lastSeen);
        if (currentWeek > lastResetWeek) {
          habitStatsHandler.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      }
    }
    bool notificationSetting =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .dailyReminders
            .settingValue;
    if (notificationSetting) {
      int numberOfReminders =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .numberOfReminders
              .settingValue;
      await notificationScheduler.scheduleDefaultTrack(
          context, numberOfReminders);
    }
    notifyListeners();
    db.habitDatabase.uploadHabits(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits);
  }

  Future<void> resetMonthlyHabits(context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();
    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);
      if (element.resetPeriod == 'Monthly') {
        if (element.smartNotifsEnabled) {
          await notificationScheduler.scheduleMonthHabitReminderTrack(element);
        }
        // If the task was not created this month, make it incomplete
        if (DateFormat('m').format(element.lastSeen) !=
            DateFormat('m').format(DateTime.now())) {
          habitStatsHandler.resetHabitCompletions();
          element.lastSeen = DateTime.now();
        }
      }
    }
    bool notificationSetting =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .dailyReminders
            .settingValue;
    if (notificationSetting) {
      int numberOfReminders =
          Provider.of<SettingsLocalStorage>(context, listen: false)
              .numberOfReminders
              .settingValue;
      await notificationScheduler.scheduleDefaultTrack(
          context, numberOfReminders);
    }
    notifyListeners();
    db.habitDatabase.uploadHabits(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits);
  }

  Future<void> resetHabits(context) async {
    NotificationManager notificationManager = NotificationManager();
    notificationManager.cancelAllScheduledNotifications();
    await resetDailyHabits(context);
    await resetWeeklyHabits(context);
    await resetMonthlyHabits(context);
    await notificationManager.printNotifications();
  }

  Future<void> scheduleSmartHabitNotifs() async {
    NotificationScheduler notificationScheduler = NotificationScheduler();
    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      if (element.smartNotifsEnabled) {
        if (element.resetPeriod == 'Daily') {
          await notificationScheduler.scheduleDayHabitReminderTrack(element);
        } else if (element.resetPeriod == 'Weekly') {
          await notificationScheduler.scheduleWeekHabitReminderTrack(element);
        } else if (element.resetPeriod == 'Monthly') {
          await notificationScheduler.scheduleMonthHabitReminderTrack(element);
        }
      }
    }
  }

  List<Habit> getTodaysDueHabits() {
    List<Habit> todaysHabits = [];
    for (int i = 0; i < _habits.length; i++) {
      if (_habits[i].resetPeriod == 'Daily') {
        if (_habits[i]
                .requiredDatesOfCompletion
                .contains(DateFormat('EEEE').format(DateTime.now())) &&
            !_habits[i].isCompleted) {
          todaysHabits.add(_habits[i]);
        }
      } else {
        if (_habits[i].isCompleted == false) {
          todaysHabits.add(_habits[i]);
        }
      }
    }
    return todaysHabits;
  }

  bool checkDailyHabits() {
    if (weekDay != DateFormat('EEEE').format(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  void clearHabitStats() {
    for (int i = 0; i < _habits.length; i++) {
      _habits[i].stats = [];
    }
  }
}

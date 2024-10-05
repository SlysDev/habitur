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
  // TODO: Refactor so it handles persistence asw (DB/LS)
  List<Habit> _habits = [];
  List<Habit> _sortedHabits = [];
  late String weekDay;
  late String date;
  final Database _db = Database();
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
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .addHabit(habit);
    await _db.habitDatabase.addHabit(habit, context);
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
    _habits.removeWhere((element) => element.id == habitID);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .deleteHabit(sortedHabits[index]);
    await _db.habitDatabase.deleteHabit(context, habitID);
    sortHabits();
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
    sortHabits();
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
        // If element.daysCompleted is not empty
        if (element.daysCompleted.isNotEmpty) {
          int counter = 0;

          // Get the difference in days between the last completion date and today
          int daysDifference = element.daysCompleted.last
              .difference(DateTime.now())
              .inDays
              .abs();

          for (int i = 0; i <= daysDifference; i++) {
            // Get the current day being checked
            DateTime currentDay =
                element.daysCompleted.last.subtract(Duration(days: i));

            // Get the day of the week as a string (e.g., "Monday", "Tuesday", etc.)
            String dayOfWeek = DateFormat('EEEE').format(currentDay);

            // Check if this day is a required date of completion for the habit
            if (element.requiredDatesOfCompletion.contains(dayOfWeek)) {
              counter++;
            }
          }

          debugPrint("${element.title} days not completed: $counter");
          counter -= 1; // for loop includes today; so subtract one from counter
          // Reset habit completions if today is a new day and it requires completion
          if (counter >= 1) {
            habitStatsHandler
                .resetHabitCompletions(); // Allows user to complete the habit again
            if (element.smartNotifsEnabled) {
              await notificationScheduler
                  .scheduleDayHabitReminderTrack(element);
            }
          }

          // Reset the streak only if more than one required day has passed without completion
          if (counter > 1) {
            element.streak = 0;
            habitStatsHandler.fillInMissingDays(context);
          }
        }
      }
    }

    // Schedule daily reminders if enabled
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

    // Upload habits if user is logged in
    if (_db.userDatabase.isLoggedIn) {
      await _db.habitDatabase.uploadHabits(context);
    }

    // Upload all habits to local storage
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits, context);
  }

  Future<void> resetWeeklyHabits(context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();

    int getWeekOfYear(DateTime date) {
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
        if (element.daysCompleted.isNotEmpty) {
          final now = DateTime.now();
          final currentWeek = getWeekOfYear(now);
          DateTime lastCompletedDay = element.daysCompleted.last;
          final lastCompletedWeek = getWeekOfYear(lastCompletedDay);

          // Reset completions if we're in a new week
          if (currentWeek > lastCompletedWeek) {
            habitStatsHandler.resetHabitCompletions();
            if (element.smartNotifsEnabled) {
              await notificationScheduler
                  .scheduleWeekHabitReminderTrack(element);
            }
          }

          // Reset the streak if more than a week has passed without completion
          if (now.difference(lastCompletedDay).inDays >= 7) {
            element.streak = 0;
            habitStatsHandler.fillInMissingDays(context);
          }
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

    if (_db.userDatabase.isLoggedIn) {
      await _db.habitDatabase.uploadHabits(context);
    }

    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits, context);
  }

  Future<void> resetMonthlyHabits(context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();

    int getMonth(DateTime date) {
      return date.month;
    }

    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);

      if (element.resetPeriod == 'Monthly') {
        if (element.daysCompleted.isNotEmpty) {
          final now = DateTime.now();
          final currentMonth = getMonth(now);
          DateTime lastCompletedDay = element.daysCompleted.last;
          final lastCompletedMonth = getMonth(lastCompletedDay);

          // Reset completions if we're in a new month
          if (currentMonth > lastCompletedMonth) {
            habitStatsHandler.resetHabitCompletions();
            if (element.smartNotifsEnabled) {
              await notificationScheduler
                  .scheduleMonthHabitReminderTrack(element);
            }
          }

          // Reset the streak if more than a month has passed without completion
          if (now.difference(lastCompletedDay).inDays >= 30) {
            element.streak = 0;
            habitStatsHandler.fillInMissingDays(context);
          }
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

    if (_db.userDatabase.isLoggedIn) {
      await _db.habitDatabase.uploadHabits(context);
    }

    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(
            Provider.of<HabitManager>(context, listen: false).habits, context);
  }

  Future<void> resetHabits(context) async {
    // TODO: Consider filling in missing days for all habits even if they aren't being reset
    NotificationManager notificationManager = NotificationManager();
    notificationManager
        .cancelAllScheduledNotifications(); // TODO: cancel notifs by channel
    await resetDailyHabits(context);
    await resetWeeklyHabits(context);
    await resetMonthlyHabits(context);
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

  void deleteAllHabits() {
    _habits = [];
    _sortedHabits = [];
    notifyListeners();
  }
}

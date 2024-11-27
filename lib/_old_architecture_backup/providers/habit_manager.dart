import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/providers/activity_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/privacy_settings.dart';
import 'database.dart';
import 'dart:collection';

class HabitManager extends ChangeNotifier {
  List<Habit> _habits = [];
  late String weekDay;
  late String date;
  final Database _db = Database();
  void getDay() {
    weekDay = DateFormat('EEEE').format(DateTime.now());
  }

  List<Habit> get habits => _habits;

  List<Habit> getVisibleHabits(BuildContext context) {
    final user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    if (user == null) return [];

    // If sharing scope is none, return empty list
    if (user.privacySettings?.habitsScope == SharingScope.none) {
      return [];
    }

    // If sharing scope is friends or everyone, return visible habits
    return _habits.where((habit) => habit.isVisible ?? true).toList();
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

    // Create activity for new habit
    final user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    final activity = ActivityEvent(
      userId: user.uid,
      username: user.username,
      type: ActivityType.newHabit,
      habitId: habit.id.toString(),
      habitTitle: habit.title,
      metadata: {
        'frequency': habit.resetPeriod,
        'targetGoal': habit.targetGoal,
      },
    );
    await activityProvider.createActivity(activity);

    notifyListeners();
  }

  void loadHabits(List<Habit> habitList) {
    _habits = habitList;
    notifyListeners();
  }

  Future<void> deleteHabit(context, int index) async {
    NotificationManager notificationManager = NotificationManager();
    await notificationManager.cancelAllScheduledNotifications();
    NotificationScheduler notificationScheduler = NotificationScheduler();
    Habit habitToDelete = _habits[index];
    int habitID = habitToDelete.id;
    _habits.removeWhere((element) => element.id == habitID);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .deleteHabit(habitToDelete);
    await _db.habitDatabase.deleteHabit(context, habitID);
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

  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  void updateHabits() {
    notifyListeners();
  }

  Future<void> resetDailyHabits(BuildContext context) async {
    NotificationScheduler notificationScheduler = NotificationScheduler();

    for (int i = 0; i < _habits.length; i++) {
      Habit element = _habits[i];
      HabitStatsHandler habitStatsHandler = HabitStatsHandler(element);

      if (element.resetPeriod == 'Daily') {
        // If element.daysCompleted is not empty
        if (element.daysCompleted.isNotEmpty) {
          DateTime lastCompletionDate = element.daysCompleted.last;
          DateTime today = DateTime.now();

          // Normalize both dates to midnight for comparison
          DateTime lastCompletionNormalized = DateTime(lastCompletionDate.year,
              lastCompletionDate.month, lastCompletionDate.day);
          DateTime todayNormalized =
              DateTime(today.year, today.month, today.day);

          // Calculate the number of days between the last completion and today
          int daysDifference =
              todayNormalized.difference(lastCompletionNormalized).inDays;

          // Check for off days
          if (daysDifference > 0) {
            int counter = 0;

            for (int i = 1; i <= daysDifference; i++) {
              // Get the current day being checked
              DateTime currentDay = todayNormalized.subtract(Duration(days: i));
              // Get the day of the week as a string (e.g., "Monday", "Tuesday", etc.)
              String dayOfWeek = DateFormat('EEEE').format(currentDay);

              // Check if this day is a required date of completion for the habit
              if (element.requiredDatesOfCompletion.contains(dayOfWeek)) {
                counter++;
              }
            }

            debugPrint("${element.title} days not completed: $counter");

            if (element.title == "Cold Shower") {
              debugPrint("Cold Shower days not completed: $counter");
            }
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

  Future<void> rescheduleSmartNotifications(Habit habit,
      {bool backward = false}) async {
    debugPrint("Rescheduling smart notifications for habit: ${habit.title}");

    NotificationManager notificationManager = NotificationManager();
    await notificationManager.cancelScheduledNotificationsByHabitId(habit.id);
    debugPrint("Cancelled existing notifications for habit: ${habit.title}");

    NotificationScheduler notificationScheduler = NotificationScheduler();
    if (habit.smartNotifsEnabled) {
      debugPrint("Smart notifications are enabled for habit: ${habit.title}");
      Duration delay;
      if (habit.resetPeriod == 'Daily') {
        delay = backward ? Duration(days: -1) : Duration(days: 1);
        await notificationScheduler.scheduleDayHabitReminderTrack(habit,
            delay: delay);
        debugPrint("Scheduled daily reminder for habit: ${habit.title}");
      } else if (habit.resetPeriod == 'Weekly') {
        delay = backward ? Duration(days: -7) : Duration(days: 7);
        await notificationScheduler.scheduleWeekHabitReminderTrack(habit,
            delay: delay);
        debugPrint("Scheduled weekly reminder for habit: ${habit.title}");
      } else if (habit.resetPeriod == 'Monthly') {
        delay = backward ? Duration(days: -30) : Duration(days: 30);
        await notificationScheduler.scheduleMonthHabitReminderTrack(habit,
            delay: delay);
        debugPrint("Scheduled monthly reminder for habit: ${habit.title}");
      } else {
        debugPrint(
            "Smart notifications are not enabled for habit: ${habit.title}");
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

  Future<void> clearHabitStats(BuildContext context) async {
    for (int i = 0; i < _habits.length; i++) {
      _habits[i].stats = [];
    }
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .clearStats(context);
  }

  Future<void> deleteAllHabits(BuildContext context) async {
    Database db = Database();
    _habits = [];
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .deleteData(context);
    await db.habitDatabase.clearHabits(context);
    notifyListeners();
  }

  Future<void> loadHabitsFromDB(BuildContext context, {String? userID}) async {
    List<Habit> habitList =
        await _db.habitDatabase.loadHabits(context, userID: userID);
    loadHabits(habitList);
    await resetDailyHabits(context);
    await resetWeeklyHabits(context);
    await resetMonthlyHabits(context);
    await Provider.of<HabitsLocalStorage>(context, listen: false)
        .uploadAllHabits(habitList, context);
  }

  Future<void> loadHabitsFromLocalStorage(BuildContext context) async {
    final habits = Provider.of<HabitsLocalStorage>(context, listen: false)
        .getHabitData(context);
    loadHabits(habits);
    await _db.habitDatabase.uploadHabits(context);
  }
}

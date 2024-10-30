import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:provider/provider.dart';

class NotificationScheduler {
  NotificationManager notificationManager = NotificationManager();
  // TODO: Handle errors + display snackbar for all functions

  Future<void> scheduleTestDefaultTrack(context) async {
    if (Provider.of<HabitManager>(context, listen: false)
        .getTodaysDueHabits()
        .isEmpty) {
      return;
    }
    DateTime now = DateTime.now();
    await notificationManager.scheduleNotification(
        title: "Good morning!",
        body: "Time to complete your habits––you have ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length} ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length == 1 ? "habit" : "habits"} due today.",
        date: now.add(Duration(seconds: 25)),
        id: 1,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Feeling motivated?",
        body: "Time to crush your habits and raise those confidence levels!",
        date: now.add(Duration(seconds: 50)),
        id: 2,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "It's getting late...",
        body: "Time's running out––complete your habits now or risk breaking your streak!",
        date: now.add(Duration(seconds: 75)),
        id: 3,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "You've lost your streak!",
        body: "Complete your habits now to start up a new streak.",
        date: now.add(Duration(seconds: 90)),
        id: 4,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "It's been a while...",
        body: "It's been five days since you've completed your habits. Give it a go!",
        date: now.add(Duration(seconds: 105)),
        id: 5,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Looks like you're taking a break",
        body: "We'll stop sending notifications for now––you can always come back!",
        date: now.add(Duration(seconds: 120)),
        id: 6,
        channelKey: "habit_smart_notifications");
  }

  Future<void> scheduleDefaultTrack(context, int numberOfNotifs) async {
    if (Provider.of<HabitManager>(context, listen: false)
        .getTodaysDueHabits()
        .isEmpty) {
      return;
    }
    TimeModel firstNotifTime =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .getSettingByName('1st Reminder Time')!
            .settingValue;
    TimeModel secondNotifTime =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .getSettingByName('2nd Reminder Time')!
            .settingValue;
    TimeModel thirdNotifTime =
        Provider.of<SettingsLocalStorage>(context, listen: false)
            .getSettingByName('3rd Reminder Time')!
            .settingValue;
    // getting notif times from settings
    DateTime now = DateTime.now();
    await notificationManager.scheduleNotification(
        title: "Hey ${Provider.of<UserLocalStorage>(context, listen: false).currentUser.username}!",
        body: "Time to complete your habits––you have ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length} ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length == 1 ? "habit" : "habits"} due today.",
        date: now.copyWith(hour: firstNotifTime.hour, minute: firstNotifTime.minute),
        id: 1,
        channelKey: "habit_smart_notifications");
    if (numberOfNotifs > 1) {
      await notificationManager.scheduleNotification(
          title: "Feeling motivated?",
          body: "Time to crush your habits and raise those confidence levels!",
          date: now.copyWith(
              hour: secondNotifTime.hour, minute: secondNotifTime.minute),
          id: 2,
          channelKey: "habit_smart_notifications");
      if (numberOfNotifs > 2) {
        await notificationManager.scheduleNotification(
            title: "It's getting late...",
            body: "Time's running out––complete your habits now or risk breaking your streak!",
            date: now.copyWith(
                hour: thirdNotifTime.hour, minute: thirdNotifTime.minute),
            id: 3,
            channelKey: "habit_smart_notifications");
      }
    }
    await notificationManager.scheduleNotification(
        title: "You've lost your streak!",
        body: "Complete your habits now to start up a new streak.",
        date: now.copyWith(
            day: now.day + 1,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        id: 4,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "It's been a while...",
        body: "It's been five days since you've completed your habits. Give it a go!",
        date: now.copyWith(
            day: now.day + 5,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        id: 5,
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Looks like you're taking a break",
        body: "We'll stop sending notifications for now––you can always come back!",
        date: now.copyWith(
            day: now.day + 10,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        id: 6,
        channelKey: "habit_smart_notifications");
  }

  Future<void> scheduleDayHabitReminderTrack(Habit habit,
      {Duration delay = const Duration()}) async {
    DateTime scheduledTime = DateTime.now();
    TimeModel optimalTime =
        calculateOptimalNotificationTime(habit.daysCompleted);
    scheduledTime = scheduledTime.copyWith(
      hour: optimalTime.hour,
      minute: optimalTime.minute,
    );
    scheduledTime = scheduledTime.add(delay);
    // current day's round of notifs
    await notificationManager.scheduleNotification(
        title: "Your habit \"${habit.title}\" is due!",
        body: "You tend to complete this habit around this time––don't forget!",
        date: scheduledTime,
        id: int.parse("${habit.id}1"),
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Don't forget ${habit.title}!",
        body: "Time's running out! Complete it now or risk breaking your streak",
        date: scheduledTime.add(Duration(hours: Random().nextInt(2) + 2)),
        id: int.parse("${habit.id}2"),
        channelKey: "habit_smart_notifications");

    // next day's notif
    await notificationManager.scheduleNotification(
        title: "Uh oh...",
        body: "Looks like you missed your ${habit.title} habit––try to start back a streak!",
        date: scheduledTime.add(Duration(days: 1)),
        id: int.parse("${habit.id}01"),
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "It's been a while",
        body: "It's been 5 days since you've completed ${habit.title}. Give it a go!",
        date: scheduledTime.add(Duration(days: 5)),
        id: int.parse("${habit.id}05"),
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Looks like you're taking a break from ${habit.title}",
        body: "We'll stop sending notifications for now––you can always come back!",
        date: scheduledTime.add(Duration(days: 10)),
        id: int.parse("${habit.id}010"),
        channelKey: "habit_smart_notifications");
  }

  Future<void> scheduleWeekHabitReminderTrack(Habit habit,
      {Duration delay = const Duration()}) async {
    DateTime now = DateTime.now();
    int todayWeekday = now.weekday;

    // Calculate days until next Sunday
    int daysUntilSunday = (DateTime.sunday - todayWeekday) % 7;
    TimeModel optimalTime =
        calculateOptimalNotificationTime(habit.daysCompleted);
    DateTime scheduledTime = now.copyWith(
      hour: optimalTime.hour,
      minute: optimalTime.minute,
    );
    scheduledTime = scheduledTime.add(delay);
    await notificationManager.scheduleNotification(
        title: "Your habit \"${habit.title}\" is due!",
        body: "You tend to complete this habit around this time––don't forget!",
        date: scheduledTime,
        id: int.parse("${habit.id}1"),
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Don't forget ${habit.title}!",
        body: "Time's running out! Complete it now or risk breaking your streak",
        date: scheduledTime.add(Duration(hours: Random().nextInt(daysUntilSunday))),
        id: int.parse("${habit.id}2"),
        channelKey: "habit_smart_notifications");
  }

  Future<void> scheduleMonthHabitReminderTrack(Habit habit,
      {Duration delay = const Duration()}) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastDayOfThisMonth =
        firstDayOfNextMonth.subtract(Duration(days: 1));
    int daysUntilMonthEnd = lastDayOfThisMonth.difference(now).inDays;
    DateTime scheduledTime = DateTime.now();
    TimeModel optimalTime =
        calculateOptimalNotificationTime(habit.daysCompleted);
    scheduledTime = scheduledTime.copyWith(
      hour: optimalTime.hour,
      minute: optimalTime.minute,
    );
    scheduledTime = scheduledTime.add(delay);
    await notificationManager.scheduleNotification(
        title: "Your habit \"${habit.title}\" is due!",
        body: "You tend to complete this habit around this time––don't forget!",
        date: scheduledTime,
        id: int.parse("${habit.id}1"),
        channelKey: "habit_smart_notifications");
    await notificationManager.scheduleNotification(
        title: "Don't forget ${habit.title}!",
        body: "Time's running out! Complete it now or risk breaking your streak",
        date: scheduledTime.add(Duration(hours: Random().nextInt(daysUntilMonthEnd))),
        id: int.parse("${habit.id}2"),
        channelKey: "habit_smart_notifications");
  }

  Future<void> scheduleHabitReminderTrack(Habit habit,
      {Duration delay = const Duration()}) async {
    if (habit.resetPeriod == "Daily") {
      await scheduleDayHabitReminderTrack(habit, delay: delay);
    } else if (habit.resetPeriod == "Weekly") {
      await scheduleWeekHabitReminderTrack(habit, delay: delay);
    } else {
      await scheduleMonthHabitReminderTrack(habit, delay: delay);
    }
  }

  Future<void> cancelHabitSchedule(int habitID) async {
      await notificationManager.cancelScheduledNotificationsByHabitId(habitID);
  }

  TimeModel calculateOptimalNotificationTime(List<DateTime> completionTimes) {
    if (completionTimes.isEmpty) {
      return TimeModel(hour: 12, minute: 0);
    }
    // Convert DateTime objects to TimeModel objects
    List<TimeModel> completionTimesOfDay = completionTimes
        .map((dt) => TimeModel(hour: dt.hour, minute: dt.minute))
        .toList();

    // Group completion times by hour and minute
    Map<TimeModel, int> timeOccurrences = {};
    completionTimesOfDay.forEach((time) {
      timeOccurrences[time] = (timeOccurrences[time] ?? 0) + 1;
    });

    // Calculate weighted average based on occurrences
    double totalWeight = 0;
    double weightedSumHour = 0;
    double weightedSumMinute = 0;
    const weightBase = 0.9; // Adjust weight base as needed
    int index = 0;
    timeOccurrences.forEach((time, count) {
      double weight = pow(weightBase, index++) as double;
      totalWeight += weight;
      weightedSumHour += time.hour * weight;
      weightedSumMinute += time.minute * weight;
    });

    // Calculate average hour and minute
    double averageHour = weightedSumHour / totalWeight;
    double averageMinute = weightedSumMinute / totalWeight;

    // Create a TimeModel object
    return TimeModel(hour: averageHour.round(), minute: averageMinute.round());
  }
}

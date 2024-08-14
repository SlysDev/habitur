import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/settings_data.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:provider/provider.dart';

class NotificationScheduler {
  NotificationManager notificationManager = NotificationManager();

  Future<void> scheduleTestDefaultTrack(context) async {
    if (Provider.of<HabitManager>(context, listen: false)
        .getTodaysDueHabits()
        .isEmpty) {
      return;
    }
    DateTime now = DateTime.now();
    await notificationManager.scheduleNotification(
        "Good morning!",
        "Time to complete your habits––you have ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length} ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length == 1 ? "habit" : "habits"} due today.",
        now.add(Duration(seconds: 25)),
        1);
    await notificationManager.scheduleNotification(
        "Feeling motivated?",
        "Time to crush your habits and raise those confidence levels!",
        now.add(Duration(seconds: 50)),
        2);
    await notificationManager.scheduleNotification(
        "It's getting late...",
        "Time's running out––complete your habits now or risk breaking your streak!",
        now.add(Duration(seconds: 75)),
        3);
    await notificationManager.scheduleNotification(
        "You've lost your streak!",
        "Complete your habits now to start up a new streak.",
        now.add(Duration(seconds: 90)),
        4);
    await notificationManager.scheduleNotification(
        "It's been a while...",
        "It's been five days since you've completed your habits. Give it a go!",
        now.add(Duration(seconds: 105)),
        5);
    await notificationManager.scheduleNotification(
        "Looks like you're taking a break",
        "We'll stop sending notifications for now––you can always come back!",
        now.add(Duration(seconds: 120)),
        6);
    // TODO: Implement changing notif times in settings
  }

  Future<void> scheduleDefaultTrack(context, int numberOfNotifs) async {
    if (Provider.of<HabitManager>(context, listen: false)
        .getTodaysDueHabits()
        .isEmpty) {
      return;
    }
    TimeModel firstNotifTime = Provider.of<SettingsData>(context, listen: false)
        .getSettingByName('1st Reminder Time')
        .settingValue;
    TimeModel secondNotifTime =
        Provider.of<SettingsData>(context, listen: false)
            .getSettingByName('2nd Reminder Time')
            .settingValue;
    TimeModel thirdNotifTime = Provider.of<SettingsData>(context, listen: false)
        .getSettingByName('3rd Reminder Time')
        .settingValue;
    // getting notif times from settings
    DateTime now = DateTime.now();
    await notificationManager.scheduleNotification(
        "Hey ${Provider.of<UserData>(context, listen: false).currentUser.username}!",
        "Time to complete your habits––you have ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length} ${Provider.of<HabitManager>(context, listen: false).getTodaysDueHabits().length == 1 ? "habit" : "habits"} due today.",
        now.copyWith(hour: firstNotifTime.hour, minute: firstNotifTime.minute),
        1);
    if (numberOfNotifs > 1) {
      await notificationManager.scheduleNotification(
          "Feeling motivated?",
          "Time to crush your habits and raise those confidence levels!",
          now.copyWith(
              hour: secondNotifTime.hour, minute: secondNotifTime.minute),
          2);
      if (numberOfNotifs > 2) {
        await notificationManager.scheduleNotification(
            "It's getting late...",
            "Time's running out––complete your habits now or risk breaking your streak!",
            now.copyWith(
                hour: thirdNotifTime.hour, minute: thirdNotifTime.minute),
            3);
      }
    }
    await notificationManager.scheduleNotification(
        "You've lost your streak!",
        "Complete your habits now to start up a new streak.",
        now.copyWith(
            day: now.day + 1,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        4);
    await notificationManager.scheduleNotification(
        "It's been a while...",
        "It's been five days since you've completed your habits. Give it a go!",
        now.copyWith(
            day: now.day + 5,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        5);
    await notificationManager.scheduleNotification(
        "Looks like you're taking a break",
        "We'll stop sending notifications for now––you can always come back!",
        now.copyWith(
            day: now.day + 10,
            hour: Random().nextInt(10) + 8,
            minute: Random().nextInt(59)),
        6);
    // TODO: Implement changing notif times in settings

    await notificationManager.printNotifications();
  }

  Future<void> scheduleDayHabitReminderTrack(Habit habit) async {
    DateTime scheduledTime = DateTime.now();
    TimeModel optimalTime =
        calculateOptimalNotificationTime(habit.daysCompleted);
    scheduledTime.copyWith(
      hour: optimalTime.hour,
      minute: optimalTime.minute,
    );
    // current day's round of notifs
    await notificationManager.scheduleNotification(
        "Your habit \"${habit.title}\" is due!",
        "You tend to complete this habit around this time––don't forget!",
        scheduledTime,
        int.parse("${habit.id}1"));
    await notificationManager.scheduleNotification(
        "Feeling motivated?",
        "Time to crush your ${habit.title} habit!",
        scheduledTime.subtract(Duration(hours: Random().nextInt(2) + 2)),
        int.parse("${habit.id}0"));
    await notificationManager.scheduleNotification(
        "Don't forget ${habit.title}!",
        "Time's running out! Complete it now or risk breaking your streak",
        scheduledTime.add(Duration(hours: Random().nextInt(2) + 2)),
        int.parse("${habit.id}2"));

    // next day's notif
    await notificationManager.scheduleNotification(
        "Uh oh...",
        "Looks like you missed your ${habit.title} habit––try to start back a streak!",
        scheduledTime.add(Duration(days: 1)),
        int.parse("${habit.id}01"));
    await notificationManager.scheduleNotification(
        "It's been a while",
        "It's been 5 days since you've completed ${habit.title}. Give it a go!",
        scheduledTime.add(Duration(days: 5)),
        int.parse("${habit.id}05"));
    await notificationManager.scheduleNotification(
        "Looks like you're taking a break",
        "We'll stop sending notifications for now––you can always come back!",
        scheduledTime.add(Duration(days: 10)),
        int.parse("${habit.id}010"));
  }

  Future<void> scheduleWeekHabitReminderTrack(Habit habit) async {
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
    await notificationManager.scheduleNotification(
        "Your habit \"${habit.title}\" is due!",
        "You tend to complete this habit around this time––don't forget!",
        scheduledTime,
        int.parse("${habit.id}1"));
    await notificationManager.scheduleNotification(
        "Feeling motivated?",
        "Time to crush your ${habit.title} habit!",
        scheduledTime
            .subtract(Duration(days: Random().nextInt(now.weekday - 1))),
        int.parse("${habit.id}0"));
    await notificationManager.scheduleNotification(
        "Don't forget ${habit.title}!",
        "Time's running out! Complete it now or risk breaking your streak",
        scheduledTime.add(Duration(hours: Random().nextInt(daysUntilSunday))),
        int.parse("${habit.id}2"));
  }

  Future<void> scheduleMonthHabitReminderTrack(Habit habit) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    DateTime lastDayOfThisMonth =
        firstDayOfNextMonth.subtract(Duration(days: 1));
    int daysUntilMonthEnd = lastDayOfThisMonth.difference(now).inDays;
    DateTime scheduledTime = DateTime.now();
    TimeModel optimalTime =
        calculateOptimalNotificationTime(habit.daysCompleted);
    scheduledTime.copyWith(
      hour: optimalTime.hour,
      minute: optimalTime.minute,
    );
    await notificationManager.scheduleNotification(
        "Your habit \"${habit.title}\" is due!",
        "You tend to complete this habit around this time––don't forget!",
        scheduledTime,
        int.parse("${habit.id}1"));
    await notificationManager.scheduleNotification(
        "Feeling motivated?",
        "Time to crush your ${habit.title} habit!",
        scheduledTime.subtract(Duration(days: Random().nextInt(now.day - 1))),
        int.parse("${habit.id}0"));
    await notificationManager.scheduleNotification(
        "Don't forget ${habit.title}!",
        "Time's running out! Complete it now or risk breaking your streak",
        scheduledTime.add(Duration(hours: Random().nextInt(daysUntilMonthEnd))),
        int.parse("${habit.id}2"));
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/notification_service.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:habitur/services/settings_service.dart';
import 'package:habitur/services/user_service.dart';
import 'package:provider/provider.dart';

class NotificationSchedulingService {
  final NotificationService _notificationService =
      locator<NotificationService>();
  final HabitService _habitService = locator<HabitService>();
  final SettingsService _settingsService = locator<SettingsService>();
  final UserService _userService = locator<UserService>();

  Future<void> scheduleDefaultTrack(int numberOfNotifs) async {
    DateTime now = DateTime.now();
    final habits = await _habitService.getTodaysDueHabits();
    if (habits.isEmpty) return;

    if (_settingsService.getSetting('Daily Reminders')?.settingValue ?? false) {
    TimeModel firstNotifTime =
        _settingsService.getSetting('1st Reminder Time')?.settingValue;
    TimeModel secondNotifTime =
        _settingsService.getSetting('2nd Reminder Time')?.settingValue;
    TimeModel thirdNotifTime =
        _settingsService.getSetting('3rd Reminder Time')?.settingValue;
    final habitCount = habits.length;

    // Schedule general reminders
    await _scheduleGeneralReminders(
      now,
      firstNotifTime,
      secondNotifTime,
      thirdNotifTime,
      numberOfNotifs,
      habitCount,
      _userService.currentUser!.username,
    );
    }

    // Schedule habit-specific smart reminders
    for (var habit in habits) {
      if (habit.smartNotifsEnabled) {
        await _scheduleSmartRemindersForHabit(habit, now);
      }
    }
  }

  Future<void> _scheduleGeneralReminders(
    DateTime now,
    TimeModel firstTime,
    TimeModel secondTime,
    TimeModel thirdTime,
    int numberOfNotifs,
    int habitCount,
    String username,
  ) async {
    // Morning reminder
    await _notificationService.scheduleNotification(
      title: "Hey $username!",
      body:
          "Time to complete your habits––you have $habitCount ${habitCount == 1 ? "habit" : "habits"} due today.",
      date: now.copyWith(hour: firstTime.hour, minute: firstTime.minute),
      id: 1,
      channelKey: "habit_smart_notifications",
    );

    if (numberOfNotifs > 1) {
      await _notificationService.scheduleNotification(
        title: "Feeling motivated?",
        body: "Time to crush your habits and raise those confidence levels!",
        date: now.copyWith(hour: secondTime.hour, minute: secondTime.minute),
        id: 2,
        channelKey: "habit_smart_notifications",
      );

      if (numberOfNotifs > 2) {
        await _notificationService.scheduleNotification(
          title: "It's getting late...",
          body:
              "Time's running out––complete your habits now or risk breaking your streak!",
          date: now.copyWith(hour: thirdTime.hour, minute: thirdTime.minute),
          id: 3,
          channelKey: "habit_smart_notifications",
        );
      }
    }
  }

  Future<void> _scheduleSmartRemindersForHabit(
      HabitInterface habit, DateTime now) async {
    final completionHistory = _habitService.getDaysCompleted(habit);
    if (completionHistory.isEmpty) return;

    // Analyze completion patterns
    final completionTimes = completionHistory
        .map((dateCompleted) => TimeOfDay.fromDateTime(dateCompleted))
        .toList();

    // Calculate most successful completion time window
    final successWindow = _calculateSuccessWindow(completionTimes);
    if (successWindow == null) return;

    // Schedule a smart reminder before the usual completion time
    final reminderTime = _adjustTimeForReminder(now, successWindow);

    await _notificationService.scheduleNotification(
      title: "Time for: ${habit.title}",
      body: _generateSmartReminderMessage(habit),
      date: reminderTime,
      id: habit.id!, // Unique ID for habit-specific notifications
      channelKey: "habit_smart_notifications",
    );

    // Schedule a follow-up if not completed
    final followUpTime = _adjustTimeForFollowUp(now, successWindow);
    await _notificationService.scheduleNotification(
      title: "Don't forget: ${habit.title}",
      body: "This is usually a great time for you to complete this habit!",
      date: followUpTime,
      id: int.parse("${habit.id}1"),
      channelKey: "habit_smart_notifications",
    );
  }

  TimeOfDay? _calculateSuccessWindow(List<TimeOfDay> completionTimes) {
    if (completionTimes.isEmpty) return null;

    // Convert times to minutes for easier calculation
    final minutesList =
        completionTimes.map((time) => time.hour * 60 + time.minute).toList();

    // Calculate average completion time
    final avgMinutes =
        minutesList.reduce((a, b) => a + b) ~/ minutesList.length;

    return TimeOfDay(
      hour: avgMinutes ~/ 60,
      minute: avgMinutes % 60,
    );
  }

  DateTime _adjustTimeForReminder(DateTime now, TimeOfDay targetTime) {
    // Schedule 30 minutes before usual completion time
    var reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetTime.hour,
      targetTime.minute,
    ).subtract(const Duration(minutes: 30));

    // If the time has passed for today, schedule for tomorrow
    if (reminderDateTime.isBefore(now)) {
      reminderDateTime = reminderDateTime.add(const Duration(days: 1));
    }

    return reminderDateTime;
  }

  DateTime _adjustTimeForFollowUp(DateTime now, TimeOfDay targetTime) {
    // Schedule 30 minutes after usual completion time
    var followUpDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      targetTime.hour,
      targetTime.minute,
    ).add(const Duration(minutes: 30));

    // If the time has passed for today, schedule for tomorrow
    if (followUpDateTime.isBefore(now)) {
      followUpDateTime = followUpDateTime.add(const Duration(days: 1));
    }

    return followUpDateTime;
  }

  String _generateSmartReminderMessage(HabitInterface habit) {
    final messages = [
      "This is usually a great time for you to complete this habit!",
      "Based on your history, you're most successful with this habit around now.",
      "You've had great success completing this habit at this time!",
      "Keep up your streak! This is your optimal time for this habit.",
    ];
    return messages[Random().nextInt(messages.length)];
  }

  Future<void> rescheduleNotifications() async {
    await _notificationService.cancelAllScheduledNotifications();
    await scheduleDefaultTrack(3); // Default to 3 notifications per day
  }
}

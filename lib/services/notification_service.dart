import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class NotificationService {
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
        NotificationChannel(
          channelKey: 'habit_smart_notifications',
          channelName: 'Habit Smart Notifications',
          channelDescription: 'Notifications for smart habit reminders',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'repeat_notifications',
          channelName: 'Repeat Notifications',
          channelDescription: 'Notifications that repeat at a set time',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> sendNotification(String channelKey) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: channelKey,
        actionType: ActionType.Default,
        title: 'Hello World!',
        body: 'This is my first notification!',
      ),
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime date,
    required int id,
    required String channelKey,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
          actionType: ActionType.Default,
          title: title,
          body: body,
        ),
        schedule: NotificationCalendar(
          month: date.month,
          day: date.day,
          hour: date.hour,
          minute: date.minute,
        ),
      );
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }

  Future<void> scheduleDailyRepeatedNotification(
    String title,
    String body,
    int hour,
    int minute,
    int id,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'repeat_notifications',
        actionType: ActionType.Default,
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        repeats: true,
      ),
    );
  }

  Future<void> cancelScheduledNotification(int id) async {
    await AwesomeNotifications().cancelSchedule(id);
  }

  Future<void> cancelNotificationsByChannel(String channelKey) async {
    try {
      final scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      final notificationIds = scheduledNotifications
          .where(
              (notification) => notification.content?.channelKey == channelKey)
          .map((notification) => notification.content!.id!)
          .toList();

      if (notificationIds.isNotEmpty) {
        await Future.wait(
          notificationIds
              .map((id) => AwesomeNotifications().cancelSchedule(id)),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling notifications for channel $channelKey: $e');
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelScheduledNotificationsByHabitId(int habitId) async {
    try {
      final scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      final notificationIds = scheduledNotifications
          .where((notification) =>
              notification.content?.id
                  .toString()
                  .startsWith(habitId.toString()) ??
              false)
          .map((notification) => notification.content!.id!)
          .toList();

      if (notificationIds.isNotEmpty) {
        await Future.wait(
          notificationIds
              .map((id) => AwesomeNotifications().cancelSchedule(id)),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling notifications for habit $habitId: $e');
    }
  }

  Future<void> printScheduledNotifications() async {
    debugPrint('notifications:');
    List<NotificationModel> notifList =
        await AwesomeNotifications().listScheduledNotifications();
    for (NotificationModel notif in notifList) {
      debugPrint("${notif.content?.title}:");
      debugPrint("Body: ${notif.content?.body}");
      debugPrint("ID: ${notif.content?.id}");
      debugPrint(
        "Scheduled at: ${(notif.schedule as NotificationCalendar).hour}:${(notif.schedule as NotificationCalendar).minute} on ${(notif.schedule as NotificationCalendar).day}/${(notif.schedule as NotificationCalendar).month}",
      );
    }
  }
}

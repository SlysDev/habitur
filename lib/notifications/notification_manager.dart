import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class NotificationManager {
  Future<void> sendNotification(String channelKey) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 0,
      channelKey: channelKey,
      actionType: ActionType.Default,
      title: 'Hello World!',
      body: 'This is my first notification!',
    ));
  }

  Future<void> scheduleNotification(
      {required String title,
      required String body,
      required DateTime date,
      required int id,
      required String channelKey}) async {
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> scheduleDailyRepeatedNotification(
      String title, String body, int hour, int minute, int id) async {
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
      // Retrieve all scheduled notifications
      List<NotificationModel> scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      // Iterate through the notifications and cancel those that match the channel key
      for (NotificationModel notification in scheduledNotifications) {
        if (notification.content?.channelKey == channelKey) {
          await AwesomeNotifications()
              .cancelSchedule(notification.content!.id!);
        }
      }
    } catch (e) {
      // Print the error if something goes wrong
      debugPrint('Error cancelling notifications for channel $channelKey: $e');
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancels all scheduled notifications associated with a specific habit ID.
  Future<void> cancelScheduledNotificationsByHabitId(int habitId) async {
    try {
      // Retrieve all scheduled notifications
      List<NotificationModel> scheduledNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      // Iterate through the notifications and cancel those that match the habit ID
      for (NotificationModel notification in scheduledNotifications) {
        if (notification.content?.id
                .toString()
                .startsWith(habitId.toString()) ??
            false) {
          await AwesomeNotifications()
              .cancelSchedule(notification.content!.id!);
        }
      }
    } catch (e) {
      // Print the error if something goes wrong
      debugPrint('Error cancelling notifications for habit ID $habitId: $e');
    }
  }

  Future<void> printNotifications() async {
    debugPrint('notifications:');
    List<NotificationModel> notifList =
        await AwesomeNotifications().listScheduledNotifications();
    for (NotificationModel notif in notifList) {
      debugPrint("${notif.content?.title}:");
      debugPrint("Body: ${notif.content?.body}");
      debugPrint("ID: ${notif.content?.id}");
      debugPrint(
          "Scheduled at: ${(notif.schedule as NotificationCalendar).hour}:${(notif.schedule as NotificationCalendar).minute} on ${(notif.schedule as NotificationCalendar).day}/${(notif.schedule as NotificationCalendar).month}");
    }
  }
}

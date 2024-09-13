import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:habitur/models/habit.dart';

class NotificationManager {
  Future<void> sendNotification() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 0,
      channelKey: 'basic_channel',
      actionType: ActionType.Default,
      title: 'Hello World!',
      body: 'This is my first notification!',
    ));
  }

  Future<void> scheduleNotification(
      String title, String body, DateTime date, int id) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'basic_channel',
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
        channelKey: 'basic_channel',
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

  Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAll();
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

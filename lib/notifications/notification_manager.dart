import 'package:awesome_notifications/awesome_notifications.dart';
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
      print(e);
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
    print('notifications:');
    List<NotificationModel> notifList =
        await AwesomeNotifications().listScheduledNotifications();
    for (NotificationModel notif in notifList) {
      print("${notif.content?.title}:");
      print("Body: ${notif.content?.body}");
      print("ID: ${notif.content?.id}");
      print(
          "Scheduled at: ${(notif.schedule as NotificationCalendar).hour}:${(notif.schedule as NotificationCalendar).minute} on ${(notif.schedule as NotificationCalendar).day}/${(notif.schedule as NotificationCalendar).month}");
    }
  }
}

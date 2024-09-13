import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/days_of_week_widget.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';
import '../components/habit_card_list.dart';

class HabitsScreen extends StatefulWidget {
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  Future<void> loadData(BuildContext context) async {
    Database db = Database();
    if (db.userDatabase.isLoggedIn) {
      DateTime lastUpdated = await db.lastUpdatedManager.lastUpdated;
      if (lastUpdated.isAfter(
          Provider.of<HabitsLocalStorage>(context, listen: false)
              .lastUpdated)) {
        await db.habitDatabase.loadHabits(context);
        if (!Provider.of<NetworkStateProvider>(context, listen: false)
            .isConnected) {
          await Provider.of<HabitsLocalStorage>(context, listen: false)
              .loadData(context);
        } // handles no internet (try/catch in DB sets isConnected to false)
      } else {
        debugPrint('loading from LS; more recent');
        await Provider.of<HabitsLocalStorage>(context, listen: false)
            .loadData(context);
        await db.habitDatabase.uploadHabits(context);
      }
    } else {
      debugPrint('user is not logged in; loading from LS');
      await Provider.of<HabitsLocalStorage>(context, listen: false)
          .loadData(context);
      Provider.of<NetworkStateProvider>(context, listen: false).isConnected =
          false;
    }
    await Provider.of<HabitManager>(context, listen: false)
        .resetHabits(context);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          Container(
            margin: EdgeInsets.all(5),
            child: IconButton(
                onPressed: () => Navigator.pushNamed(context, 'profile-screen'),
                icon: Icon(
                  Icons.menu_rounded,
                  color: kPrimaryColor,
                  size: 30,
                )),
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeGreetingHeader(),
            // AsideButton(
            //     text: 'schedule test notifs',
            //     onPressed: () async {
            //       NotificationManager notificationManager =
            //           NotificationManager();
            //       await notificationManager.cancelAllScheduledNotifications();
            //       NotificationScheduler notificationScheduler =
            //           NotificationScheduler();
            //       await notificationScheduler.scheduleTestDefaultTrack(context);
            //     }),
            // AsideButton(
            //     text: 'reschedule notif track',
            //     onPressed: () async {
            //       NotificationManager notificationManager =
            //           NotificationManager();
            //       await notificationManager.cancelAllScheduledNotifications();
            //       NotificationScheduler notificationScheduler =
            //           NotificationScheduler();
            //       int numberOfReminders =
            //           Provider.of<SettingsLocalStorage>(context, listen: false)
            //               .numberOfReminders
            //               .settingValue;
            //       await notificationScheduler.scheduleDefaultTrack(
            //           context, numberOfReminders);
            //       notificationManager.printNotifications();
            //     }),
            // AsideButton(
            //     text: 'clear habits data',
            //     onPressed: () async {
            //       await Provider.of<HabitsLocalStorage>(context, listen: false)
            //           .deleteData();
            //     }),
            // AsideButton(
            //     text: 'load data from DB',
            //     onPressed: () async {
            //       try {
            //         Database db = Database();
            //         await db.habitDatabase.loadHabits(context);
            //         Provider.of<NetworkStateProvider>(context, listen: false)
            //             .isConnected = true;
            //       } catch (e) {
            //         Provider.of<NetworkStateProvider>(context, listen: false)
            //             .isConnected = false;
            //       }
            //     }),
            HabitCardList(
              onRefresh: () => loadData(context),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'habits',
      ),
    );
  }
}

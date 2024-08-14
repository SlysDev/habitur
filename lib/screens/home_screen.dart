import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/community-habit-list.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/providers/community_challenge_manager.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';
import '../components/habit_card_list.dart';
import '../notifications/notification_manager.dart';

class HomeScreen extends StatefulWidget {
  bool isOnline;
  HomeScreen({this.isOnline = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    if (widget.isOnline) {
      Provider.of<Database>(context, listen: false).loadData(context);
    }
    Provider.of<Database>(context, listen: false).loadData(context);
    Provider.of<SettingsLocalStorage>(context, listen: false).init();
    super.initState();
  }

  Widget build(BuildContext context) {
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
            CommunityHabitList(),
            AsideButton(
                text: 'Upload data',
                onPressed: () {
                  Provider.of<Database>(context, listen: false)
                      .uploadData(context);
                }),
            AsideButton(
                text: 'Download data',
                onPressed: () {
                  Provider.of<Database>(context, listen: false)
                      .loadData(context);
                  print('downloaded');
                }),
            // HabitCardList(
            //   // Passes network status to card list
            //   isOnline: widget.isOnline,
            // ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'home',
      ),
    );
  }
}


    // Checking for the day, will implement try/catch for online/offline later.
    // if (Provider.of<MHabitReset>(context).checkDailyHabits()) {
    //   Provider.of<UserData>(context).resetDailyHabits();
    //   Provider.of<MHabitReset>(context).getDay();
    // } else {
    //   Provider.of<MHabitReset>(context).getDay();
    // }

    // Scheduling with Cron - may implement in the future.
    // final cron = Cron();
    // cron.schedule(Schedule.parse('0 0 * * *'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetDailyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });
    // cron.schedule(Schedule.parse('0 0 * * 1'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetWeeklyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });
    // cron.schedule(Schedule.parse('0 0 1 * *'), () async {
    //   try {
    //     Provider.of<UserData>(context, listen: false).resetMonthlyHabits();
    //   } catch (e, st) {
    //     print(e);
    //   }
    // });

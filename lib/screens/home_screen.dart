import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import '../components/home_greeting_header.dart';
import 'package:habitur/constants.dart';
import '../components/habit_card_list.dart';

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
      print('done');
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Consumer<HabitManager>(
      builder: (context, habitManager, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            actions: [
              Container(
                margin: EdgeInsets.all(5),
                child: IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, 'profile-screen'),
                    icon: Icon(
                      Icons.menu_rounded,
                      color: kNeutralBlue,
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
                HabitCardList(
                  // Passes network status to card list
                  isOnline: widget.isOnline,
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          bottomNavigationBar: NavBar(
            currentPage: 'home',
          ),
        );
      },
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

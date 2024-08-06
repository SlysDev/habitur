import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/data/local/habit_repository.dart';
import 'package:habitur/models/habit.dart';
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

class HabitsScreen extends StatefulWidget {
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    if (Provider.of<HabitRepository>(context, listen: false)
        .getHabitData()
        .isNotEmpty) {
      Provider.of<HabitManager>(context, listen: false).sortHabits();
      // Provider.of<Database>(context, listen: false).loadHabits2(context);
    } else {
      Provider.of<Database>(context, listen: false).loadHabits(context);
    }
    // Provider.of<HabitManager>(context, listen: false).resetHabits(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<HabitRepository>(context, listen: false)
          .loadData(context),
      builder: (context, snapshot) {
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
                AsideButton(
                    text: 'download data to local storage',
                    onPressed: () async {
                      await Provider.of<HabitRepository>(context, listen: false)
                          .uploadAllHabits(
                              Provider.of<HabitManager>(context, listen: false)
                                  .habits);
                    }),
                AsideButton(
                    text: 'clear all LS boxes',
                    onPressed: () async {
                      await Provider.of<HabitRepository>(context, listen: false)
                          .close();
                    }),
                AsideButton(
                    text: 'load data from DB',
                    onPressed: () {
                      Provider.of<Database>(context, listen: false)
                          .loadHabits(context);
                    }),
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(
                            color: kPrimaryColor,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round))
                    : HabitCardList(),
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

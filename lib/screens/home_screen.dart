import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/modules/habit_reset_module.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/constants.dart';

class HomeScreen extends StatelessWidget {
  bool isOnline;
  HomeScreen({this.isOnline = true});
  final _firestore = FirebaseFirestore.instance;
  String timeOfDay = 'Day';
  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    // Calculate the time of day
    if (currentTime.hour > 3 && currentTime.hour < 12) {
      timeOfDay = 'Morning';
    } else if (currentTime.hour > 12 && currentTime.hour < 18) {
      timeOfDay = 'Afternoon';
    } else {
      timeOfDay = 'Evening';
    }
    return Consumer<UserData>(
      builder: (context, userData, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Good $timeOfDay',
                  style: kTitleTextStyle,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Today is ' +
                      DateFormat('EEEE,').format(DateTime.now()) +
                      ' ' +
                      DateFormat('d').format(DateTime.now()) +
                      '/' +
                      DateFormat('M').format(DateTime.now()),
                ),
                const SizedBox(
                  height: 80,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          double currentValue;
                          double incrementedValue;
                          return userData
                                  .userHabits[index].requiredDatesOfCompletion
                                  .contains(
                                      DateFormat('EEEE').format(DateTime.now()))
                              ? HabitCard(
                                  progress: userData.userHabits[index]
                                          .currentCompletions /
                                      userData.userHabits[index]
                                          .requiredCompletions,
                                  completed: userData.userHabits[index]
                                              .currentCompletions ==
                                          userData.userHabits[index]
                                              .requiredCompletions
                                      ? true
                                      : false,
                                  onDismissed: (direction) {
                                    userData.removeUserHabit(index);
                                    userData.updateUserData();
                                  },
                                  title: userData.userHabits[index].title,
                                  onLongPress: () {
                                    userData.userHabits[index]
                                        .decrementCompletion();
                                    userData.updateUserData();
                                  },
                                  onTap: () {
                                    if (userData.userHabits[index]
                                            .currentCompletions !=
                                        userData.userHabits[index]
                                            .requiredCompletions) {
                                      userData.userHabits[index]
                                          .incrementCompletion();
                                      userData.updateUserData();
                                    }
                                  },
                                  color: userData.userHabits[index].color)
                              : Container();
                        },
                        itemCount: userData.userHabits.length),
                  ),
                ),
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

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/components/navbar.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/constants.dart';

class HomeScreen extends StatelessWidget {
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
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'settings_screen');
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  color: kDarkBlue,
                  size: 30,
                ),
              ),
            ],
          ),
          body: Column(
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
                                currentValue: userData
                                        .userHabits[index].currentCompletions /
                                    userData
                                        .userHabits[index].requiredCompletions,
                                afterValue: userData
                                        .userHabits[index].currentCompletions /
                                    userData
                                        .userHabits[index].requiredCompletions,
                                completed: userData.userHabits[index]
                                            .currentCompletions ==
                                        userData.userHabits[index]
                                            .requiredCompletions
                                    ? true
                                    : false,
                                onDismissed: (direction) {
                                  Provider.of<UserData>(context, listen: false)
                                      .removeUserHabit(index);
                                },
                                title: userData.userHabits[index].title,
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
          bottomNavigationBar: NavBar(
            currentPage: 'home',
          ),
        );
      },
    );
  }
}

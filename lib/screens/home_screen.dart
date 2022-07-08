import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitur/components/navbar.dart';
import 'package:provider/provider.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/habit_card.dart';
import 'package:habitur/constants.dart';
import 'package:ionicons/ionicons.dart';

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
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good $timeOfDay, ',
                    style: kHeadingTextStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    DateFormat('EEEE, d').format(DateTime.now()),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            return HabitCard(
                                title: userData.userHabits[index].title,
                                onTap: () {
                                  userData.userHabits[index].isCompleted =
                                      !userData.userHabits[index].isCompleted;
                                  userData.updateUserData();
                                },
                                color: userData.userHabits[index].isCompleted ==
                                        true
                                    ? kAoEnglish
                                    : kDarkBlue);
                          },
                          itemCount: userData.userHabits.length),
                    ),
                  ),
                ],
              ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
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
                  color: kDarkBlueColor,
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
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HabitCard(
                          title: 'Test',
                          onTap: () {},
                        ),
                        HabitCard(
                          title: 'Test',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavBar(),
        );
      },
    );
  }
}

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          NavItem(
            icon: Icon(
              Icons.home_filled,
              color: kLightAccent,
              size: 25,
            ),
            onPressed: () {},
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
          NavItem(
            icon: Icon(
              Icons.line_axis_rounded,
              color: kLightAccent,
              size: 25,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  void Function() onPressed;
  Icon icon;
  NavItem({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}

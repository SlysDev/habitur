import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../providers/user_data.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            icon: Icon(
              Icons.menu_rounded,
              color: kDarkBlueColor,
              size: 30,
            ),
          ),
        ],
      ),
      body: Consumer<UserData>(
        builder: (context, userData, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text(
                  userData.userHabits.length == 0
                      ? 'You don\'t have any habits added yet.'
                      : 'Habits',
                  style: kHeadingTextStyle,
                  textAlign: TextAlign.center,
                ),
                ListView.builder(
                  itemBuilder: (context, index) {
                    return RadioListTile(
                        title: Text(
                          userData.userHabits[index].name,
                        ),
                        value: userData.userHabits[index].isCompleted,
                        groupValue: true,
                        onChanged: (changedValue) {
                          userData.userHabits[index].isCompleted =
                              changedValue as bool;
                        });
                  },
                  itemCount: userData.userHabits.length,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ionicons/ionicons.dart';
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
      body: HabitsSection(),
	  bottomNavigationBar: BottomNavigationBar(
		  showSelectedLabels: false,
		  showUnselectedLabels: false,
		  selectedItemColor: kDarkBlueColor,
		  unselectedItemColor: kLightAccent,
		  unselectedIconTheme: IconThemeData(
			  opacity: 0.5,
			  ),
		  selectedIconTheme: IconThemeData(
			  opacity: 1,
			  shadows: [
				  Shadow(
					  blurRadius: 60,
					  color: Colors.black54,
					  ),
			  ],
			  ),
			items: [
			  BottomNavigationBarItem(
				  icon: Icon(Ionicons.albums),
				  label: 'Home'
			  ),
			  BottomNavigationBarItem(
				  icon: Icon(Ionicons.stats_chart),
				  label: 'Stats'
			  ),
			  BottomNavigationBarItem(
				  icon: Icon(Ionicons.home),
				  label: 'Something'
			  ),
			]
		  ),
    );
  }
}

class HabitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Habits',
              style: kHeadingTextStyle,
            ),
            Expanded(
              child: ListView.builder(
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
                      userData.updateUserHabits();
                    },
                  );
                },
                itemCount: userData.userHabits.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

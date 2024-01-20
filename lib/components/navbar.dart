import 'package:flutter/material.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/screens/add_habit_screen.dart';

class NavBar extends StatelessWidget {
  String currentPage;
  NavBar({required this.currentPage});
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
              color: currentPage == 'home' ? kPrimaryColor : kGray,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          NavItem(
            icon: Icon(
              Icons.bar_chart,
              color: currentPage == 'statistics' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              if (currentPage == 'home') {
                Navigator.pushNamed(context, 'statistics_screen');
              } else {
                Navigator.popAndPushNamed(context, 'statistics_screen');
              }
            },
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    elevation: 20,
                    isScrollControlled: true,
                    builder: (context) => AddHabitScreen());
              },
              child: Icon(Icons.add),
            ),
          ),
          NavItem(
            icon: Icon(
              Icons.store,
              color: currentPage == 'marketplace' ? kPrimaryColor : kGray,
              size: 25,
            ),
            onPressed: () {
              if (currentPage == 'home') {
                Navigator.pushNamed(context, 'habit_selection_screen');
              } else {
                Navigator.popAndPushNamed(context, 'habit_selection_screen');
              }
            },
          ),
          NavItem(
            icon: Icon(
              Icons.settings,
              color: currentPage == 'settings' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              if (currentPage == 'home') {
                Navigator.pushNamed(context, 'settings_screen');
              } else {
                Navigator.popAndPushNamed(context, 'settings_screen');
              }
            },
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

import 'package:flutter/material.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/screens/add_habit_screen.dart';
import 'package:habitur/screens/admin-screen.dart';

class NavBar extends StatelessWidget {
  String currentPage;
  late dynamic onButtonPress;
  NavBar({required this.currentPage, this.onButtonPress});
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
              Navigator.pushNamedAndRemoveUntil(
                  context, 'home_screen', (route) => false);
            },
          ),
          NavItem(
            icon: Icon(
              Icons.done_all_rounded,
              color: currentPage == 'habits' ? kPrimaryColor : kGray,
              size: 25,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'habits_screen', (route) => false);
            },
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: onButtonPress == null
                  ? () {
                      showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          barrierColor: kPrimaryColor.withOpacity(0.2),
                          elevation: 0,
                          isScrollControlled: true,
                          builder: (context) => AddHabitScreen());
                    }
                  : onButtonPress,
              child: Icon(Icons.add),
            ),
          ),
          NavItem(
            icon: Icon(
              Icons.bar_chart,
              color: currentPage == 'statistics' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'statistics_screen', (route) => false);
            },
          ),
          NavItem(
            icon: Icon(
              Icons.settings,
              color: currentPage == 'settings' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'settings_screen', (route) => false);
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

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
      padding: EdgeInsets.only(bottom: 30, top: 15),
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          NavItem(
            icon: Icon(
              Icons.home_rounded,
              color: currentPage == 'home' ? kPrimaryColor : kGray,
              size: 25,
            ),
            onPressed: () {
              currentPage != 'home'
                  ? Navigator.pushNamedAndRemoveUntil(
                      context, 'home_screen', (route) => false)
                  : null;
            },
          ),
          NavItem(
            icon: Icon(
              Icons.check_circle_rounded,
              color: currentPage == 'habits' ? kPrimaryColor : kGray,
              size: 25,
            ),
            onPressed: () {
              currentPage != 'habits'
                  ? Navigator.pushNamedAndRemoveUntil(
                      context, 'habits_screen', (route) => false)
                  : null;
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
              Icons.bar_chart_rounded,
              color: currentPage == 'statistics' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              currentPage != 'statistics'
                  ? Navigator.pushNamedAndRemoveUntil(
                      context, 'statistics_screen', (route) => false)
                  : null;
            },
          ),
          NavItem(
            icon: Icon(
              Icons.settings_rounded,
              color: currentPage == 'settings' ? kPrimaryColor : kGray,
            ),
            onPressed: () {
              currentPage != 'settings'
                  ? Navigator.pushNamedAndRemoveUntil(
                      context, 'settings_screen', (route) => false)
                  : null;
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
    return IconButton(
      onPressed: onPressed,
      icon: icon,
    );
  }
}

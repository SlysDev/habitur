import 'package:flutter/material.dart';
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
              color: currentPage == 'home' ? kDarkBlue : kSlateGray,
              size: 25,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, 'home_screen');
            },
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context, builder: (context) => AddHabitScreen());
              },
              child: Icon(Icons.add),
            ),
          ),
          NavItem(
            icon: Icon(
              Icons.store,
              color: currentPage == 'marketplace' ? kDarkBlue : kSlateGray,
              size: 25,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, 'habit_selection_screen');
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

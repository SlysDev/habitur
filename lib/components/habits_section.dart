import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:provider/provider.dart';
import '../providers/user_data.dart';

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

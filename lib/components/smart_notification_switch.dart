import 'package:flutter/material.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class SmartNotificationSwitch extends StatefulWidget {
  Habit habit;
  SmartNotificationSwitch({super.key, required this.habit});

  @override
  State<SmartNotificationSwitch> createState() =>
      _SmartNotificationSwitchState();
}

class _SmartNotificationSwitchState extends State<SmartNotificationSwitch> {
  @override
  Widget build(BuildContext context) {
    return StaticCard(
      color: kFadedGreen,
      opacity: 0.2,
      padding: 10,
      child: SwitchListTile.adaptive(
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: kLightGreenAccent,
              size: 36,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                  MediaQuery.of(context).size.width > 600
                      ? 'Smart Notifications'
                      : 'Smart \n Notifications',
                  textAlign: TextAlign.center,
                  style: kMainDescription.copyWith(fontSize: 16)),
            ),
          ],
        ),
        onChanged: (value) {
          setState(() {
            widget.habit.smartNotifsEnabled = value;
          });
        },
        value: widget.habit.smartNotifsEnabled,
      ),
    );
  }
}

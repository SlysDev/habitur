import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/user_data.dart';
import 'package:intl/intl.dart';

class HomeGreetingHeader extends StatelessWidget {
  DateTime currentTime = DateTime.now();
  String timeOfDay = 'Day';
  @override
  Widget build(BuildContext context) {
    if (currentTime.hour > 3 && currentTime.hour < 12) {
      timeOfDay = 'Morning';
    } else if (currentTime.hour > 12 && currentTime.hour < 18) {
      timeOfDay = 'Afternoon';
    } else {
      timeOfDay = 'Evening';
    }
    return Column(children: [
      Text(
        'Good $timeOfDay',
        style: kTitleTextStyle,
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        'Today is ' +
            DateFormat('EEEE,').format(DateTime.now()) +
            ' ' +
            DateFormat('M').format(DateTime.now()) +
            '/' +
            DateFormat('d').format(DateTime.now()),
      ),
      const SizedBox(
        height: 80,
      ),
      Text(
        Provider.of<UserData>(context).habiturRating.toString(),
        style: kTitleTextStyle,
      )
    ]);
  }
}

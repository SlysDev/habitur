import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
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
        'Good $timeOfDay, ${Provider.of<UserData>(context, listen: false).currentUser.username}',
        style: kTitleTextStyle,
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 10,
      ),
      Text(
        'Today is ${DateFormat('EEEE,').format(DateTime.now())} ${DateFormat('M').format(DateTime.now())}/${DateFormat('d').format(DateTime.now())}',
        style: TextStyle(fontSize: 16),
      ),
      const SizedBox(
        height: 40,
      ),
      Center(
        child: Text(
          Provider.of<UserData>(context).currentUser.userLevel.toString(),
          style: kTitleTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        width: 300,
        margin: const EdgeInsets.only(top: 20),
        child: RoundedProgressBar(
          color: kPrimaryColor,
          progress: Provider.of<UserData>(context).currentUser.userXP /
              Provider.of<UserData>(context).levelUpRequirement,
        ),
      ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     // Container(width: 60, child: kHabiturLogo),
      //     // Container(
      //     //   child: Text(
      //     //     Provider.of<LevelingSystem>(context).currentUser.userLevel.toString(),
      //     //     style: kTitleTextStyle,
      //     //   ),
      //     // ),
      //     // CircularPercentIndicator(
      //     //   radius: 60,
      //     //   lineWidth: 20,
      //     //   progressColor: kDarkBlue,
      //     //   curve: Curves.ease,
      //     //   circularStrokeCap: CircularStrokeCap.round,
      //     //   percent: Provider.of<LevelingSystem>(context).currentUser.userXP /
      //     //       Provider.of<LevelingSystem>(context).levelUpRequirement,
      //     //   animation: true,
      //     //   animateFromLastPercent: true,
      //     //   center: Container(
      //     //     child: Text(
      //     //       Provider.of<LevelingSystem>(context).currentUser.userLevel.toString(),
      //     //       style: kTitleTextStyle,
      //     //     ),
      //     //   ),
      //     // ),
      //   ],
      // ),
    ]);
  }
}

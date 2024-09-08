import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/days_of_week_widget.dart';
import 'package:habitur/components/network_indicator.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:intl/intl.dart';

class HomeGreetingHeader extends StatelessWidget {
  DateTime currentTime = DateTime.now();
  String timeOfDay = 'Day';
  bool isLoading;
  HomeGreetingHeader({super.key, this.isLoading = false});
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
        'Good $timeOfDay, ' +
            (isLoading
                ? '...'
                : Provider.of<UserLocalStorage>(context, listen: false)
                    .currentUser
                    .username),
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
      SizedBox(height: 40),
      DaysOfWeekWidget(),
      const SizedBox(
        height: 30,
      ),
      const NetworkIndicator(),
      const SizedBox(
        height: 18,
      ),
      Center(
        child: Text(
          isLoading
              ? '...'
              : Provider.of<UserLocalStorage>(context)
                  .currentUser
                  .userLevel
                  .toString(),
          style: kTitleTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        width: 300,
        margin: const EdgeInsets.only(top: 20),
        child: RoundedProgressBar(
          color: kPrimaryColor,
          progress: isLoading
              ? 0
              : Provider.of<UserLocalStorage>(context).currentUser.userXP /
                  Provider.of<UserLocalStorage>(context)
                      .currentUser
                      .levelUpRequirement,
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

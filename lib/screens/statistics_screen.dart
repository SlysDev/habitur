import 'package:flutter/material.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/leveling_system.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Statistics',
          style: kHeadingTextStyle,
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 60),
              child: CircularPercentIndicator(
                radius: 100,
                lineWidth: 30,
                progressColor: kMainBlue,
                curve: Curves.ease,
                circularStrokeCap: CircularStrokeCap.round,
                percent: Provider.of<LevelingSystem>(context).habiturRating /
                    Provider.of<LevelingSystem>(context).levelUpRequirement,
                animation: true,
                animateFromLastPercent: true,
                center: Container(
                  child: Text(
                    Provider.of<LevelingSystem>(context).userLevel.toString(),
                    style: kTitleTextStyle,
                  ),
                ),
              ),
            ),
          ),
          // Center(
          //   child: Text(
          //     Provider.of<LevelingSystem>(context).userLevel.toString(),
          //     style: kTitleTextStyle,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // Container(
          //   margin: EdgeInsets.all(20),
          //   child: RoundedProgressBar(
          //     color: kDarkBlue,
          //     progress: Provider.of<LevelingSystem>(context).habiturRating /
          //         Provider.of<LevelingSystem>(context).levelUpRequirement,
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}

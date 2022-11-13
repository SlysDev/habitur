import 'package:flutter/material.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
          CircularPercentIndicator(
            lineWidth: 15,
            progressColor: kSlateGray,
            backgroundColor: Colors.transparent,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
            radius: 80,
            percent: .6,
            curve: Curves.ease,
            center: Text(
              '9',
              style: kHeadingTextStyle.copyWith(fontSize: 50),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}

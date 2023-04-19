import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/providers/statistics_manager.dart';
import '../components/navbar.dart';
import '../components/rounded_progress_bar.dart';
import '../constants.dart';
import '../providers/leveling_system.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/user_data.dart';

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
          SizedBox(
            height: 20,
          ),
          LineGraph(
              height: 200,
              data: Provider.of<StatisticsManager>(context).confidenceStats),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}

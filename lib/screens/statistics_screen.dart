import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habitur/components/aside_button.dart';
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
        title: Container(
          child: const Text(
            'Statistics',
            style: kTitleTextStyle,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
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
            height: 10,
          ),
          Text(
            'Habitur Rating',
            style: kHeadingTextStyle,
          ),
          const SizedBox(
            height: 40,
          ),
          LineGraph(
              height: 200,
              data: Provider.of<StatisticsManager>(context)
                  .displayedConfidenceStats),
          const SizedBox(
            height: 10,
          ),
          DropdownMenu(
            textStyle: const TextStyle(color: Colors.white),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: kMainBlue,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            menuStyle: MenuStyle(
              backgroundColor: MaterialStateProperty.all(kMainBlue),
            ),
            dropdownMenuEntries: const <DropdownMenuEntry>[
              DropdownMenuEntry(
                value: 0,
                label: 'This Week',
              ),
              DropdownMenuEntry(value: 1, label: 'This Month'),
              DropdownMenuEntry(value: 2, label: 'This Year'),
            ],
            onSelected: (value) {
              if (value == 0) {
                Provider.of<StatisticsManager>(context, listen: false)
                    .weekConfidenceView();
              } else if (value == 1) {
                Provider.of<StatisticsManager>(context, listen: false)
                    .monthConfidenceView();
              } else {
                Provider.of<StatisticsManager>(context, listen: false)
                    .yearConfidenceView();
              }
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}

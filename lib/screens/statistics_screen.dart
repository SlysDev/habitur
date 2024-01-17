import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card_list.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/modules/statistics_recorder.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:intl/intl.dart';
import '../components/navbar.dart';
import '../components/rounded_progress_bar.dart';
import '../constants.dart';
import '../providers/leveling_system.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/user_data.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Text(
              Provider.of<LevelingSystem>(context).userLevel.toString(),
              style: kTitleTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: RoundedProgressBar(
                lineHeight: 25,
                color: kPrimaryColor,
                progress: Provider.of<LevelingSystem>(context).habiturRating /
                    Provider.of<LevelingSystem>(context).levelUpRequirement,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
                "${Provider.of<LevelingSystem>(context).habiturRating} / ${Provider.of<LevelingSystem>(context).levelUpRequirement}",
                style: kHeadingTextStyle.copyWith(fontSize: 20)),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: HabitHeatMap(
                data:
                    // Converts stats array into a map (list --> iterable --> map)
                    Map<DateTime, int>.fromEntries(
                        Provider.of<SummaryStatisticsRepository>(context)
                            .completionStats
                            .map((dataPoint) => MapEntry(
                                DateTime(dataPoint.date.year,
                                    dataPoint.date.month, dataPoint.date.day),
                                dataPoint.value)))),
          ),
          const SizedBox(height: 40),
          const HabitStatsCardList(),
          const SizedBox(height: 20),
          // ... (your existing code)
        ],
      ),
      bottomNavigationBar: NavBar(
        currentPage: 'statistics',
      ),
    );
  }
}

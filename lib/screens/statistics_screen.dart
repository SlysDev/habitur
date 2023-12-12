import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/modules/statistics_manager.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
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
      body: ListView(
        children: [
          const SizedBox(height: 30),
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
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Habitur Rating',
              style: kHeadingTextStyle,
            ),
          ),
          HabitHeatMap(
            data:
                // Converts stats array into a map (list --> iterable --> map)
                Map.fromIterable(
                    Provider.of<SummaryStatisticsRepository>(context)
                        .completionStats
                        .map((element) => {element.date: element.value})),
          ),
          const SizedBox(height: 40),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Provider.of<HabitManager>(context).habits.length,
            itemBuilder: (BuildContext context, int index) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 20,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        Provider.of<HabitManager>(context).habits[index].title,
                        style: kHeadingTextStyle.copyWith(fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      physics: new NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      childAspectRatio: 1.7,
                      children: [
                        _buildStat(
                            "Completions",
                            Provider.of<HabitManager>(context)
                                .habits[index]
                                .totalCompletions
                                .toString()),
                        _buildStat(
                            "Streak 🔥",
                            Provider.of<HabitManager>(context)
                                .habits[index]
                                .streak
                                .toString()),
                        _buildStat(
                            "% Completion Rate",
                            (Provider.of<HabitManager>(context)
                                        .habits[index]
                                        .completionRate *
                                    100)
                                .toStringAsFixed(1)),
                        _buildStat(
                            "Confidence Level",
                            Provider.of<HabitManager>(context)
                                .habits[index]
                                .confidenceLevel
                                .toStringAsFixed(2)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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

Widget _buildStat(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        value,
        style: kHeadingTextStyle,
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: kMainDescription,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

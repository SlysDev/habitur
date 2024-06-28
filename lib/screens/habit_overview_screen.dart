import 'package:flutter/material.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class HabitOverviewScreen extends StatelessWidget {
  Habit habit;
  HabitOverviewScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    print(habit.completionStats[0].date);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                StaticCard(
                  child: Text(
                    habit.title,
                    style: kTitleTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                StaticCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Text(
                        '${habit.streak} 🔥',
                        style: kTitleTextStyle.copyWith(
                            color: Colors.white, fontSize: 60),
                      ),
                    ),
                  ),
                  color: Colors.orange.shade300,
                  opacity: 0.1,
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Confidence Level',
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                LineGraph(
                  data: habit.confidenceStats,
                  height: 200,
                  yAxisTitle: 'Confidence Level',
                  showDots: true,
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Calendar',
                    style: kHeadingTextStyle.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                HabitHeatMap(data: habit.completionStats),
                const SizedBox(height: 40),
                HabitStatsCard(habit: habit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

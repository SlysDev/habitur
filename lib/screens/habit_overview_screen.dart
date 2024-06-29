import 'package:flutter/material.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/single-stat-card.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class HabitOverviewScreen extends StatelessWidget {
  Habit habit;
  HabitOverviewScreen({super.key, required this.habit});

  double getConfidenceChange(List<DataPoint> stats) {
    if (stats.length < 2) return 0.0;
    return stats.last.value - stats[stats.length - 2].value;
  }

  @override
  Widget build(BuildContext context) {
    double confidenceChange = getConfidenceChange(habit.confidenceStats);
    String changeText = confidenceChange > 0
        ? confidenceChange.toStringAsFixed(1)
        : confidenceChange.toStringAsFixed(1);
    String changeSymbol = confidenceChange > 0 ? '↑' : '↓';

    print(habit.completionStats[0].date);
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 40),
                LineGraph(
                  data: habit.confidenceStats,
                  height: 200,
                  showDots: true,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confidence Level',
                      style: kHeadingTextStyle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    StaticCard(
                      color: confidenceChange > 0
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      opacity: 0.2,
                      child: Text(
                        '$changeText $changeSymbol',
                        style: TextStyle(
                          color:
                              confidenceChange > 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  shrinkWrap: true,
                  children: [
                    SingleStatCard(
                        statText: habit.streak.toString(),
                        statDescription: 'Streak',
                        fontSize: 40,
                        color: Colors.orange.shade300),
                    SingleStatCard(
                        statText: habit.totalCompletions.toString(),
                        statDescription: 'Total Completions',
                        fontSize: 40,
                        color: Colors.green.shade300),
                    SingleStatCard(
                        statText:
                            (habit.completionRate * 100).toStringAsFixed(0) +
                                '%',
                        statDescription: 'Completion Rate',
                        fontSize: 40,
                        color: Colors.blue.shade300),
                    SingleStatCard(
                      statText: habit.highestStreak.toString(),
                      statDescription: 'Highest Streak',
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                StaticCard(
                  child: HabitHeatMap(data: habit.completionStats),
                  opacity: 0.3,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

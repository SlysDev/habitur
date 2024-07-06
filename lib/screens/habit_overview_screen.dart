import 'package:flutter/material.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/habit_stats_card.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/single-stat-card.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/data_point.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_insights_generator.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/providers/summary_statistics_repository.dart';
import 'package:provider/provider.dart';

class HabitOverviewScreen extends StatelessWidget {
  Habit habit;
  HabitOverviewScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    HabitInsightsGenerator insightsGenerator =
        HabitInsightsGenerator(habit, statsCalculator);
    double confidenceChange = statsCalculator.calculateConfidenceChange();
    String changeSymbol = confidenceChange > 0 ? '↑' : '↓';
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
                StaticCard(
                  opacity: 0.3,
                  child: Column(
                    children: [
                      LineGraph(
                        data: habit.stats,
                        height: 200,
                        showDots: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Confidence Level',
                            style:
                                kHeadingTextStyle.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          StaticCard(
                            color: confidenceChange > 0
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                            opacity: 0.2,
                            child: Text(
                              '${confidenceChange.toStringAsFixed(2)} $changeSymbol',
                              style: TextStyle(
                                color: confidenceChange > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  children: [
                    StaticCard(
                      child: Icon(Icons.lightbulb),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        insightsGenerator.findAreaForImprovement()['message'],
                        style: kMainDescription,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
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
                      color: Colors.orange.shade300,
                    ),
                    SingleStatCard(
                      statText: habit.highestStreak.toString(),
                      statDescription: 'Highest Streak',
                      fontSize: 40,
                      color: Colors.white,
                    ),
                    SingleStatCard(
                      statText: statsCalculator
                          .calculateAverageCompletionsPerWeek()
                          .toStringAsFixed(1),
                      statDescription: 'Average Weekly Completions',
                      fontSize: 40,
                      color: Colors.green.shade300,
                    ),
                    SingleStatCard(
                      statText: habit.stats.length < 7
                          ? (statsCalculator.calculateConsistencyFactor(
                                          period: habit.stats.length) *
                                      100)
                                  .toStringAsFixed(0) +
                              '%'
                          : (statsCalculator.calculateConsistencyFactor() * 100)
                                  .toStringAsFixed(0) +
                              '%',
                      statDescription: '7-day Consistency',
                      fontSize: 40,
                      color: Colors.teal.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                StaticCard(
                  child: HabitHeatMap(data: habit.stats),
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

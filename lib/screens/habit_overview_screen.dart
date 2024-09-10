import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/empty_stats_widget.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/insight_display.dart';
import 'package:habitur/components/line_graph.dart';
import 'package:habitur/components/multi_stat_line_graph.dart';
import 'package:habitur/components/single-stat-card.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/insights_generator.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';

class HabitOverviewScreen extends StatelessWidget {
  Habit habit;
  HabitOverviewScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    HabitStatsCalculator statsCalculator = HabitStatsCalculator(habit);
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: habit.stats.isEmpty
              ? EmptyStatsWidget()
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 40),
                    MultiStatLineGraph(
                      data: habit.stats,
                      showStatTitle: true,
                      height: 250,
                      showChangeIndicator: true,
                    ),
                    const SizedBox(height: 60),
                    InsightDisplay(
                      stats: habit.stats,
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
                              .calculateAverageCompletionsPerWeek(habit.stats)
                              .toStringAsFixed(1),
                          statDescription: 'Average Weekly Completions',
                          fontSize: 40,
                          color: Colors.green.shade300,
                        ),
                        SingleStatCard(
                          statText: habit.stats.length < 7
                              ? (statsCalculator.calculateConsistencyFactor(
                                              habit.stats,
                                              habit.requiredCompletions,
                                              period: habit.stats.length) *
                                          100)
                                      .toStringAsFixed(0) +
                                  '%'
                              : (statsCalculator.calculateConsistencyFactor(
                                              habit.stats,
                                              habit.requiredCompletions) *
                                          100)
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/habit_heat_map.dart';
import 'package:habitur/components/insight_display.dart';
import 'package:habitur/components/line_graph.dart';
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
    print('Overview Screen - habit.stats: ${habit.stats}');
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    InsightsGenerator insightsGenerator = InsightsGenerator(habit.stats);
    Map<String, dynamic> improvementData =
        insightsGenerator.findAreaForImprovement();
    String insightPreText = improvementData['message']['preText'];
    String insightPercentChange =
        improvementData['message']['percentChange'].toString();
    String insightPostText = improvementData['message']['postText'];

    double confidenceChange =
        statsCalculator.calculateStatChange(habit.stats, 'confidenceLevel');
    String changeSymbol = confidenceChange > 0 ? '↑' : '↓';
    changeSymbol = confidenceChange == 0 ? '–' : changeSymbol;
    Color changeColor = confidenceChange > 0 ? Colors.green : Colors.red;
    changeColor = confidenceChange == 0 ? Colors.white60 : changeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: habit.stats.isEmpty
                ? EmptyStatsWidget()
                : ListView(
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
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                StaticCard(
                                  color: changeColor,
                                  opacity: 0.2,
                                  child: Text(
                                    '${confidenceChange.toStringAsFixed(2)} $changeSymbol',
                                    style: TextStyle(
                                      color: changeColor,
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
                      InsightDisplay(
                          insightPreText: insightPreText,
                          insightPercentChange: insightPercentChange,
                          insightPostText: insightPostText),
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
      ),
    );
  }
}

class EmptyStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Ensures widget takes up more space
      height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
      child: Stack(
        children: [
          Container(
            // Background decoration
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kOrangeAccent.withOpacity(0.5),
                  Colors.orange.shade200.withOpacity(0.5),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Content fits within
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Looks like this is a new habit!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check back once you\'ve logged a completion to see your stats!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Inspirational quote
                  Text(
                    '"The journey of a thousand miles begins with a single step." - Lao Tzu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

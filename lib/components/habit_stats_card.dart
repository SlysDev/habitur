import 'package:flutter/material.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/modules/habit_stats_calculator.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class HabitStatsCard extends StatelessWidget {
  HabitStatsCard({super.key, required this.habit});
  Habit habit;

  @override
  Widget build(BuildContext context) {
    HabitStatisticsCalculator statsCalculator =
        HabitStatisticsCalculator(habit);
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: StaticCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                habit.title,
                style: kHeadingTextStyle.copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              childAspectRatio: 1.7,
              children: [
                _buildStat("Completions", habit.totalCompletions.toString()),
                _buildStat("Streak 🔥", habit.streak.toString()),
                _buildStat(
                    "Consistency",
                    (statsCalculator.calculateConsistencyFactor(
                                    habit.stats, habit.requiredCompletions) *
                                100)
                            .toStringAsFixed(0) +
                        "%"),
                _buildStat("Confidence Level",
                    habit.confidenceLevel.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
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

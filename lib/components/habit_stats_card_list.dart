import 'package:flutter/material.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

class HabitStatsCardList extends StatelessWidget {
  const HabitStatsCardList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Provider.of<HabitManager>(context).habits.length,
      itemBuilder: (BuildContext context, int index) =>
          HabitStatsCard(index: index),
    );
  }
}

class HabitStatsCard extends StatelessWidget {
  HabitStatsCard({super.key, required this.index});
  int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kFadedBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 20,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
              physics: const NeverScrollableScrollPhysics(),
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

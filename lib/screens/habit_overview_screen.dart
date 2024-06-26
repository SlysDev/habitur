import 'package:flutter/material.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: [
                Text(
                  habit.title,
                  style: kTitleTextStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                StaticCard(
                  child: LineGraph(
                    data: Provider.of<SummaryStatisticsRepository>(context)
                        .confidenceStats,
                    height: 300,
                    yAxisTitle: 'Confidence Level',
                    showDots: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

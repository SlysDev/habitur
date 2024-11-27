import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/empty_stats_widget.dart';
import 'package:habitur/ui/widgets/habit_heat_map/habit_heat_map.dart';
import 'package:habitur/components/insight_display.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';
import 'package:habitur/components/multi_stat_line_graph.dart';
import 'package:habitur/ui/widgets/single-stat-card.dart';
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
  }
}

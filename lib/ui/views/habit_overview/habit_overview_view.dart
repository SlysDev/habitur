import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/services/stats/stats_calculation_service.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/ui/views/habit_overview/habit_overview_viewmodel.dart';

import '../../../app/app.locator.dart';
import '../../widgets/empty_stats/empty_stats.dart';
import '../../widgets/habit_heat_map/habit_heat_map.dart';
import '../../widgets/insight_display/insight_display.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/multi_stat_line_graph/multi_stat_line_graph.dart';
import '../../widgets/single-stat-card.dart';

class HabitOverviewView extends StackedView<HabitOverviewViewModel> {
  final String habitId;
  final _statsCalculationService = locator<StatsCalculationService>();

  HabitOverviewView({
    required this.habitId,
    Key? key,
  }) : super(key: key);

  @override
  Widget builder(
      BuildContext context, HabitOverviewViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(viewModel.habit?.title ?? ''),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: viewModel.habit?.stats?.isEmpty ?? true
            ? EmptyStats()
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 40),
                  MultiStatLineGraph(
                    data: viewModel.habit!.stats,
                    showStatTitle: true,
                    height: 250,
                    showChangeIndicator: true,
                  ),
                  const SizedBox(height: 60),
                  InsightDisplay(
                    stats: viewModel.habit?.stats ?? [],
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
                        statText: viewModel.habit?.streak.toString() ?? '',
                        statDescription: 'Streak',
                        fontSize: 40,
                        color: Colors.orange.shade300,
                      ),
                      SingleStatCard(
                        statText:
                            viewModel.habit?.highestStreak.toString() ?? '',
                        statDescription: 'Highest Streak',
                        fontSize: 40,
                        color: Colors.white,
                      ),
                      SingleStatCard(
                        statText: _statsCalculationService
                            .calculateAverageValueForStat(
                                viewModel.habit!.stats, 'confidenceLevel')
                            .toStringAsFixed(1),
                        statDescription: 'Average Weekly Completions',
                        fontSize: 40,
                        color: Colors.green.shade300,
                      ),
                      SingleStatCard(
                        statText: (viewModel.habit?.stats?.length ?? 0) < 7
                            ? '${(_statsCalculationService.calculateConsistencyFactor(viewModel.habit!.stats, viewModel.habit!.targetGoal, period: viewModel.habit!.stats.length) * 100).toStringAsFixed(0)}%'
                            : '${(_statsCalculationService.calculateConsistencyFactor(viewModel.habit!.stats, viewModel.habit!.targetGoal) * 100).toStringAsFixed(0)}%',
                        statDescription: '7-day Consistency',
                        fontSize: 40,
                        color: Colors.teal.shade300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ModernCard(
                    opacity: 0.15,
                    child: HabitHeatMap(data: viewModel.habit!.stats),
                  ),
                  SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  @override
  HabitOverviewViewModel viewModelBuilder(BuildContext context) {
    final viewModel = HabitOverviewViewModel();
    viewModel.initialize(habitId);
    return viewModel;
  }
}

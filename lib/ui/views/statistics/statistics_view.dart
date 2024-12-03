import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/insight_display/insight_display.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'statistics_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StackedView<StatisticsViewModel> {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, StatisticsViewModel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : LoadingOverlay(
              isLoading: viewModel.isBusy,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverallStats(viewModel),
                        const SizedBox(height: 24),
                        InsightDisplay(stats: viewModel.statPoints),
                        const SizedBox(height: 24),
                        LineGraph(
                            data: viewModel.statPoints,
                            title: 'Confidence Level',
                            statName: 'confidenceLevel'),
                        const SizedBox(height: 24),
                        LineGraph(
                            data: viewModel.statPoints,
                            title: 'Consistency',
                            statName: 'consistencyFactor'),
                        const SizedBox(height: 24),
                        LineGraph(
                            data: viewModel.statPoints,
                            title: 'Streak',
                            statName: 'streak'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const NavBar(
        currentPage: 'stats',
      ),
    );
  }

  Widget _buildOverallStats(StatisticsViewModel viewModel) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: kTitleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Total Habits', viewModel.totalHabits.toString()),
                _buildStatItem('Completion Rate',
                    '${(viewModel.completionRate * 100).toStringAsFixed(1)}%'),
                _buildStatItem('Best Streak', viewModel.bestStreak.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: kTitleTextStyle.copyWith(fontSize: 24),
        ),
        Text(
          label,
          style: kSubDescription,
        ),
      ],
    );
  }

  Widget _buildCompletionChart(StatisticsViewModel viewModel) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion History',
              style: kTitleTextStyle,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakChart(StatisticsViewModel viewModel) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak History',
              style: kTitleTextStyle,
            ),
            const SizedBox(height: 16),
            LineGraph(
                data: viewModel.statPoints,
                title: 'Streak',
                statName: 'streak'),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStats(StatisticsViewModel viewModel) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Statistics',
              style: kTitleTextStyle,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.habitStats.length,
              itemBuilder: (context, index) {
                final stat = viewModel.habitStats[index];
                return ListTile(
                  title: Text(viewModel.habits[index].title),
                  subtitle: Text(
                    'Completion Rate: ${(stat.consistencyFactor * 100).toStringAsFixed(1)}% • '
                    'Streak: ${stat.streak}',
                  ),
                  trailing: CircularProgressIndicator(
                    value: stat.consistencyFactor,
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  StatisticsViewModel viewModelBuilder(BuildContext context) {
    final viewModel = StatisticsViewModel();
    viewModel.initialize();
    return viewModel;
  }
}

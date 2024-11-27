import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStats(viewModel),
                    const SizedBox(height: 24),
                    _buildCompletionChart(viewModel),
                    const SizedBox(height: 24),
                    _buildStreakChart(viewModel),
                    const SizedBox(height: 24),
                    _buildHabitStats(viewModel),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallStats(StatisticsViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: kTitleTextStyle,
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
    return Card(
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
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.completionData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakChart(StatisticsViewModel viewModel) {
    return Card(
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
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.streakData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStats(StatisticsViewModel viewModel) {
    return Card(
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
                  title: Text(stat.habitName),
                  subtitle: Text(
                    'Completion Rate: ${(stat.completionRate * 100).toStringAsFixed(1)}% • '
                    'Streak: ${stat.streak}',
                  ),
                  trailing: CircularProgressIndicator(
                    value: stat.completionRate,
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
  StatisticsViewModel viewModelBuilder(BuildContext context) =>
      StatisticsViewModel();
}

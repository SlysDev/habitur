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
        title: Text(
          viewModel.habit?.title ?? '',
          style: kSubHeadingTextStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          _buildCustomPopupMenu(context, viewModel),
        ],
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
                                viewModel.habit!.stats, 'completions')
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

  Widget _buildCustomPopupMenu(
      BuildContext context, HabitOverviewViewModel viewModel) {
    return GestureDetector(
      onTapDown: (details) =>
          _showCustomPopupMenu(context, viewModel, details.globalPosition),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kFadedBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showCustomPopupMenu(BuildContext context,
      HabitOverviewViewModel viewModel, Offset tapPosition) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        position.dy + kToolbarHeight,
        tapPosition.dx + 50,
        0,
      ),
      color: kFadedBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      items: [
        if (!(viewModel.habit?.isCommunityHabit ?? true))
          PopupMenuItem(
            value: 'share',
            child: _buildPopupMenuItem(
              icon: Icons.group_add,
              text: 'Share Habit',
              color: kPrimaryColor,
            ),
          ),
        PopupMenuItem(
          value: 'edit',
          child: _buildPopupMenuItem(
            icon: Icons.edit,
            text: 'Edit Habit',
            color: kLightPrimaryColor,
          ),
        ),
      ],
    );

    if (result != null) {
      switch (result) {
        case 'share':
          await viewModel.shareHabit();
          break;
        case 'edit':
          viewModel.navigateToEditHabit();
          break;
      }
    }
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: kFadedBlue.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

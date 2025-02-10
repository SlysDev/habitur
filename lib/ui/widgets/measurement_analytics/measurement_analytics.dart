import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';
import 'package:stacked/stacked.dart';
import 'measurement_analytics_model.dart';

class MeasurementAnalytics extends StackedView<MeasurementAnalyticsModel> {
  final List<StatPoint> stats;
  final String measurementUnit;
  final double targetGoal;

  const MeasurementAnalytics({
    super.key,
    required this.stats,
    required this.measurementUnit,
    required this.targetGoal,
  });

  @override
  Widget builder(
    BuildContext context,
    MeasurementAnalyticsModel viewModel,
    Widget? child,
  ) {
    return ModernCard(
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Measurement Analytics',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            verticalSpaceMedium,

            // Stats Grid
            LayoutBuilder(builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _buildStatCard(
                    'Daily Avg',
                    '${viewModel.averageDaily.toInt()} $measurementUnit',
                    'Last 7 days',
                    kPrimaryColor,
                  ),
                  _buildStatCard(
                    'Best Day',
                    '${viewModel.bestDay.toInt()} $measurementUnit',
                    'Personal record',
                    Colors.orange.shade300,
                  ),
                  _buildStatCard(
                    'Total',
                    '${viewModel.total.toInt()} $measurementUnit',
                    'All time',
                    Colors.green.shade300,
                  ),
                  _buildStatCard(
                    'Progress',
                    '${(viewModel.goalProgress * 100).toInt()}%',
                    'Of daily target',
                    Colors.teal.shade300,
                  ),
                ],
              );
            }),
            verticalSpaceMedium,

            // Trend Analysis
            if (viewModel.insights.isNotEmpty) ...[
              Text(
                'Insights',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              verticalSpaceSmall,
              ...viewModel.insights
                  .map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.insights_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ),
                            horizontalSpaceSmall,
                            Expanded(
                              child: Text(
                                insight,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatChip(
            icon: _getIconForTitle(title),
            label: title,
            color: color,
            size: 0.85,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Daily Avg':
        return Icons.calendar_today_rounded;
      case 'Best Day':
        return Icons.emoji_events_rounded;
      case 'Total':
        return Icons.bar_chart_rounded;
      case 'Progress':
        return Icons.track_changes_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  @override
  MeasurementAnalyticsModel viewModelBuilder(BuildContext context) =>
      MeasurementAnalyticsModel(
        stats: stats,
        targetGoal: targetGoal,
      );
}

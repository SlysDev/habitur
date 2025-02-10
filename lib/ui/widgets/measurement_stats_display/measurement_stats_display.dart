import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/circular_progress_indicator/circular_progress_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';

import 'measurement_stats_display_model.dart';

class MeasurementStatsDisplay
    extends StackedView<MeasurementStatsDisplayModel> {
  final List<StatPoint> stats;
  final String measurementUnit;
  final double targetGoal;
  final double currentProgress;

  const MeasurementStatsDisplay({
    Key? key,
    required this.stats,
    required this.measurementUnit,
    required this.targetGoal,
    required this.currentProgress,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MeasurementStatsDisplayModel viewModel,
    Widget? child,
  ) {
    return ModernCard(
      padding: 0,
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF092d55).withOpacity(0.1),
              kPrimaryColor.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Daily ${measurementUnit}s',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TARGET',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      targetGoal.toStringAsFixed(0),
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpaceMedium,

            // Progress section with circular indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Completed ${currentProgress.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(targetGoal - currentProgress).toStringAsFixed(0)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 64,
                              height: 1,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          horizontalSpaceSmall,
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  measurementUnit,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    height: 1,
                                    color: Colors.white38,
                                  ),
                                ),
                                Text(
                                  'LEFT',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    height: 1.2,
                                    letterSpacing: 0.5,
                                    color: Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                horizontalSpaceMedium,
                HabiturCircularProgress(
                  progress: (currentProgress / targetGoal).clamp(0.0, 1.0),
                  size: 120,
                  progressColor: kPrimaryColor,
                  backgroundColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(currentProgress / targetGoal * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  MeasurementStatsDisplayModel viewModelBuilder(BuildContext context) =>
      MeasurementStatsDisplayModel()..initialize(stats);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/stat_point.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:stacked/stacked.dart';

import 'time_of_day_analysis_model.dart';

class TimeOfDayAnalysis extends StackedView<TimeOfDayAnalysisModel> {
  final List<StatPoint> stats;
  final String measurementUnit;

  const TimeOfDayAnalysis({
    super.key,
    required this.stats,
    required this.measurementUnit,
  });

  @override
  Widget builder(
    BuildContext context,
    TimeOfDayAnalysisModel viewModel,
    Widget? child,
  ) {
    return ModernCard(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Time Analysis',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (viewModel.bestTimeBlock != 'Not enough data')
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Best: ',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: kPrimaryColor.withOpacity(0.7),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              viewModel.bestTimeBlock,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            verticalSpaceMedium,

            // Time blocks section
            ...viewModel.timeBlocks.map((block) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            block.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            '${block.completions} ${block.completions == 1 ? 'time' : 'times'}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceSmall,
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width:
                                      constraints.maxWidth * block.percentage,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        block.name == viewModel.bestTimeBlock
                                            ? kPrimaryColor
                                            : Colors.white.withOpacity(0.3),
                                        block.name == viewModel.bestTimeBlock
                                            ? kPrimaryColor.withOpacity(0.7)
                                            : Colors.white.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (block.name == viewModel.bestTimeBlock) ...[
                        verticalSpaceSmall,
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: kPrimaryColor,
                              size: 16,
                            ),
                            horizontalSpaceTiny,
                            Text(
                              'Most successful time for $measurementUnit',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )),

            // Performance patterns section
            if (viewModel.hasEnoughData && viewModel.patterns.isNotEmpty) ...[
              verticalSpaceMedium,
              Text(
                'Performance Patterns',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              verticalSpaceSmall,
              ...viewModel.patterns.map((pattern) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                            pattern,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  TimeOfDayAnalysisModel viewModelBuilder(BuildContext context) =>
      TimeOfDayAnalysisModel(stats: stats);
}

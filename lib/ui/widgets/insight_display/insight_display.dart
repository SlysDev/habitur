import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../models/stat_point.dart';
import 'insight_display_model.dart';

class InsightDisplay extends StackedView<InsightDisplayModel> {
  const InsightDisplay(
      {super.key, required this.stats, this.isSummary = false});

  final List<StatPoint> stats;
  final bool isSummary;

  @override
  Widget builder(
    BuildContext context,
    InsightDisplayModel viewModel,
    Widget? child,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kOrangeAccent.withOpacity(0.15),
            kOrangeAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kOrangeAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: kOrangeAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Trends',
                    style: TextStyle(
                      color: kOrangeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: viewModel.insightPreText),
                        if (viewModel.insightPercentChange.isNotEmpty &&
                            viewModel.insightPercentChange != '0.0%')
                          TextSpan(
                            text: ' ${viewModel.insightPercentChange} ',
                            style: TextStyle(
                              color: kOrangeAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        TextSpan(text: viewModel.insightPostText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  InsightDisplayModel viewModelBuilder(
    BuildContext context,
  ) {
    final viewModel = InsightDisplayModel();
    viewModel.initialize(stats, isSummary);
    return viewModel;
  }
}

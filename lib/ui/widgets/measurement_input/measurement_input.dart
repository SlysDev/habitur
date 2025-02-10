import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:stacked/stacked.dart';

import 'measurement_input_model.dart';

class MeasurementInput extends StackedView<MeasurementInputModel> {
  final double value;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final double stepSize;
  final Function(double) onChanged;
  final bool showQuickAdjust;

  const MeasurementInput({
    super.key,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.minValue,
    this.maxValue,
    this.stepSize = 1.0,
    this.showQuickAdjust = true,
  });

  @override
  Widget builder(
    BuildContext context,
    MeasurementInputModel viewModel,
    Widget? child,
  ) {
    return ModernCard(
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showQuickAdjust) ...[
              _buildAdjustButton(
                context,
                Icons.remove_rounded,
                () => viewModel.decrementValue(),
                viewModel.isDecrementEnabled,
                viewModel,
              ),
              horizontalSpaceSmall,
            ],
            Container(
              width: 70,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.textController.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showQuickAdjust) ...[
              horizontalSpaceSmall,
              _buildAdjustButton(
                context,
                Icons.add_rounded,
                () => viewModel.incrementValue(),
                viewModel.isIncrementEnabled,
                viewModel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool enabled,
    MeasurementInputModel viewModel,
  ) {
    return GestureDetector(
      onTapDown: (details) {
        if (enabled) {
          HapticFeedback.lightImpact();
          onPressed();
          // Start continuous adjustment after long press
          Future.delayed(const Duration(milliseconds: 500), () {
            viewModel.startContinuousAdjustment(
              isIncrement: icon == Icons.add_rounded,
            );
          });
        }
      },
      onTapUp: (_) => viewModel.stopContinuousAdjustment(),
      onTapCancel: () => viewModel.stopContinuousAdjustment(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 20,
        ),
      ),
    );
  }

  @override
  MeasurementInputModel viewModelBuilder(BuildContext context) =>
      MeasurementInputModel(
        initialValue: value,
        minValue: minValue,
        maxValue: maxValue,
        stepSize: stepSize,
        onChanged: onChanged,
      );
}

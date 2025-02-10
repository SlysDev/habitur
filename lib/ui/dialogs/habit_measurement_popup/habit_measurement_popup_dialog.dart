import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/measurement_input/measurement_input.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import './habit_measurement_popup_dialog_model.dart';

class HabitMeasurementPopupDialog
    extends StackedView<HabitMeasurementPopupDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const HabitMeasurementPopupDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HabitMeasurementPopupDialogModel viewModel,
    Widget? child,
  ) {
    final measurementUnit = request.data?["unit"] ?? "";
    final maxValue = (request.data?["maxValue"] as num?)?.toDouble() ?? 100.0;
    final initialValue = (request.data?["currentValue"] as num?)?.toDouble();

    // Initialize the view model with the current value
    viewModel.initialize(initialValue);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      request.title ?? 'Track Progress',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (request.description != null) ...[
                      verticalSpaceSmall,
                      Text(
                        request.description!,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Measurement Input
                    MeasurementInput(
                      value: viewModel.currentValue,
                      unit: measurementUnit,
                      minValue: 0,
                      maxValue: maxValue,
                      stepSize: 1,
                      onChanged: viewModel.updateValue,
                    ),
                    verticalSpaceMedium,

                    // Progress Indicator
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${viewModel.currentValue.toInt()}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                Text(
                                  ' / ${maxValue.toInt()}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Text(
                                  '(${(viewModel.currentValue / maxValue * 100).toInt()}%)',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpaceSmall,
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: constraints.maxWidth *
                                        (viewModel.currentValue / maxValue)
                                            .clamp(0.0, 1.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kPrimaryColor,
                                          kPrimaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: viewModel.cancelDialog,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    horizontalSpaceSmall,
                    // Save Button
                    ElevatedButton(
                      onPressed: viewModel.submitDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  HabitMeasurementPopupDialogModel viewModelBuilder(BuildContext context) =>
      HabitMeasurementPopupDialogModel();
}

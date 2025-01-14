import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import './habit_measurement_popup_dialog_model.dart';

class HabitMeasurementPopupDialog extends StackedView<HabitMeasurementPopupDialogModel> {
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Dialog(
        backgroundColor: kBackgroundColor,
        child: Container(
          alignment: Alignment.center,
          height: 300,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter how much you completed:',
                style: kHeadingTextStyle,
                textAlign: TextAlign.center,
              ),
              Slider(
                value: viewModel.currentValue,
                min: 0,
                max: 100, // or more, depending on your use case
                divisions: 100,
                onChanged: viewModel.updateValue,
              ),
              Text('${viewModel.currentValue.toInt()}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: viewModel.submitDialog,
                child: const Text('Done'),
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
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:stacked/stacked.dart';
import 'measurement_toggle_model.dart';

class MeasurementToggle extends StackedView<MeasurementToggleModel> {
  final bool usesMeasurement;
  final String measurementUnit;
  final Function(bool) onUsesMeasurementChanged;
  final Function(String) onMeasurementUnitChanged;

  const MeasurementToggle({
    super.key,
    required this.usesMeasurement,
    required this.measurementUnit,
    required this.onUsesMeasurementChanged,
    required this.onMeasurementUnitChanged,
  });

  @override
  Widget builder(
    BuildContext context,
    MeasurementToggleModel viewModel,
    Widget? child,
  ) {
    return ModernCard(
      color: kFadedBlue,
      opacity: 0.1,
      padding: 10,
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Row(
              children: [
                Icon(
                  Icons.straighten,
                  color: kLightPrimaryColor,
                  size: 30,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Track Measurements',
                    textAlign: TextAlign.center,
                    style: kMainDescription.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            value: viewModel.usesMeasurement,
            onChanged: viewModel.toggleMeasurement,
          ),
          if (viewModel.usesMeasurement) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: viewModel.unitController,
                decoration: InputDecoration(
                  labelText: 'Unit (e.g. pages, miles)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  @override
  MeasurementToggleModel viewModelBuilder(BuildContext context) =>
      MeasurementToggleModel(
        usesMeasurement: usesMeasurement,
        measurementUnit: measurementUnit,
        onUsesMeasurementChanged: onUsesMeasurementChanged,
        onMeasurementUnitChanged: onMeasurementUnitChanged,
      );
}
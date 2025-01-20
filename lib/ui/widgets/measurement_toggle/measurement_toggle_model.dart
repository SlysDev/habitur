import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MeasurementToggleModel extends BaseViewModel {
  final bool initialUsesMeasurement;
  final String initialMeasurementUnit;
  final Function(bool) onUsesMeasurementChanged;
  final Function(String) onMeasurementUnitChanged;

  late TextEditingController unitController;
  bool _usesMeasurement = false;

  MeasurementToggleModel({
    required bool usesMeasurement,
    required String measurementUnit,
    required this.onUsesMeasurementChanged,
    required this.onMeasurementUnitChanged,
  })  : initialUsesMeasurement = usesMeasurement,
        initialMeasurementUnit = measurementUnit {
    _usesMeasurement = usesMeasurement;
    unitController = TextEditingController(text: measurementUnit);
    unitController.addListener(_onUnitChanged);
  }

  bool get usesMeasurement => _usesMeasurement;

  void toggleMeasurement(bool value) {
    _usesMeasurement = value;
    onUsesMeasurementChanged(value);
    rebuildUi();
  }

  void _onUnitChanged() {
    onMeasurementUnitChanged(unitController.text);
  }

  @override
  void dispose() {
    unitController.dispose();
    super.dispose();
  }
}

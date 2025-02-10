import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MeasurementInputModel extends BaseViewModel {
  final double initialValue;
  final double? minValue;
  final double? maxValue;
  final double stepSize;
  final Function(double) onChanged;

  late TextEditingController textController;
  Timer? _continuousAdjustmentTimer;

  MeasurementInputModel({
    required this.initialValue,
    required this.onChanged,
    this.minValue,
    this.maxValue,
    this.stepSize = 1.0,
  }) {
    textController = TextEditingController(text: initialValue.toString());
  }

  bool get isIncrementEnabled =>
      maxValue == null || getCurrentValue() < maxValue!;
  bool get isDecrementEnabled =>
      minValue == null || getCurrentValue() > minValue!;

  double getCurrentValue() {
    return double.tryParse(textController.text) ?? initialValue;
  }

  void incrementValue() {
    final newValue = getCurrentValue() + stepSize;
    if (maxValue == null || newValue <= maxValue!) {
      updateValue(newValue);
    }
  }

  void decrementValue() {
    final newValue = getCurrentValue() - stepSize;
    if (minValue == null || newValue >= minValue!) {
      updateValue(newValue);
    }
  }

  void updateValue(double newValue) {
    final intValue = newValue.toInt();
    double currentValue = intValue.toDouble();
    textController.text = intValue.toString();
    onChanged(currentValue);
    notifyListeners();
  }

  void onTextChanged(String value) {
    if (value.isEmpty) {
      onChanged(0);
      return;
    }

    final newValue = int.tryParse(value)?.toDouble() ?? 0;
    if (minValue != null && newValue < minValue!) {
      updateValue(minValue!);
    } else if (maxValue != null && newValue > maxValue!) {
      updateValue(maxValue!);
    } else {
      onChanged(newValue);
    }
  }

  void startContinuousAdjustment({required bool isIncrement}) {
    _continuousAdjustmentTimer?.cancel();
    _continuousAdjustmentTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (isIncrement) {
          incrementValue();
        } else {
          decrementValue();
        }
      },
    );
  }

  void stopContinuousAdjustment() {
    _continuousAdjustmentTimer?.cancel();
    _continuousAdjustmentTimer = null;
  }

  @override
  void dispose() {
    textController.dispose();
    _continuousAdjustmentTimer?.cancel();
    super.dispose();
  }
}

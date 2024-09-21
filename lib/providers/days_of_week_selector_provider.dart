import 'package:flutter/material.dart';

class DaysOfWeekSelectorProvider extends ChangeNotifier {
  List<String> requiredDatesOfCompletion = [];

  // Initialize with existing habit days
  DaysOfWeekSelectorProvider(List<String> initialDays) {
    requiredDatesOfCompletion = initialDays;
  }

  // Toggle day selection
  void toggleDay(String day) {
    if (requiredDatesOfCompletion.contains(day)) {
      requiredDatesOfCompletion.remove(day);
    } else {
      requiredDatesOfCompletion.add(day);
    }
    notifyListeners();
  }

  bool isDaySelected(String day) {
    return requiredDatesOfCompletion.contains(day);
  }
}

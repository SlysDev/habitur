import 'package:flutter/material.dart';
import 'package:habitur/app/app.bottomsheets.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitCardListModel extends StreamViewModel {
  final _habitService = locator<HabitService>();
  final _bottomSheetService = locator<BottomSheetService>();

  @override
  Stream<List<HabitInterface>> get stream => _habitService.habitsStream;

  List<HabitInterface> get habits => data ?? [];

  Future<void> onRefresh() async {
    await _habitService.loadHabits();
  }

  HabitInterface getHabit(int index) {
    final habit = habits[index];
    debugPrint(
        'Getting habit at index $index: ${habit.title} (ID: ${habit.id})');
    debugPrint('The habit is of type ${habit.runtimeType}');
    return habit;
  }

  Future<void> addHabit() async {
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addHabit,
      isScrollControlled: true,
    );
  }
}

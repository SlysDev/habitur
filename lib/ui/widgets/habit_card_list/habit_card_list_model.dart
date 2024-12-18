import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/bottom_sheet_type.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/services/habit_service.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitCardListModel extends StreamViewModel {
  final _habitService = locator<HabitService>();
  final _bottomSheetService = locator<BottomSheetService>();

  @override
  Stream<List<Habit>> get stream => _habitService.habitsStream;

  List<Habit> get habits => data ?? [];

  Future<void> onRefresh() async {
    await _habitService.loadHabits();
  }

  Habit getHabit(int index) {
    final habit = habits[index];
    debugPrint(
        'Getting habit at index $index: ${habit.title} (ID: ${habit.id})');
    return habit;
  }

  Future<void> addHabit() async {
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addHabit,
      isScrollControlled: true,
    );
  }
}

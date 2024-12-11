import 'package:flutter/material.dart';
import 'package:habitur/ui/bottom_sheets/add_habit/add_habit_sheet.dart';
import 'package:habitur/ui/bottom_sheets/create_shared_habit/create_shared_habit_sheet.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../constants.dart';
import '../enums/bottom_sheet_type.dart';

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.addHabit: (context, request, completer) =>
        AddHabitSheet(completer: completer, request: request),
    BottomSheetType.createSharedHabit: (context, request, completer) =>
        CreateSharedHabitSheet(completer: completer, request: request),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}

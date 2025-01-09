// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/action_selection/action_selection_sheet.dart';
import '../ui/bottom_sheets/add_habit/add_habit_sheet.dart';
import '../ui/bottom_sheets/create_shared_habit/create_shared_habit_sheet.dart';

enum BottomSheetType {
  actionSelection,
  addHabit,
  createSharedHabit,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.actionSelection: (context, request, completer) =>
        ActionSelectionSheet(request: request, completer: completer),
    BottomSheetType.addHabit: (context, request, completer) =>
        AddHabitSheet(request: request, completer: completer),
    BottomSheetType.createSharedHabit: (context, request, completer) =>
        CreateSharedHabitSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}

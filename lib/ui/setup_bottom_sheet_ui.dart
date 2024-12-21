import 'package:habitur/app/app.locator.dart';
import 'package:habitur/enums/bottom_sheet_type.dart';
import 'package:habitur/ui/bottom_sheets/action_selection/action_selection_sheet.dart';
import 'package:habitur/ui/bottom_sheets/add_habit/add_habit_sheet.dart';
import 'package:habitur/ui/bottom_sheets/create_shared_habit/create_shared_habit_sheet.dart';
import 'package:stacked_services/stacked_services.dart';

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.addHabit: (context, sheetRequest, completer) =>
        AddHabitSheet(
          request: sheetRequest,
          completer: completer,
        ),
    BottomSheetType.createSharedHabit: (context, sheetRequest, completer) =>
        CreateSharedHabitSheet(
          request: sheetRequest,
          completer: completer,
        ),
    BottomSheetType.actionSelection: (context, sheetRequest, completer) =>
        ActionSelectionSheet(completer: completer, request: sheetRequest),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}

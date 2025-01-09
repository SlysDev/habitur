import 'package:flutter/material.dart';
import 'package:habitur/app/app.bottomsheets.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ActionSelectionSheetModel extends BaseViewModel {
  Function(SheetResponse)? completer;
  final _bottomSheetService = locator<BottomSheetService>();

  Future<void> onCreateHabit() async {
    _bottomSheetService.completeSheet(SheetResponse(confirmed: true));
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.addHabit,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  Future<void> onCreateSharedHabit() async {
    _bottomSheetService.completeSheet(SheetResponse(confirmed: true));
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.createSharedHabit,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  Future<void> onShareActivity() async {
    showErrorSnackbar('This feature is not yet available');
    // TODO: Implement share activity sheet + functionality
    //   _bottomSheetService.completeSheet(SheetResponse(confirmed: true));
    // await _bottomSheetService.showCustomSheet(
    //   variant: BottomSheetType.shareActivity,
    //   isScrollControlled: true,
    //   barrierColor: Colors.black.withOpacity(0.2),
    // );
  }
}

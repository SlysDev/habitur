import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/constants.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DifficultyPopupDialogModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  double chosenDifficulty = 5.0; // Initial difficulty
  Color highlightColor = kPrimaryColor.withOpacity(0.3);

  void updateDifficulty(double newDifficulty) {
    chosenDifficulty = newDifficulty;
    rebuildUi();
  }

  void submitDialog() {
    _dialogService.completeDialog(
        DialogResponse(confirmed: true, data: chosenDifficulty));
  }
}

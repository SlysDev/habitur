// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/streak_milestone/streak_milestone_dialog.dart';

enum DialogType {
  streakMilestone,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.streakMilestone: (context, request, completer) =>
        StreakMilestoneDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

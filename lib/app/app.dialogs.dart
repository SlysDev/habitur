// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/level_up/level_up_dialog.dart';
import '../ui/dialogs/select_friends/select_friends_dialog.dart';
import '../ui/dialogs/streak_milestone/streak_milestone_dialog.dart';

enum DialogType {
  streakMilestone,
  selectFriends,
  levelUp,
}

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.streakMilestone: (context, request, completer) =>
        StreakMilestoneDialog(request: request, completer: completer),
    DialogType.selectFriends: (context, request, completer) =>
        SelectFriendsDialog(request: request, completer: completer),
    DialogType.levelUp: (context, request, completer) =>
        LevelUpDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/basic/basic_dialog.dart';
import '../ui/dialogs/difficulty_popup/difficulty_popup_dialog.dart';
import '../ui/dialogs/level_up/level_up_dialog.dart';
import '../ui/dialogs/modern/modern_dialog.dart';
import '../ui/dialogs/profile/profile_dialog.dart';
import '../ui/dialogs/select_friends/select_friends_dialog.dart';
import '../ui/dialogs/streak_milestone/streak_milestone_dialog.dart';
import '../ui/dialogs/success/success_dialog.dart';

enum DialogType {
  streakMilestone,
  selectFriends,
  levelUp,
  modern,
  profile,
  difficultyPopup,
  success,
  basic,
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
    DialogType.modern: (context, request, completer) =>
        ModernDialog(request: request, completer: completer),
    DialogType.profile: (context, request, completer) =>
        ProfileDialog(request: request, completer: completer),
    DialogType.difficultyPopup: (context, request, completer) =>
        DifficultyPopupDialog(request: request, completer: completer),
    DialogType.success: (context, request, completer) =>
        SuccessDialog(request: request, completer: completer),
    DialogType.basic: (context, request, completer) =>
        BasicDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

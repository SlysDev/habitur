import 'package:habitur/ui/dialogs/streak_milestone/streak_milestone_dialog.dart';
import 'package:habitur/ui/widgets/dialog/modern_dialog.dart';
import 'package:habitur/ui/widgets/dialog/habit_difficulty_dialog.dart';
import 'package:habitur/ui/widgets/dialog/profile_dialog/profile_dialog.dart';
import 'package:habitur/ui/widgets/dialog/success_dialog.dart';
import 'package:habitur/ui/dialogs/select_friends/select_friends_dialog.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../constants.dart';
import '../enums/dialog_type.dart';
import 'package:flutter/material.dart';

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.basic: (context, sharedRequest, completer) => Dialog(
          backgroundColor: kBackgroundColor,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sharedRequest.title ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  sharedRequest.description ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (sharedRequest.secondaryButtonTitle != null)
                      TextButton(
                        onPressed: () => completer(DialogResponse(
                          confirmed: false,
                        )),
                        child: Text(
                          sharedRequest.secondaryButtonTitle!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    TextButton(
                      onPressed: () => completer(DialogResponse(
                        confirmed: true,
                      )),
                      child: Text(
                        sharedRequest.mainButtonTitle ?? 'Ok',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
    DialogType.modern: (context, sharedRequest, completer) => ModernDialog(
          title: sharedRequest.title ?? '',
          subtitle: sharedRequest.description,
          primaryAction: ModernDialogAction(
            label: sharedRequest.mainButtonTitle ?? 'OK',
            onPressed: () => completer(DialogResponse(confirmed: true)),
          ),
          secondaryAction: sharedRequest.secondaryButtonTitle != null
              ? ModernDialogAction(
                  label: sharedRequest.secondaryButtonTitle!,
                  onPressed: () => completer(DialogResponse(confirmed: false)),
                )
              : null,
        ),
    DialogType.profile: (context, sharedRequest, completer) => ProfileDialog(
          uid: sharedRequest.data['uid'] as String,
          isFriendProfile:
              sharedRequest.data['isFriendProfile'] as bool? ?? false,
          completer: completer,
        ),
    DialogType.difficultyPopup: (context, sharedRequest, completer) =>
        HabitDifficultyDialog(completer: completer),
    DialogType.success: (context, sharedRequest, completer) => SuccessDialog(
          title: sharedRequest.title,
          description: sharedRequest.description,
          onTap: () => completer(DialogResponse(confirmed: true)),
        ),
    DialogType.selectFriends: (context, sharedRequest, completer) =>
        SelectFriendsDialog(
          request: sharedRequest,
          completer: completer,
        ),
    DialogType.streakMilestone: (context, sharedRequest, completer) =>
        StreakMilestoneDialog(request: sharedRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

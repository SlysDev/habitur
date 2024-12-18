import 'package:habitur/ui/widgets/dialog/modern_dialog.dart';
import 'package:habitur/ui/widgets/dialog/habit_difficulty_dialog.dart';
import 'package:habitur/ui/widgets/dialog/profile_dialog/profile_dialog.dart';
import 'package:habitur/ui/widgets/dialog/success_dialog.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';
import '../constants.dart';
import '../enums/dialog_type.dart';
import 'package:flutter/material.dart';

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.basic: (context, request, completer) => Dialog(
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
                  request.title ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  request.description ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (request.secondaryButtonTitle != null)
                      TextButton(
                        onPressed: () => completer(DialogResponse(
                          confirmed: false,
                        )),
                        child: Text(
                          request.secondaryButtonTitle!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    TextButton(
                      onPressed: () => completer(DialogResponse(
                        confirmed: true,
                      )),
                      child: Text(
                        request.mainButtonTitle ?? 'OK',
                        style: const TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
    DialogType.profile: (context, request, completer) => ProfileDialog(
          uid: request.data['user'].uid,
          isFriendProfile: request.data['isFriendProfile'],
          completer: completer,
        ),
    DialogType.modern: (context, request, completer) => ModernDialog(
          title: request.title ?? '',
          subtitle: request.description,
          content: request.data as Widget?,
          primaryAction: request.mainButtonTitle != null
              ? ModernDialogAction(
                  label: request.mainButtonTitle!,
                  onPressed: () => completer(DialogResponse(confirmed: true)),
                )
              : null,
          secondaryAction: request.secondaryButtonTitle != null
              ? ModernDialogAction(
                  label: request.secondaryButtonTitle!,
                  onPressed: () => completer(DialogResponse(confirmed: false)),
                )
              : null,
        ),
    DialogType.difficultyPopup: (context, request, completer) =>
        HabitDifficultyDialog(
          completer: completer,
        ),
    DialogType.success: (context, request, completer) => SuccessDialog(
          title: request.title,
          description: request.description,
          onTap: () => completer(DialogResponse(confirmed: true)),
        ),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

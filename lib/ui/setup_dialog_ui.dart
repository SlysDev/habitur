import 'package:habitur/ui/widgets/dialog/modern_dialog.dart';
import 'package:habitur/ui/widgets/profile_dialog/profile_dialog.dart';
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      onPressed: () => completer(DialogResponse(
                        confirmed: true,
                      )),
                      child: Text(request.mainButtonTitle ?? 'OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    DialogType.profile: (context, request, completer) => ProfileDialog(
          uid: request.uid,
          isFriendProfile: request.isFriendProfile ?? false,
        ),
    DialogType.modern: (context, request, completer) => ModernDialog(
          title: request.title,
          subtitle: request.subtitle,
          content: request.content,
          icon: request.icon,
          iconColor: request.iconColor,
          primaryAction: request.primaryAction,
          secondaryAction: request.secondaryAction,
          tertiaryAction: request.tertiaryAction,
          maxWidth: request.maxWidth,
        )
  };

  dialogService.registerCustomDialogBuilders(builders);
}

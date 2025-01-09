import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:stacked_services/stacked_services.dart';

class ModernDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ModernDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: ModernCard(
          padding: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (request.data?['imageUrl'] != null) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    _getDialogIcon(),
                    size: 40,
                    color: kPrimaryColor,
                  ),
                ),
                verticalSpaceMedium,
              ],
              Text(
                request.title ?? '',
                style: kHeadingTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (request.description != null) ...[
                verticalSpaceSmall,
                Text(
                  request.description!,
                  style: kMainDescription.copyWith(
                    color: kGray,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              verticalSpaceLarge,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (request.data?['secondaryButtonTitle'] != null)
                    Expanded(
                      child: AsideButton(
                        text: request.secondaryButtonTitle!,
                        onPressed: () =>
                            completer(DialogResponse(confirmed: false)),
                      ),
                    ),
                  if (request.secondaryButtonTitle != null)
                    horizontalSpaceSmall,
                  Expanded(
                    child: PrimaryButton(
                      text: request.mainButtonTitle ?? 'OK',
                      onPressed: () =>
                          completer(DialogResponse(confirmed: true)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDialogIcon() {
    if (request.data != null && request.data is IconData) {
      return request.data as IconData;
    }

    // Default icons based on common dialog types
    if (request.title?.toLowerCase().contains('error') ?? false) {
      return Icons.error_outline_rounded;
    }
    if (request.title?.toLowerCase().contains('success') ?? false) {
      return Icons.check_circle_outline_rounded;
    }
    if (request.title?.toLowerCase().contains('warning') ?? false) {
      return Icons.warning_amber_rounded;
    }

    // Default info icon
    return Icons.info_outline_rounded;
  }
}

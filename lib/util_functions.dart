import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/ui/widgets/error_tile.dart';
import 'package:habitur/ui/widgets/status_card/status_card.dart';
import 'package:habitur/ui/widgets/status_card/status_card_model.dart';
import 'package:stacked_services/stacked_services.dart';

String generateUniqueId() {
  return Random()
      .nextInt(1000000000)
      .toString(); // generate a random number between 0 and 1000000000
}

// error handling
showDebugErrorSnackbar(BuildContext context, e, s) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 5),
      backgroundColor: kOrangeAccent,
      content: Text(
          'Error--Take a screenshot and send to our team: \n \n ${e.toString()}, $s'),
    ),
  );
}

showErrorDialog(BuildContext context, String errorText,
    {Duration duration = const Duration(seconds: 1)}) {
  showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      Future.delayed(duration, () {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      });

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AlertDialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: kLightRedAccent.withOpacity(0.8),
            content: ErrorTile(
              errorText: errorText,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 60),
        ],
      );
    },
  );
}

showSuccessDialog(BuildContext context, String successText,
    {Duration duration = const Duration(seconds: 1)}) {
  showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      Future.delayed(duration, () {
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
      });

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AlertDialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: kLightGreenAccent.withOpacity(0.8),
            content: ErrorTile(
              errorText: successText,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 60),
        ],
      );
    },
  );
}

// Status card overlay
OverlayEntry? _currentOverlay;

void _removeCurrentOverlay() {
  _currentOverlay?.remove();
  _currentOverlay = null;
}

void _showStatusCard(BuildContext context, String message, StatusType status) {
  _removeCurrentOverlay();

  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: StatusCard(
        message: message,
        status: status,
        onDismiss: _removeCurrentOverlay,
      ),
    ),
  );
  _currentOverlay = overlay;

  Overlay.of(context).insert(overlay);
}

// Convenience functions for showing success/error status cards
void showSuccess(BuildContext context, String message) {
  _showStatusCard(context, message, StatusType.success);
}

void showError(BuildContext context, String message) {
  _showStatusCard(context, message, StatusType.error);
}

Future<T> showStatusOverlay<T>(
  BuildContext context,
  String loadingMessage,
  Future<T> Function() operation, {
  String? successMessage,
}) async {
  _showStatusCard(context, loadingMessage, StatusType.loading);

  try {
    final result = await operation();
    _removeCurrentOverlay();
    if (context.mounted) {
      _showStatusCard(
        context,
        successMessage ?? 'Operation completed successfully',
        StatusType.success,
      );
    }
    return result;
  } catch (e) {
    _removeCurrentOverlay();
    if (context.mounted) {
      _showStatusCard(context, e.toString(), StatusType.error);
    }
    rethrow;
  }
}

// UI transitions

Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

DateTime simplifyDateIntoDays(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDay(DateTime? date1, DateTime? date2) {
  if (date1 == null || date2 == null) return false;
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String getTimeSlot(DateTime time) {
  int hour = time.hour;
  if (hour >= 5 && hour < 11) return 'morning';
  if (hour >= 11 && hour < 17) return 'afternoon';
  if (hour >= 17 && hour < 23) return 'evening';
  return 'night';
}

bool stringToBool(String value) {
  return value.toLowerCase() == 'true';
}

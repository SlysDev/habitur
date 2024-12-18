import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/enums/dialog_type.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:habitur/ui/widgets/error_tile.dart';
import 'package:habitur/ui/widgets/status_card/status_card.dart';
import 'package:habitur/ui/widgets/status_card/status_card_model.dart';
import 'package:stacked_services/stacked_services.dart';

String generateUniqueId() {
  return Random()
      .nextInt(1000000)
      .toString(); // generate a random number between 0 and 1000000000
}

void showErrorSnackbar(String message) {
  final _snackbarService = locator<SnackbarService>();
  if (_snackbarService.isSnackbarOpen) {
    _snackbarService.closeSnackbar();
  }
  _snackbarService.showCustomSnackBar(
      message: message,
      variant: SnackbarType.error,
      duration: Duration(milliseconds: 1400));
}

void showSuccessSnackbar(String message) {
  final _snackbarService = locator<SnackbarService>();
  if (_snackbarService.isSnackbarOpen) {
    _snackbarService.closeSnackbar();
  }
  _snackbarService.showCustomSnackBar(
      message: message,
      variant: SnackbarType.success,
      duration: Duration(milliseconds: 1000));
}

// error handling
void showDebugErrorSnackbar(BuildContext context, e, s) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: 5),
      backgroundColor: kOrangeAccent,
      content: Text(
          'Error--Take a screenshot and send to our team: \n \n ${e.toString()}, $s'),
    ),
  );
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

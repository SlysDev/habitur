import 'package:flutter/material.dart';
import 'package:habitur/app/app.locator.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/enums/snackbar_type.dart';
import 'package:stacked_services/stacked_services.dart';

void setupSnackbarUi() {
  final _snackbarService = locator<SnackbarService>();

  _snackbarService.registerCustomSnackbarConfig(
      variant: SnackbarType.error, config: _errorSnackbarConfig());
  _snackbarService.registerCustomSnackbarConfig(
      variant: SnackbarType.success, config: _successSnackbarConfig());
}

SnackbarConfig _errorSnackbarConfig() {
  return _defaultSnackbarConfig(
      color: kLightRedAccent, icon: Icon(Icons.error));
}

SnackbarConfig _successSnackbarConfig() {
  return _defaultSnackbarConfig(
      color: kLightGreenAccent, icon: Icon(Icons.check));
}

SnackbarConfig _defaultSnackbarConfig(
    {Color color = Colors.white,
    double barBlur = 3.0,
    double verticalHeight = 120,
    Color textColor = Colors.white,
    Icon icon = const Icon(Icons.info)}) {
  return SnackbarConfig(
    backgroundColor: color.withOpacity(0.3),
    textColor: textColor,
    borderRadius: 12.0,
    barBlur: barBlur,
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: verticalHeight),
    padding: const EdgeInsets.all(16.0),
    borderColor: color.withOpacity(0.6),
    borderWidth: 1.0,
    icon: icon,
    snackPosition: SnackPosition.BOTTOM,
    animationDuration: const Duration(milliseconds: 1000),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeInOutCubicEmphasized,
    reverseAnimationCurve: Curves.easeInOutCubicEmphasized,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 25,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

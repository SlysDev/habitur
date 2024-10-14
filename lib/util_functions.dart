import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

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

import 'package:flutter/material.dart';
import 'package:habitur/components/error_tile.dart';
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

showErrorDialog(BuildContext context, String errorText) {
  showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AlertDialog(
            alignment: Alignment.bottomCenter,
            backgroundColor: kRed.withOpacity(0.8),
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
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context);
  });
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

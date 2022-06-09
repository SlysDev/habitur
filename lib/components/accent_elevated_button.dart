import 'package:flutter/material.dart';
import '../constants.dart';

class AccentElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  late ButtonStyle style;
  AccentElevatedButton({required this.onPressed, required this.child});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(kTurqoiseAccent),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

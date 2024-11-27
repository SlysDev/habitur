import 'package:flutter/material.dart';
import '../constants.dart';

class InactiveElevatedButton extends StatelessWidget {
  final Widget child;
  late ButtonStyle style;
  InactiveElevatedButton({required this.child});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      child: child,
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.5)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

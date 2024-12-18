import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({required this.text, required this.onPressed, super.key});
  String text;
  void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: kMainDescription),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class AsideButton extends StatelessWidget {
  String text;
  void Function() onPressed;
  AsideButton({required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        text,
        style: kMainDescription.copyWith(
          color: kGray,
        ),
      ),
      onTap: onPressed,
    );
  }
}

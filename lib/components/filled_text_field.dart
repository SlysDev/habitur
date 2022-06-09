import 'package:flutter/material.dart';
import '../constants.dart';

class FilledTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final String hintText;
  final bool obscureText;
  FilledTextField(
      {required this.onChanged,
      required this.hintText,
      this.obscureText = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: TextField(
        obscureText: obscureText,
        cursorColor: Colors.white,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
        decoration:
            kFilledTextFieldInputDecoration.copyWith(hintText: hintText),
      ),
    );
  }
}

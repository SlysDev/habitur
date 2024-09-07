import 'package:flutter/material.dart';
import '../constants.dart';

class FilledTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final String hintText;
  final bool obscureText;
  final String initialValue;
  final bool enabled;
  dynamic controller;
  FilledTextField(
      {required this.onChanged,
      required this.hintText,
      this.enabled = true,
      this.initialValue = '',
      this.controller,
      this.obscureText = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      obscureText: obscureText,
      cursorColor: Colors.white,
      onChanged: onChanged,
      controller: controller ??
          (initialValue != null
              ? TextEditingController(text: initialValue)
              : TextEditingController()),
      textAlign: TextAlign.center,
      style: TextStyle(
          color: enabled ? Colors.white : Colors.red.withOpacity(0.7)),
      decoration: kFilledTextFieldInputDecoration.copyWith(
        hintText: hintText,
        fillColor: enabled ? kFadedBlue : Colors.red.withOpacity(0.1),
      ),
    );
  }
}

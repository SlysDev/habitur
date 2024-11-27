import 'package:flutter/material.dart';
import '../constants.dart';

class FilledTextField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String? hintText;
  final bool obscureText;
  final String initialValue;
  final bool enabled;
  final IconData? prefixIcon;
  final TextAlign textAlign;
  final TextEditingController? controller;

  const FilledTextField({
    Key? key,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.initialValue = '',
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      obscureText: obscureText,
      cursorColor: Colors.white,
      onChanged: onChanged,
      cursorOpacityAnimates: true,
      controller: controller ?? TextEditingController(text: initialValue),
      textAlign: textAlign,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.red.withOpacity(0.7),
      ),
      decoration: kFilledTextFieldInputDecoration.copyWith(
        hintText: hintText,
        fillColor: enabled ? kFadedBlue : Colors.red.withOpacity(0.1),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: enabled ? Colors.white70 : Colors.red.withOpacity(0.7),
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 8 : 16,
          vertical: 16,
        ),
      ),
    );
  }
}

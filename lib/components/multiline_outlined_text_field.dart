import 'package:flutter/material.dart';
import '../constants.dart'; // Ensure this has your constants like kFadedBlue

class MultilineTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final String hintText;
  final String initialValue;
  final bool enabled;
  final TextEditingController? controller;

  MultilineTextField({
    required this.onChanged,
    required this.hintText,
    this.enabled = true,
    this.initialValue = '',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      maxLines: null, // Allows for multiline input
      minLines: 2,
      keyboardType: TextInputType.multiline,
      cursorColor: Colors.white,
      onChanged: onChanged,
      controller: controller ??
          (initialValue.isNotEmpty
              ? TextEditingController(text: initialValue)
              : TextEditingController()),
      style: TextStyle(
        color: enabled ? Colors.white : Colors.red.withOpacity(0.7),
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        fillColor: kFadedBlue, // Set the background to kFadedBlue
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          borderSide: BorderSide.none, // No visible border
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 10), // Space around text
      ),
    );
  }
}

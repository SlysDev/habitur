import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitur/constants.dart';

class PrimaryTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const PrimaryTextField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.prefix,
    this.suffix,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      style: TextStyle(
        color: enabled ? Colors.white : kGray,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? kGray : kGray.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: kGray.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: kLightRedAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        prefixIcon: prefix != null
            ? IconTheme(
                data: IconThemeData(
                  color: enabled ? kPrimaryColor : kGray,
                  size: 20,
                ),
                child: prefix!,
              )
            : null,
        suffixIcon: suffix != null
            ? IconTheme(
                data: IconThemeData(
                  color: enabled ? kPrimaryColor : kGray,
                  size: 20,
                ),
                child: suffix!,
              )
            : null,
        filled: true,
        fillColor:
            enabled ? kFadedBlue.withOpacity(0.5) : kDarkGray.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: kFadedBlue,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: kFadedBlue,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: kPrimaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: kLightRedAccent,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: kLightRedAccent,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: kDarkGray.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}

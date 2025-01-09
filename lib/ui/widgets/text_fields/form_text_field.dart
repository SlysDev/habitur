import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/text_fields/primary_text_field.dart';

class FormTextField extends PrimaryTextField {
  FormTextField({
    super.key,
    required String label,
    String? hint,
    super.controller,
    super.focusNode,
    super.keyboardType,
    super.textInputAction,
    super.obscureText,
    super.onChanged,
    super.onSubmitted,
    super.validator,
    super.maxLines,
    super.maxLength,
    super.inputFormatters,
    super.textCapitalization,
    super.prefix,
    super.suffix,
  }) : super(
          label: label,
          hint: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        );

  // Factory constructors for common form fields
  factory FormTextField.email({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return FormTextField(
      key: key,
      label: 'Email',
      hint: 'Enter your email',
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
      prefix: const Icon(Icons.email_outlined),
    );
  }

  factory FormTextField.password({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return FormTextField(
      key: key,
      label: 'Password',
      hint: 'Enter your password',
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      obscureText: !showPassword,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
      prefix: const Icon(Icons.lock_outline),
      suffix: IconButton(
        icon: Icon(
          showPassword ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: onTogglePassword,
      ),
    );
  }

  factory FormTextField.username({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return FormTextField(
      key: key,
      label: 'Username',
      hint: 'Enter your username',
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
      prefix: const Icon(Icons.person_outline),
    );
  }
}

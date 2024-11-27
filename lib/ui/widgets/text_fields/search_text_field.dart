import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/text_fields/primary_text_field.dart';

class SearchTextField extends PrimaryTextField {
  SearchTextField({
    super.key,
    super.controller,
    super.focusNode,
    super.onChanged,
    super.onSubmitted,
    String? hint,
    VoidCallback? onClear,
  }) : super(
          hint: hint ?? 'Search...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          prefix: const Icon(Icons.search),
          suffix: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        );
}

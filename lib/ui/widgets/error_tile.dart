import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/modern_card.dart';

class ErrorTile extends StatelessWidget {
  const ErrorTile({super.key, this.errorText, this.color});

  final String? errorText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 16),
          Text(errorText ?? 'Something went wrong'),
        ],
      ),
    );
  }
}

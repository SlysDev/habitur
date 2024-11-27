import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ModernDialog extends StatelessWidget {
  const ModernDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.icon,
    this.iconColor,
    this.primaryAction,
    this.secondaryAction,
    this.tertiaryAction,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 8, 24, 24),
    this.maxWidth = 400,
  });

  final String title;
  final String? subtitle;
  final Widget? content;
  final IconData? icon;
  final Color? iconColor;
  final ModernDialogAction? primaryAction;
  final ModernDialogAction? secondaryAction;
  final ModernDialogAction? tertiaryAction;
  final EdgeInsets contentPadding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: kFadedBlue.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            if (content != null)
              Padding(
                padding: contentPadding,
                child: content,
              ),
            if (_hasActions) _buildActions(),
          ],
        ),
      ),
    );
  }

  bool get _hasActions =>
      primaryAction != null ||
      secondaryAction != null ||
      tertiaryAction != null;

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? kPrimaryColor,
              size: 28,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: kGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (tertiaryAction != null) ...[
            _ActionButton(
              action: tertiaryAction!,
              type: ActionType.tertiary,
            ),
            const SizedBox(width: 8),
          ],
          if (secondaryAction != null) ...[
            _ActionButton(
              action: secondaryAction!,
              type: ActionType.secondary,
            ),
            const SizedBox(width: 8),
          ],
          if (primaryAction != null)
            _ActionButton(
              action: primaryAction!,
              type: ActionType.primary,
            ),
        ],
      ),
    );
  }
}

class ModernDialogAction {
  const ModernDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
}

enum ActionType { primary, secondary, tertiary }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.type,
  });

  final ModernDialogAction action;
  final ActionType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ActionType.primary:
        return ElevatedButton(
          onPressed: action.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                action.isDestructive ? kLightRedAccent : kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case ActionType.secondary:
        return OutlinedButton(
          onPressed: action.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor:
                action.isDestructive ? kLightRedAccent : kPrimaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            side: BorderSide(
              color: action.isDestructive
                  ? kLightRedAccent.withOpacity(0.5)
                  : kPrimaryColor.withOpacity(0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case ActionType.tertiary:
        return TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: action.isDestructive ? kLightRedAccent : kGray,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            action.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}

// Helper method to show the dialog easily
Future<T?> showModernDialog<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  Widget? content,
  IconData? icon,
  Color? iconColor,
  ModernDialogAction? primaryAction,
  ModernDialogAction? secondaryAction,
  ModernDialogAction? tertiaryAction,
  bool barrierDismissible = true,
  EdgeInsets? contentPadding,
  double? maxWidth,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => ModernDialog(
      title: title,
      subtitle: subtitle,
      content: content,
      icon: icon,
      iconColor: iconColor,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      tertiaryAction: tertiaryAction,
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(24, 8, 24, 24),
      maxWidth: maxWidth ?? 400,
    ),
  );
}

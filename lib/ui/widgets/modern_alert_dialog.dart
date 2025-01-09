import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class ModernAlertDialog extends StatelessWidget {
  const ModernAlertDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.content = const SizedBox(),
    this.actions = const [],
    this.icon,
    this.maxWidth = 400,
  });

  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kFadedBlue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kFadedBlue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: kGray,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (content != const SizedBox())
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: content,
                ),
              ),
            if (actions.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: kFadedBlue.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      actions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ModernDialogButton extends StatefulWidget {
  const ModernDialogButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isPrimary = false,
    this.isDestructive = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;
  final bool isDestructive;

  @override
  State<ModernDialogButton> createState() => _ModernDialogButtonState();
}

class _ModernDialogButtonState extends State<ModernDialogButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!widget.isPrimary) return Colors.transparent;

    if (widget.isDestructive) {
      return _isHovered ? kLightRedAccent : kLightRedAccent.withOpacity(0.1);
    }

    return _isHovered ? kPrimaryColor : kPrimaryColor.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (widget.isDestructive) {
      return kLightRedAccent.withOpacity(_isHovered ? 1 : 0.3);
    }

    if (widget.isPrimary) {
      return kPrimaryColor.withOpacity(_isHovered ? 1 : 0.3);
    }

    return kFadedBlue.withOpacity(_isHovered ? 0.5 : 0.3);
  }

  Color _getTextColor() {
    if (widget.isDestructive) {
      return kLightRedAccent;
    }

    if (widget.isPrimary) {
      return _isHovered ? Colors.white : kPrimaryColor;
    }

    return _isHovered ? kPrimaryColor : kGray;
  }
}

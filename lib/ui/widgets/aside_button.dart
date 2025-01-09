import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class AsideButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const AsideButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isActive = false,
    this.icon,
    this.padding,
  }) : super(key: key);

  @override
  State<AsideButton> createState() => _AsideButtonState();
}

class _AsideButtonState extends State<AsideButton> {
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
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: _getTextColor(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 14,
                  fontWeight: _isHovered || widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isActive) {
      return kFadedBlue;
    }
    if (_isHovered) {
      return kFadedBlue.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  Color _getBorderColor() {
    if (widget.isActive) {
      return kPrimaryColor;
    }
    if (_isHovered) {
      return kPrimaryColor.withOpacity(0.5);
    }
    return kFadedBlue;
  }

  Color _getTextColor() {
    if (widget.isActive || _isHovered) {
      return kPrimaryColor;
    }
    return kGray;
  }
}

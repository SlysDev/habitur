import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? borderRadius;
  final EdgeInsets? padding;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius = 12,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = backgroundColor ?? kPrimaryColor;
    final effectiveTextColor = textColor ?? Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDisabled ? kDarkGray : effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: !isDisabled
            ? [
                BoxShadow(
                  color: effectiveColor.withOpacity(0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !isDisabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveTextColor.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: effectiveTextColor.withOpacity(0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

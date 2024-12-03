import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class SuccessDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback onTap;

  const SuccessDialog({
    super.key,
    this.title,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible fullscreen button to handle outside taps
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GestureDetector(
            // Prevent taps on dialog from propagating to background
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kBackgroundColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: kPrimaryColor.withOpacity(0.2),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: kPrimaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title ?? 'Success!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Tap anywhere to dismiss',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

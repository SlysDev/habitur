import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.borderRadius = 0,
  });

  final Widget child;
  final bool isLoading;
  final double borderRadius;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,

        // Loading overlay
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !widget.isLoading,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  // Blurred background with animated blur
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: widget.isLoading ? 3.0 : 0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                      child: AnimatedOpacity(
                        opacity: widget.isLoading ? 1.0 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius:
                                BorderRadius.circular(widget.borderRadius),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Loader in the center
                  AnimatedOpacity(
                    opacity: widget.isLoading ? 1.0 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 6.0,
                      ),
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

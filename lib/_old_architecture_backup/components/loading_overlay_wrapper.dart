import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:provider/provider.dart';

class LoadingOverlayWrapper extends StatelessWidget {
  final Widget child;

  const LoadingOverlayWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<LoadingStateProvider>(context).isLoading;
    return Stack(
      children: [
        // Main content
        child,

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Stack(
              children: [
                // Blurred background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.4), // Optional dark tint
                  ),
                ),
                // Loader in the center
                Center(
                  child: AnimatedOpacity(
                    opacity: isLoading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
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
      ],
    );
  }
}

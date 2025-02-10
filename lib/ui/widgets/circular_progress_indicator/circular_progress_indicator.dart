import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class HabiturCircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final Duration animationDuration;
  final Curve animationCurve;

  const HabiturCircularProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: animationDuration,
        curve: animationCurve,
        builder: (context, value, _) {
          return Stack(
            children: [
              // Background circle
              CustomPaint(
                size: Size(size, size),
                painter: CircleProgressPainter(
                  progress: 1.0,
                  progressColor: backgroundColor?.withOpacity(0.2) ??
                      Colors.white.withOpacity(0.1),
                  strokeWidth: strokeWidth,
                  isBackground: true,
                ),
              ),
              // Progress circle
              CustomPaint(
                size: Size(size, size),
                painter: CircleProgressPainter(
                  progress: value,
                  progressColor: progressColor ?? kPrimaryColor,
                  strokeWidth: strokeWidth,
                  isBackground: false,
                ),
              ),
              if (child != null)
                Center(
                  child: child,
                ),
            ],
          );
        },
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final bool isBackground;

  CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Create the paint for the progress
    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (!isBackground) {
      // Add subtle gradient and shadow for the progress
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          progressColor,
          progressColor.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    // Draw the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      progressColor != oldDelegate.progressColor ||
      strokeWidth != oldDelegate.strokeWidth;
}

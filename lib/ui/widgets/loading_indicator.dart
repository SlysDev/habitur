import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.backgroundColor,
  });

  final double size;
  final double strokeWidth;
  final Color? backgroundColor;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _LoadingPainter(
                  strokeWidth: widget.strokeWidth,
                  progress: _rotationAnimation.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  _LoadingPainter({
    required this.strokeWidth,
    required this.progress,
  });

  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = kFadedBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * 3.14159,
      false,
      backgroundPaint,
    );

    // Draw primary arc
    final primaryPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          kPrimaryColor,
          kLightPrimaryColor,
          kDarkPrimaryColor,
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: 0,
        endAngle: 2 * 3.14159,
        transform: GradientRotation(progress * 2 * 3.14159),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5 * 3.14159,
      3.14159,
      false,
      primaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

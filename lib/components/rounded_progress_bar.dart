import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RoundedProgressBar extends StatelessWidget {
  const RoundedProgressBar({
    Key? key,
    required this.progress,
    this.color = Colors.white,
  }) : super(key: key);

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      percent: progress,
      barRadius: const Radius.circular(30),
      lineHeight: 12.0,
      animation: true,
      animationDuration: 600,
      curve: Curves.ease,
      animateFromLastPercent: true,
      progressColor: color,
      backgroundColor: color.withOpacity(0.2),
    );
  }
}

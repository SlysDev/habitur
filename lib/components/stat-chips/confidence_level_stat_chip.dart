import 'package:flutter/material.dart';
import 'package:habitur/components/stat-chips/stat_chip.dart';
import 'package:habitur/constants.dart';

class ConfidenceLevelStatChip extends StatelessWidget {
  final double confidenceLevel;
  const ConfidenceLevelStatChip({super.key, required this.confidenceLevel});

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.sentiment_satisfied_rounded,
      label: '$confidenceLevel',
      color: kLightGreenAccent,
    );
  }
}

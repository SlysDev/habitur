import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';

class StreakStatChip extends StatelessWidget {
  final int streak;
  const StreakStatChip({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.local_fire_department_rounded,
      label: '$streak',
      color: kOrangeAccent,
    );
  }
}

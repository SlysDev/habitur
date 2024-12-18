import 'package:flutter/material.dart';
import 'package:habitur/components/stat-chips/stat_chip.dart';
import 'package:habitur/constants.dart';

class DifficultyRatingStatChip extends StatelessWidget {
  final double difficultyRating;
  const DifficultyRatingStatChip({super.key, required this.difficultyRating});

  @override
  Widget build(BuildContext context) {
    return StatChip(
      icon: Icons.warning,
      label: '$difficultyRating',
      color: kLightRedAccent,
    );
  }
}

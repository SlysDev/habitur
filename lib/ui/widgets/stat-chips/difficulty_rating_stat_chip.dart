import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';

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

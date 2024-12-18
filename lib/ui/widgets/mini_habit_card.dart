import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:habitur/ui/widgets/stat-chips/confidence_level_stat_chip.dart';
import 'package:habitur/ui/widgets/stat-chips/difficulty_rating_stat_chip.dart';
import 'package:habitur/ui/widgets/stat-chips/streak_stat_chip.dart';

class MiniHabitCard extends StatelessWidget {
  const MiniHabitCard({Key? key, required this.habit}) : super(key: key);

  final HabitInterface habit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 4,
        color: kFadedBlue.withOpacity(habit.isCompleted ? 0.3 : 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: kPrimaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StreakStatChip(streak: habit.streak),
                  const SizedBox(width: 12),
                  ConfidenceLevelStatChip(
                      confidenceLevel: double.parse(
                          habit.confidenceLevel.toStringAsFixed(2))),
                  const SizedBox(width: 12),
                  DifficultyRatingStatChip(
                      difficultyRating: habit.stats.length > 0
                          ? double.parse(habit.stats.last.difficultyRating
                              .toStringAsFixed(2))
                          : 0.0),
                ],
              ),
              const SizedBox(height: 12),
              RoundedProgressBar(
                progress: habit.currentProgress / habit.targetGoal,
                color: kPrimaryColor,
                lineHeight: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

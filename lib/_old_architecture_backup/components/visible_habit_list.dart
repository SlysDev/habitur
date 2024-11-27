import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/modules/auth_service.dart';
import 'package:habitur/components/stat-chips/confidence_level_stat_chip.dart';
import 'package:habitur/components/stat-chips/difficulty_rating_stat_chip.dart';
import 'package:habitur/components/streak_stat_chip.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/providers/database.dart';

class VisibleHabitList extends StatelessWidget {
  final String userId;
  final bool isFriendProfile;
  final SharingScope? habitsScope;
  final List<Habit>? habits;

  const VisibleHabitList({
    Key? key,
    required this.userId,
    this.isFriendProfile = false,
    this.habitsScope,
    this.habits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If habits are provided directly, show them
    if (habits != null) {
      return _buildHabitList(habits!);
    }

    // Check if user has chosen to share habits
    bool userHasChosenToShareHabits = habitsScope == SharingScope.everyone ||
        (habitsScope == SharingScope.friends && isFriendProfile);

    if (!userHasChosenToShareHabits) {
      return const Center(
        child: Text(
          'No habits shared yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    // If viewing own profile or habits are shared, load them
    if (userId == AuthService().currentUser!.uid ||
        userHasChosenToShareHabits) {
      return FutureBuilder<List<Habit>>(
        future: Database().habitDatabase.loadHabits(context, userID: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading habits',
                style: TextStyle(color: kGray),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No habits yet',
                style: TextStyle(color: kGray),
              ),
            );
          }

          return _buildHabitList(snapshot.data!);
        },
      );
    }

    return const Center(
      child: Text(
        'No habits shared yet',
        style: TextStyle(color: kGray),
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits) {
    final List<Habit> visibleHabits =
        habits.where((habit) => habit.isVisible ?? false).toList();

    if (visibleHabits.isEmpty) {
      return const Center(
        child: Text(
          'No habits shared yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: visibleHabits
          .map((habit) => [
                _MiniHabitCard(habit: habit),
                const SizedBox(height: 12),
              ])
          .expand((x) => x)
          .toList()
        ..removeLast(), // Remove the last spacer
    );
  }
}

class _MiniHabitCard extends StatelessWidget {
  const _MiniHabitCard({Key? key, required this.habit}) : super(key: key);

  final Habit habit;

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

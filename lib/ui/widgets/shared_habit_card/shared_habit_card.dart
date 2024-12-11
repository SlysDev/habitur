import 'package:flutter/material.dart';
import 'package:habitur/models/participant_data.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';

class SharedHabitCard extends StatelessWidget {
  final SharedHabit sharedHabit;
  final VoidCallback onTap;

  const SharedHabitCard({
    required this.sharedHabit,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participants = sharedHabit.participantData;
    final displayedParticipants = participants.take(3).toList();
    final extraParticipants =
        participants.length > 3 ? participants.length - 3 : 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: kcFadedBlue,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sharedHabit.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kcPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...displayedParticipants.map((participant) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: UserAvatar(
                          username: participant.user.username,
                          size: 32,
                        ),
                      )),
                  if (extraParticipants > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kcAccentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$extraParticipants',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kcAccentColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: kcAccentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Group Streak: ${_calculateGroupStreak()} days',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kcLightPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateGroupStreak() {
    // Calculate the minimum streak among all active participants
    if (sharedHabit.participantData.isEmpty) return 0;

    return sharedHabit.participantData
        .map((participant) => _getParticipantStreak(participant))
        .reduce((min, current) => current < min ? current : min);
  }

  int _getParticipantStreak(ParticipantData participant) {
    final now = DateTime.now();
    final daysSinceLastSeen = now.difference(participant.lastSeen).inDays;

    // If participant hasn't been seen in more than a day, their streak is 0
    if (daysSinceLastSeen > 1) return 0;

    // Return their completion count as their streak
    return participant.fullCompletionCount;
  }
}

import 'package:flutter/material.dart';

class TargetGoalSelector extends StatelessWidget {
  const TargetGoalSelector({
    super.key,
    required this.targetGoal,
    required this.resetPeriodNoun,
    required this.onTargetGoalChanged,
  });

  final int targetGoal;
  final String resetPeriodNoun;
  final ValueChanged<int> onTargetGoalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Target',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.white70),
              onPressed: () => onTargetGoalChanged(targetGoal - 1),
            ),
            Expanded(
              child: Text(
                '$targetGoal time${targetGoal == 1 ? '' : 's'} per ${resetPeriodNoun}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.white70),
              onPressed: () => onTargetGoalChanged(targetGoal + 1),
            ),
          ],
        ),
      ],
    );
  }
}

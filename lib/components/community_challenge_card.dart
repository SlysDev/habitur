import 'package:flutter/material.dart';
import 'package:habitur/components/rounded_progress_bar.dart';
import 'package:habitur/constants.dart';

class CommunityChallengeCard extends StatelessWidget {
  String title;
  void Function() onTap;
  void Function() onLongPress;
  Color color;
  double progress;
  bool completed;
  void Function(BuildContext) onDismissed;
  void Function(BuildContext) onEdit;
  CommunityChallengeCard({
    super.key,
    required this.title,
    required this.progress,
    required this.onTap,
    required this.onLongPress,
    this.color = kFadedBlue,
    required this.completed,
    required this.onDismissed,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: !completed ? color : color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Column(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.transparent,
                  strokeWidth: 5,
                  semanticsLabel: 'progress',
                  semanticsValue: 'progress',
                  strokeCap: StrokeCap.round,
                ),
                const SizedBox(height: 10),
                // total completions display
              ],
            ),
            Column(
              children: [
                Text(
                  title,
                  style: kHeadingTextStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

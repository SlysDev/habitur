import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:stacked_services/stacked_services.dart';

class HabitDifficultyDialog extends StatefulWidget {
  const HabitDifficultyDialog({
    super.key,
    required this.completer,
  });

  final Function(DialogResponse) completer;

  @override
  State<HabitDifficultyDialog> createState() => _HabitDifficultyDialogState();
}

class _HabitDifficultyDialogState extends State<HabitDifficultyDialog> {
  double chosenDifficulty = 5.0; // Initial difficulty
  Color highlightColor = kPrimaryColor.withOpacity(0.3);

  void updateDifficulty(double newDifficulty) {
    setState(() {
      chosenDifficulty = newDifficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Dialog(
        backgroundColor: kBackgroundColor,
        child: Container(
          alignment: Alignment.center,
          height: 325,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'How difficult was this habit to complete?',
                style: kHeadingTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DifficultyButton(
                    emoji: '🤯',
                    difficulty: 10.0,
                    chosenDifficulty: chosenDifficulty,
                    highlightColor: highlightColor,
                    onTap: updateDifficulty,
                  ),
                  const SizedBox(width: 10),
                  _DifficultyButton(
                    emoji: '😕',
                    difficulty: 6.6,
                    chosenDifficulty: chosenDifficulty,
                    highlightColor: highlightColor,
                    onTap: updateDifficulty,
                  ),
                  const SizedBox(width: 10),
                  _DifficultyButton(
                    emoji: '🙂',
                    difficulty: 3.3,
                    chosenDifficulty: chosenDifficulty,
                    highlightColor: highlightColor,
                    onTap: updateDifficulty,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DifficultyButton(
                    emoji: '😌',
                    difficulty: 0.0,
                    chosenDifficulty: chosenDifficulty,
                    highlightColor: highlightColor,
                    onTap: updateDifficulty,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => widget.completer(
                  DialogResponse(
                    confirmed: true,
                    data: chosenDifficulty,
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.emoji,
    required this.difficulty,
    required this.chosenDifficulty,
    required this.highlightColor,
    required this.onTap,
  });

  final String emoji;
  final double difficulty;
  final double chosenDifficulty;
  final Color highlightColor;
  final Function(double) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(difficulty),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Text(emoji, style: kHeadingTextStyle),
        decoration: BoxDecoration(
          color: chosenDifficulty == difficulty
              ? highlightColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

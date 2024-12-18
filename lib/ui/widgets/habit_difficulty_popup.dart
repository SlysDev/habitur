import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/primary_button.dart';

class HabitDifficultyPopup extends StatefulWidget {
  const HabitDifficultyPopup({
    super.key,
    required this.onDifficultySelected,
  });

  final Function(double) onDifficultySelected;

  @override
  State<HabitDifficultyPopup> createState() => _HabitDifficultyPopupState();
}

class _HabitDifficultyPopupState extends State<HabitDifficultyPopup> {
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
      child: AlertDialog(
        surfaceTintColor: Colors.black,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Container(
          alignment: Alignment.center,
          height: 400,
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('How difficult was this habit to complete?',
                  style: kHeadingTextStyle, textAlign: TextAlign.center),
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
              PrimaryButton(
                onPressed: () => widget.onDifficultySelected(chosenDifficulty),
                text: 'Done',
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

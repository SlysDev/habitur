import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/modules/habit_stats_handler.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:provider/provider.dart';

class HabitDifficultyPopup extends StatefulWidget {
  HabitDifficultyPopup(
      {super.key,
      required this.habitIndex,
      required this.onDifficultySelected});
  int habitIndex;
  Function(double) onDifficultySelected;

  @override
  State<HabitDifficultyPopup> createState() => _HabitDifficultyPopupState();
}

class _HabitDifficultyPopupState extends State<HabitDifficultyPopup> {
  double chosenDifficulty = 5.0; // Initial difficulty

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
        backgroundColor: kBackgroundColor,
        content: Container(
          height: 200,
          width: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => updateDifficulty(10.0),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('🤯', style: kHeadingTextStyle),
                      decoration: BoxDecoration(
                        color: chosenDifficulty == 10.0
                            ? kAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => updateDifficulty(6.6),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('😕', style: kHeadingTextStyle),
                      decoration: BoxDecoration(
                        color: chosenDifficulty == 6.6
                            ? kAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => updateDifficulty(3.3),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('🙂', style: kHeadingTextStyle),
                      decoration: BoxDecoration(
                        color: chosenDifficulty == 3.3
                            ? kAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => updateDifficulty(0),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Text('😎', style: kHeadingTextStyle),
                      decoration: BoxDecoration(
                        color: chosenDifficulty == 0
                            ? kAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
              AccentElevatedButton(
                onPressed: () {
                  widget.onDifficultySelected(chosenDifficulty);
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

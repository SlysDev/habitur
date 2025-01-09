import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'difficulty_popup_dialog_model.dart';

class DifficultyPopupDialog extends StackedView<DifficultyPopupDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const DifficultyPopupDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DifficultyPopupDialogModel viewModel,
    Widget? child,
  ) {
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
                    chosenDifficulty: viewModel.chosenDifficulty,
                    highlightColor: viewModel.highlightColor,
                    onTap: viewModel.updateDifficulty,
                  ),
                  const SizedBox(width: 10),
                  _DifficultyButton(
                    emoji: '😕',
                    difficulty: 6.6,
                    chosenDifficulty: viewModel.chosenDifficulty,
                    highlightColor: viewModel.highlightColor,
                    onTap: viewModel.updateDifficulty,
                  ),
                  const SizedBox(width: 10),
                  _DifficultyButton(
                    emoji: '🙂',
                    difficulty: 3.3,
                    chosenDifficulty: viewModel.chosenDifficulty,
                    highlightColor: viewModel.highlightColor,
                    onTap: viewModel.updateDifficulty,
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
                    chosenDifficulty: viewModel.chosenDifficulty,
                    highlightColor: viewModel.highlightColor,
                    onTap: viewModel.updateDifficulty,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => viewModel.submitDialog(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  DifficultyPopupDialogModel viewModelBuilder(BuildContext context) =>
      DifficultyPopupDialogModel();
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

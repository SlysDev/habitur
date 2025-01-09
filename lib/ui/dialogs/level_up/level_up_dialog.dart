import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'level_up_dialog_model.dart';

class LevelUpDialog extends StackedView<LevelUpDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const LevelUpDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LevelUpDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      backgroundColor: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConfettiWidget(
              confettiController: viewModel.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.02,
              numberOfParticles: 15,
              gravity: 0.1,
              maxBlastForce: 20,
              minBlastForce: 10,
            ),
            Icon(
              Icons.star_rounded,
              size: 60,
              color: Colors.amber,
            ),
            SizedBox(height: 20),
            Text(
              'Level Up!\nYou\'re now level ${request.data?['level']}',
              style: kHeadingTextStyle.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Keep crushing those habits!',
              style: kSubDescription.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => viewModel.closeDialog(),
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sweet!',
                  style: kCtaBtnStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  LevelUpDialogModel viewModelBuilder(BuildContext context) =>
      LevelUpDialogModel();

  @override
  void onViewModelReady(LevelUpDialogModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialize();
  }
}

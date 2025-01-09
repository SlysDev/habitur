import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:habitur/ui/widgets/modern_card.dart';

import 'streak_milestone_dialog_model.dart';

const double _graphicSize = 60;

class StreakMilestoneDialog extends StackedView<StreakMilestoneDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const StreakMilestoneDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StreakMilestoneDialogModel viewModel,
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
              Icons.local_fire_department_rounded,
              size: 60,
              color: kOrangeAccent,
            ),
            SizedBox(height: 20),
            Text(
              'You\'ve reached a \n${request.data?['streak']} day streak!',
              style: kHeadingTextStyle.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Keep up the great work!',
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
                  color: kOrangeAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Awesome!',
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
  StreakMilestoneDialogModel viewModelBuilder(BuildContext context) =>
      StreakMilestoneDialogModel();

  @override
  void onViewModelReady(StreakMilestoneDialogModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.initialize();
  }
}

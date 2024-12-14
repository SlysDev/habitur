import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:habitur/ui/widgets/stat_change_indicator/stat_change_indicator.dart';
import 'package:habitur/ui/widgets/user_avatar_list/user_avatar_list.dart';
import 'package:stacked/stacked.dart';

import 'shared_habit_card_model.dart';

class SharedHabitCard extends StackedView<SharedHabitCardModel> {
  const SharedHabitCard({
    super.key,
    required this.sharedHabit,
    this.color = kDarkPrimaryColor,
  });

  final SharedHabit sharedHabit;
  final Color color;

  @override
  Widget builder(
    BuildContext context,
    SharedHabitCardModel viewModel,
    Widget? child,
  ) {
    double height = viewModel.sharedHabit.title.length > 20
        ? 128.0 + (viewModel.sharedHabit.title.length.toDouble() * 2.15)
        : 128;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      opacity: viewModel.isBusy ? 0.6 : 1,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              debugPrint(
                  'Navigating to shared habit dashboard for habit ID: ${viewModel.sharedHabit.id}');
              await viewModel.navigateToSharedHabitDashboard();
            },
            child: Slidable(
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    autoClose: true,
                    onPressed: (context) async {
                      await viewModel.deleteSharedHabit();
                    },
                    backgroundColor: kLightRedAccent,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Delete',
                  ),
                  viewModel.isCurrentUserAuthor ? 
                  SlidableAction(
                    onPressed: (context) async {
                      await viewModel.editSharedHabit();
                    },
                    backgroundColor: kDarkPrimaryColor,
                    icon: Icons.edit,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Edit',
                  ) : Container(),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.ease,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.5 -
                              (viewModel.hasCurrentUserCompleted ? 0.3 : 0)),
                          color.withOpacity(0.2 -
                              (viewModel.hasCurrentUserCompleted ? 0.1 : 0)),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.isBusy
                                      ? '...'
                                      : viewModel.sharedHabit.title,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                UserAvatarList(
                                  usernames: viewModel
                                      .sharedHabit.participantData
                                      .map((e) => e.username)
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            debugPrint(
                                'Incrementing shared habit ID: ${viewModel.sharedHabit.id}');
                            await viewModel.incrementSharedHabit();
                          },
                          onLongPress: () async {
                            debugPrint(
                                'Long press detected on shared habit ID: ${viewModel.sharedHabit.id}');
                            await viewModel.decrementSharedHabit();
                          },
                          child: Stack(
                            children: [
                              RoundedProgressBar(
                                progress: viewModel.userProgressPercentage,
                                color: viewModel.hasCurrentUserCompleted
                                    ? kLightGreenAccent
                                    : kFadedGreen.withOpacity(0.5),
                                width: 100,
                                lineHeight: height,
                                radius: 17.5,
                              ),
                              Positioned.fill(
                                child: Icon(
                                  viewModel.hasCurrentUserCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.check_rounded,
                                  color: viewModel.hasCurrentUserCompleted
                                      ? Colors.white
                                      : kLightGreenAccent,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Icon(
                      Icons.group,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 128,
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                emissionFrequency: 0,
                minBlastForce: 10,
                numberOfParticles: 10,
                blastDirectionality: BlastDirectionality.explosive,
                confettiController: viewModel.controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  SharedHabitCardModel viewModelBuilder(BuildContext context) =>
      SharedHabitCardModel(sharedHabit: sharedHabit);
}

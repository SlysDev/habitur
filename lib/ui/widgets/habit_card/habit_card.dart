import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/shared_habit.dart';
import 'package:habitur/ui/views/habit_overview/habit_overview_view.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:habitur/ui/widgets/user_avatar_list/user_avatar_list.dart';
import 'package:stacked/stacked.dart';

import 'habit_card_model.dart';

class HabitCard extends StackedView<HabitCardModel> {
  const HabitCard({
    super.key,
    required this.habit,
    this.color = kFadedBlue,
  });

  final HabitInterface habit;
  final Color color;

  @override
  Widget builder(
      BuildContext context, HabitCardModel viewModel, Widget? child) {
    double height = 128.0 + (viewModel.habit.title.length.toDouble() * 2.15);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      opacity: viewModel.isBusy ? 0.6 : 1,
      child: Stack(
        children: [
          GestureDetector(
            onLongPress: () {
              viewModel.habit.lastSeen =
                  DateTime.now().subtract(const Duration(days: 1));
            },
            onTap: () async {
              debugPrint(
                  'Navigating to habit dashboard for habit ID: ${viewModel.habit.id}');
              await viewModel.navigateToHabitDashboard();
            },
            child: Slidable(
              startActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    autoClose: true,
                    onPressed: (context) async {
                      await viewModel.deleteHabit();
                    },
                    backgroundColor: kLightRedAccent,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      await viewModel.editHabit();
                    },
                    backgroundColor: kDarkPrimaryColor,
                    icon: Icons.edit,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Edit',
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.ease,
                height: height,
                decoration: BoxDecoration(
                  color: !viewModel.completed
                      ? color.withOpacity(0.5)
                      : color.withOpacity(0.25),
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
                                  : viewModel.currentHabit.title,
                              style: kHeadingTextStyle.copyWith(
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            if (viewModel.habit.isShared)
                              const SizedBox(
                                height: 10,
                              ),
                            if (viewModel.habit is SharedHabit)
                              UserAvatarList(
                                  usernames: (viewModel.habit as SharedHabit)
                                      .participantData
                                      .map((e) => e.username)
                                      .toList()),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await viewModel.incrementHabit();
                      },
                      onLongPress: () async {
                        debugPrint(
                            'Long press detected on habit ID: ${viewModel.habit.id}');
                        await viewModel.decrementHabit();
                      },
                      child: Stack(
                        children: [
                          RoundedProgressBar(
                            progress: viewModel.progressPercentage,
                            color: viewModel.habit.isCompleted
                                ? kLightGreenAccent
                                : kFadedGreen.withOpacity(0.5),
                            width: 100,
                            lineHeight: height,
                            radius: 20,
                          ),
                          Positioned.fill(
                            child: Icon(
                              viewModel.habit.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.check_rounded,
                              color: viewModel.habit.isCompleted
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
            ),
          ),
          Container(
            height: 128,
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: viewModel.controller,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0,
                numberOfParticles: 15,
                gravity: 0.1,
                maxBlastForce: 20,
                minBlastForce: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  HabitCardModel viewModelBuilder(BuildContext context) {
    return HabitCardModel(habit: habit);
  }
}

// if (isShared)
//   Row(
//     children: [
//       // Display avatar icons for shared habits
//       for (String username
//           in usernames.take(3))
//         Padding(
//           padding: const EdgeInsets.only(
//               right: 4.0),
//           child:
//               UserAvatar(username: username),
//         ),
//       if (usernames.length > 3)
//         const CircleAvatar(
//           radius: 12,
//           backgroundColor: kGray,
//           child: Text(
//             '...',
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 12),
//           ),
//         ),
//     ],
//   ),

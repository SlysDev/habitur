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

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    this.color = kFadedBlue,
  });

  final HabitInterface habit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HabitCardModel>.reactive(
      key: ValueKey('habit_model_${habit.id}'),
      viewModelBuilder: () => HabitCardModel(
        habit: habit,
      ),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        double height = model.habit.title.length > 20
            ? 128.0 + (model.habit.title.length.toDouble() * 2.15)
            : 128;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          opacity: model.isBusy ? 0.6 : 1,
          child: Stack(
            children: [
              GestureDetector(
                onLongPress: () {
                  model.habit.lastSeen =
                      DateTime.now().subtract(const Duration(days: 1));
                },
                onTap: () async {
                  await model.navigateToHabitDashboard();
                },
                child: Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        autoClose: true,
                        onPressed: (context) async {
                          await model.deleteHabit();
                        },
                        backgroundColor: kLightRedAccent,
                        icon: Icons.delete,
                        borderRadius: BorderRadius.circular(20),
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          await model.editHabit();
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
                      color: !model.completed
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
                                  model.isBusy ? '...' : model.habit.title,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                if (model.habit.isShared)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                if (model.habit is SharedHabit)
                                  UserAvatarList(
                                      usernames: (model.habit as SharedHabit)
                                          .participantData
                                          .map((e) => e.user.username)
                                          .toList()),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await model.incrementHabit();
                          },
                          onLongPress: () async {
                            await model.uncompleteHabit();
                          },
                          child: Stack(
                            children: [
                              RoundedProgressBar(
                                progress: model.progressPercentage,
                                color: model.habit.isCompleted
                                    ? kLightGreenAccent
                                    : kFadedGreen.withOpacity(0.5),
                                width: 100,
                                lineHeight: height,
                                radius: 17.5,
                              ),
                              Positioned.fill(
                                child: Icon(
                                  model.habit.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.check_rounded,
                                  color: model.habit.isCompleted
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
                    emissionFrequency: 0,
                    minBlastForce: 10,
                    numberOfParticles: 10,
                    blastDirectionality: BlastDirectionality.explosive,
                    confettiController: model.controller,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

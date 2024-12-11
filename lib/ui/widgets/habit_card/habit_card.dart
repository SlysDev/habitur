import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/ui/views/habit_overview/habit_overview_view.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:stacked/stacked.dart';

import 'habit_card_model.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    this.color = kFadedBlue,
  });

  final Habit habit;
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
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.ease,
                        height: model.habit.title.length > 20
                            ? 128.0 +
                                (model.habit.title.length.toDouble() * 2.15)
                            : 128,
                        decoration: BoxDecoration(
                          color:
                              !model.completed ? color : color.withOpacity(0.5),
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Column(
                                          children: [
                                            RoundedProgressBar(
                                              progress:
                                                  model.progressPercentage,
                                              color: Colors.white,
                                              width: constraints.maxWidth,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.ease,
                                width: 100,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 30,
                                  color: kLightGreenAccent,
                                ),
                              ),
                            ),
                          ],
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

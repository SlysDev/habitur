import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/ui/views/habit_overview/habit_overview_view.dart';
import 'package:stacked/stacked.dart';

import 'habit_card_model.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.habit, this.color = kFadedBlue});

  final Habit habit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HabitCardModel>.reactive(
      viewModelBuilder: () => HabitCardModel(habit: habit),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            opacity: model.isBusy ? 0.6 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitOverviewView(
                          habitId: model.habit.id.toString(),
                        ),
                      ),
                    );
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
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2634),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    model.isBusy ? '...' : model.habit.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Participant Avatars
                                SizedBox(
                                  height: 32,
                                  width: 52, // Width for 2 avatars + dot
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Placeholder avatars - replace with actual participant data
                                      for (var i = 0; i < 2; i++)
                                        Positioned(
                                          left: i * 20.0,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF1A2634),
                                                width: 2,
                                              ),
                                              color: Colors.grey[400],
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      if (true)
                                        Positioned(
                                          left: 40,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await model.incrementHabit();
                            },
                            onLongPress: () async {
                              model.uncompleteHabit();
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A5A4B),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  // Circular progress indicator
                                  CircularProgressIndicator(
                                    value: model.progress,
                                    backgroundColor: Colors.black12,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4CAF50),
                                    ),
                                    strokeWidth: 3,
                                  ),
                                  // Checkmark icon
                                  const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ConfettiWidget(
                  emissionFrequency: 0,
                  minBlastForce: 10,
                  numberOfParticles: 10,
                  blastDirectionality: BlastDirectionality.explosive,
                  confettiController: model.controller,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

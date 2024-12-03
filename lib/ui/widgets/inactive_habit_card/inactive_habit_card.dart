import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:stacked/stacked.dart';

import 'inactive_habit_card_model.dart';

class InactiveHabitCard extends StackedView<InactiveHabitCardModel> {
  const InactiveHabitCard({
    super.key,
    required this.habit,
    this.color = const Color(0x0AFFFFFF), // 4% white opacity
  });

  final Habit habit;
  final Color color;

  @override
  Widget builder(
    BuildContext context,
    InactiveHabitCardModel viewModel,
    Widget? child,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutSine,
      opacity: viewModel.isBusy ? 0.1 : 1,
      child: Stack(
        children: [
          GestureDetector(
            onTap: viewModel.navigateToOverview,
            child: Slidable(
              startActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) async => await viewModel.deleteHabit(),
                    backgroundColor: kLightRedAccent,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(20),
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (_) async => await viewModel.editHabit(),
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
                    height: 128,
                    decoration: BoxDecoration(
                      color: !viewModel.completed
                          ? color
                          : color.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.isBusy
                                      ? '...'
                                      : viewModel.habit.title,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white.withOpacity(0.75)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                viewModel.isBusy
                                    ? Container()
                                    : RoundedProgressBar(
                                        progress: viewModel.progress,
                                        color: viewModel.completed
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.white,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 30,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  InactiveHabitCardModel viewModelBuilder(BuildContext context) =>
      InactiveHabitCardModel();

  @override
  void onViewModelReady(InactiveHabitCardModel viewModel) =>
      viewModel.init(habit);
}

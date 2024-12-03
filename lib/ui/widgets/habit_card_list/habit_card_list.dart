import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/habit_card/habit_card.dart';
import 'package:stacked/stacked.dart';

import 'habit_card_list_model.dart';

class HabitCardList extends StackedView<HabitCardListModel> {
  const HabitCardList({super.key});

  @override
  Widget builder(
    BuildContext context,
    HabitCardListModel viewModel,
    Widget? child,
  ) {
    return SizedBox(
      width: double.infinity,
      child: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        onRefresh: () async {
          await viewModel.onRefresh();
        },
        child: viewModel.habits.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No habits yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start building better habits today',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.addHabit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Your First Habit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: viewModel.habits.length,
                itemBuilder: (context, index) {
                  final habit = viewModel.getHabit(index);
                  return Column(
                    key: ValueKey('habit_column_${habit.id}'),
                    children: [
                      const SizedBox(height: 20),
                      HabitCard(
                        key: ValueKey('habit_card_${habit.id}'),
                        habit: habit,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
      ),
    );
  }

  @override
  HabitCardListModel viewModelBuilder(BuildContext context) =>
      HabitCardListModel();
}

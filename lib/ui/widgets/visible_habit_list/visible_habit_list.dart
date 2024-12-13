import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/habit.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/ui/widgets/mini_habit_card.dart';
import 'package:stacked/stacked.dart';

import 'visible_habit_list_model.dart';

class VisibleHabitList extends StackedView<VisibleHabitListModel> {
  final String userId;
  final bool isFriendProfile;
  final SharingScope? habitsScope;
  final List<HabitInterface>? habits;

  const VisibleHabitList({
    Key? key,
    required this.userId,
    this.isFriendProfile = false,
    this.habitsScope,
    this.habits,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    VisibleHabitListModel viewModel,
    Widget? child,
  ) {
    if (habits != null) {
      return _buildHabitList(viewModel, habits!);
    }

    // Check if user has chosen to share habits
    if (!viewModel.userHasChosenToShareHabits) {
      return const Center(
        child: Text(
          'No habits shared yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    // Load habits if the user is allowed
    return FutureBuilder<List<HabitInterface>>(
      future: viewModel.loadHabits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading habits',
              style: TextStyle(color: kGray),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No habits yet',
              style: TextStyle(color: kGray),
            ),
          );
        }

        return _buildHabitList(viewModel, snapshot.data!);
      },
    );
  }

  Widget _buildHabitList(VisibleHabitListModel viewModel, List<HabitInterface> habits) {
    final visibleHabits = viewModel.getVisibleHabits(habits);

    if (visibleHabits.isEmpty) {
      return const Center(
        child: Text(
          'No habits shared yet',
          style: TextStyle(color: kGray),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: visibleHabits
          .map((habit) => [
                MiniHabitCard(habit: habit),
                const SizedBox(height: 12),
              ])
          .expand((x) => x)
          .toList()
        ..removeLast(), // Remove the last spacer
    );
  }

  @override
  void onViewModelReady(VisibleHabitListModel viewModel) {
    // TODO: implement onViewModelReady
    viewModel.initialize(userId, isFriendProfile, habitsScope, habits);
  }

  @override
  VisibleHabitListModel viewModelBuilder(
    BuildContext context,
  ) {
    final viewModel = VisibleHabitListModel();
    return viewModel;
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'edit_habit_viewmodel.dart';

class EditHabitView extends StackedView<EditHabitViewModel> {
  final String? habitId;

  const EditHabitView({super.key, this.habitId});

  @override
  Widget builder(
      BuildContext context, EditHabitViewModel viewModel, Widget? child) {
    return Scaffold(
      key: const Key('EditHabitView_Scaffold'),
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        key: const Key('EditHabitView_AppBar'),
        title: Text(habitId == null ? 'Add Habit' : 'Edit Habit'),
        actions: [
          if (habitId != null)
            IconButton(
              key: const Key('EditHabitView_DeleteIconButton'),
              icon: const Icon(Icons.delete),
              onPressed: viewModel.deleteHabit,
            ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  key: const Key('EditHabitView_Column'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const Key('EditHabitView_TitleTextField'),
                      controller: viewModel.titleController,
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Habit Title',
                        hintText: 'Enter habit title',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Reset Period',
                      style: kTitleTextStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildResetPeriodButtons(viewModel),
                    const SizedBox(height: 24),
                    const Text(
                      'Target Goal',
                      style: kTitleTextStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildTargetGoalButtons(viewModel),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Smart Notifications'),
                      subtitle: const Text(
                          'Get reminders based on your habit completion patterns'),
                      value: viewModel.smartNotifsEnabled,
                      onChanged: viewModel.setSmartNotifs,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      key: const Key('EditHabitView_SaveButton'),
                      text: 'Save Habit',
                      onPressed: viewModel.saveHabit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildResetPeriodButtons(EditHabitViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => viewModel.setResetPeriod('Daily'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                viewModel.resetPeriod == 'Daily' ? kPrimaryColor : null,
          ),
          child: const Text('Daily'),
        ),
        ElevatedButton(
          onPressed: () => viewModel.setResetPeriod('Weekly'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                viewModel.resetPeriod == 'Weekly' ? kPrimaryColor : null,
          ),
          child: const Text('Weekly'),
        ),
        ElevatedButton(
          onPressed: () => viewModel.setResetPeriod('Monthly'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                viewModel.resetPeriod == 'Monthly' ? kPrimaryColor : null,
          ),
          child: const Text('Monthly'),
        ),
      ],
    );
  }

  Widget _buildTargetGoalButtons(EditHabitViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => viewModel.setTargetGoal(1),
          style: ElevatedButton.styleFrom(
            backgroundColor: viewModel.targetGoal == 1 ? kPrimaryColor : null,
          ),
          child: const Text('1x'),
        ),
        ElevatedButton(
          onPressed: () => viewModel.setTargetGoal(2),
          style: ElevatedButton.styleFrom(
            backgroundColor: viewModel.targetGoal == 2 ? kPrimaryColor : null,
          ),
          child: const Text('2x'),
        ),
      ],
    );
  }

  @override
  EditHabitViewModel viewModelBuilder(BuildContext context) =>
      EditHabitViewModel(habitId: habitId ?? '');
}

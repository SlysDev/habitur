import 'package:flutter/material.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/habit_form/habit_form.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'edit_habit_viewmodel.dart';

class EditHabitView extends StackedView<EditHabitViewModel> {
  final String? habitId;

  const EditHabitView({super.key, this.habitId});

  @override
  Widget builder(
    BuildContext context,
    EditHabitViewModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Title bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => viewModel.navigateBack(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    horizontalSpaceMediumNew,
                    Text(
                      'Edit Habit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Expanded(
                  child: HabitForm(
                    initialData: viewModel.habitData,
                    onSubmit: (HabitInterface data) async => await viewModel.saveHabit(data),
                    submitButtonText: viewModel.isBusy ? '...' : 'Save Habit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  EditHabitViewModel viewModelBuilder(BuildContext context) {
    debugPrint('here is the habit id: $habitId');
    return EditHabitViewModel(habitId: habitId ?? '');
  }
}

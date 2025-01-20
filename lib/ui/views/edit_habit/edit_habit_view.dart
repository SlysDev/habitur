import 'package:flutter/material.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/habit_form/habit_form.dart';
import 'package:habitur/ui/widgets/measurement_toggle/measurement_toggle.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'edit_habit_viewmodel.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/reset_period_selector/reset_period_selector.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';

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
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
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
                    titleController: viewModel.titleController,
                    resetPeriod: viewModel.resetPeriod,
                    targetGoal: viewModel.targetGoal,
                    smartNotificationsEnabled:
                        viewModel.smartNotificationsEnabled,
                    selectedDays: viewModel.selectedDays,
                    usesMeasurement: viewModel.usesMeasurement,
                    measurementUnit: viewModel.measurementUnit,
                    onResetPeriodChanged: viewModel.setResetPeriod,
                    onTargetGoalChanged: viewModel.adjustTargetGoal,
                    onSmartNotificationsChanged:
                        viewModel.setSmartNotifications,
                    onDayToggled: viewModel.toggleDay,
                    onUsesMeasurementChanged: viewModel.setUsesMeasurement,
                    onMeasurementUnitChanged: viewModel.setMeasurementUnit,
                    submitButton: PrimaryButton(
                      onPressed: () async {
                        if (!viewModel.isBusy) {
                          await viewModel.saveHabit();
                          await viewModel.navigateBack();
                        }
                      },
                      text: viewModel.isBusy ? '...' : 'Save Habit',
                    ),
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

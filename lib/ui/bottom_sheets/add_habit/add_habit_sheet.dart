import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
import 'package:habitur/ui/widgets/habit_form/habit_form.dart';
import 'package:habitur/ui/widgets/measurement_toggle/measurement_toggle.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/reset_period_selector/reset_period_selector.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/static_card.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'add_habit_sheet_model.dart';

class AddHabitSheet extends StackedView<AddHabitSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const AddHabitSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddHabitSheetModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Title bar
            Text(
              'New Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: HabitForm(
                titleController: viewModel.titleController,
                resetPeriod: viewModel.resetPeriod,
                targetGoal: viewModel.targetGoal,
                smartNotificationsEnabled: viewModel.smartNotificationsEnabled,
                selectedDays: viewModel.selectedDays,
                usesMeasurement: viewModel.usesMeasurement,
                measurementUnit: viewModel.measurementUnit,
                onResetPeriodChanged: viewModel.setResetPeriod,
                onTargetGoalChanged: viewModel.adjustTargetGoal,
                onSmartNotificationsChanged: viewModel.setSmartNotifications,
                onDayToggled: viewModel.toggleDay,
                onUsesMeasurementChanged: viewModel.setUsesMeasurement,
                onMeasurementUnitChanged: viewModel.setMeasurementUnit,
                submitButton: PrimaryButton(
                  onPressed: () async {
                    if (!viewModel.isBusy) {
                      await viewModel.createHabit();
                    }
                  },
                  text: viewModel.isBusy ? '...' : 'Create Habit',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AddHabitSheetModel viewModelBuilder(BuildContext context) =>
      AddHabitSheetModel();
}

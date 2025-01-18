import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
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
              child: ListView(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  // Habit name input
                  FormTextField(
                    label: 'Habit Name',
                    controller: viewModel.titleController,
                    hint: 'Meditate, Exercise, Read...',
                  ),
                  const SizedBox(height: 24),

                  // Smart notifications toggle
                  SmartNotificationsToggle(
                    smartNotificationsEnabled:
                        viewModel.smartNotificationsEnabled,
                    onSmartNotificationsChanged:
                        viewModel.setSmartNotifications,
                  ),

                  const SizedBox(height: 24),

                  // Reset period selector
                  ModernCard(
                    child: ResetPeriodSelector(
                      resetPeriod: viewModel.resetPeriod,
                      onResetPeriodChanged: (period) {
                        viewModel.setResetPeriod(period);
                        viewModel
                            .notifyListeners(); // Ensure listeners are notified
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Days of week selector
                  viewModel.resetPeriod == 'Daily'
                      ? ModernCard(
                          child: DaysOfWeekSelector(
                            selectedDays: viewModel.selectedDays,
                            onDayToggled: viewModel.toggleDay,
                          ),
                        )
                      : Container(),
                  viewModel.resetPeriod == 'Daily'
                      ? const SizedBox(height: 24)
                      : Container(),

                  // Target goal selector
                  ModernCard(
                    child: TargetGoalSelector(
                      targetGoal: viewModel.targetGoal,
                      resetPeriodNoun: viewModel.resetPeriodNoun,
                      onTargetGoalChanged: viewModel.setTargetGoal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  MeasurementToggle(
                    usesMeasurement: viewModel.usesMeasurement,
                    measurementUnit: viewModel.measurementUnit,
                    onUsesMeasurementChanged: viewModel.setUsesMeasurement,
                    onMeasurementUnitChanged: viewModel.setMeasurementUnit,
                  ),
                  const SizedBox(height: 40),

                  // Create button
                  PrimaryButton(
                    onPressed: viewModel.isBusy ? () {} : viewModel.createHabit,
                    text: viewModel.isBusy ? '...' : 'Create Habit',
                  ),
                ],
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

import 'package:flutter/material.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
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
                          onTargetGoalChanged: viewModel.adjustTargetGoal,
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

                      // Save button
                      PrimaryButton(
                        onPressed: viewModel.isBusy
                            ? () {}
                            : () {
                                viewModel.saveHabit();
                                viewModel.navigateBack();
                              },
                        text: viewModel.isBusy ? '...' : 'Save Habit',
                      ),
                    ],
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
  EditHabitViewModel viewModelBuilder(BuildContext context) =>
      EditHabitViewModel(habitId: habitId ?? '');
}

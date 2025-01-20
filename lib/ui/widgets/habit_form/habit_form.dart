import 'package:flutter/material.dart';
import 'package:habitur/models/habit_interface.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
import 'package:habitur/ui/widgets/measurement_toggle/measurement_toggle.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/reset_period_selector/reset_period_selector.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'habit_form_viewmodel.dart';
// ... other imports

class HabitForm extends StackedView<HabitFormViewModel> {
  final Function(HabitInterface) onSubmit;
  final String submitButtonText;
  final HabitInterface? initialData;

  const HabitForm({
    Key? key,
    required this.onSubmit,
    required this.submitButtonText,
    this.initialData,
  }) : super(key: key);

  @override
  Widget builder(BuildContext context, HabitFormViewModel viewModel, Widget? child) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        FormTextField(
          label: 'Habit Name',
          controller: viewModel.titleController,
          hint: 'Meditate, Exercise, Read...',
        ),
        const SizedBox(height: 24),

        SmartNotificationsToggle(
          smartNotificationsEnabled: viewModel.smartNotificationsEnabled,
          onSmartNotificationsChanged: viewModel.setSmartNotifications,
        ),
        const SizedBox(height: 24),

        ModernCard(
          child: ResetPeriodSelector(
            resetPeriod: viewModel.resetPeriod,
            onResetPeriodChanged: viewModel.setResetPeriod,
          ),
        ),
        const SizedBox(height: 24),

        if (viewModel.resetPeriod == 'Daily') ...[
          ModernCard(
            child: DaysOfWeekSelector(
              selectedDays: viewModel.selectedDays,
              onDayToggled: viewModel.toggleDay,
            ),
          ),
          const SizedBox(height: 24),
        ],

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

        PrimaryButton(
          onPressed: () => onSubmit(viewModel.getFormData()),
          text: submitButtonText,
        ),
      ],
    );
  }

  @override
  HabitFormViewModel viewModelBuilder(BuildContext context) {
    final viewModel = HabitFormViewModel();
    debugPrint('here is the initial data: $initialData');
    viewModel.initializeWithHabit(initialData);
    return viewModel;
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'edit_shared_habit_viewmodel.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/reset_period_selector/reset_period_selector.dart';
import 'package:habitur/ui/widgets/day_of_week_selector/day_of_week_selector.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';

class EditSharedHabitView extends StackedView<EditSharedHabitViewModel> {
  final String? habitId;

  const EditSharedHabitView({super.key, this.habitId});

  @override
  Widget builder(
    BuildContext context,
    EditSharedHabitViewModel viewModel,
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
                      'Edit Shared Habit',
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
                        hint: 'Enter habit name',
                      ),
                      const SizedBox(height: 24),

                      // Description input
                      FormTextField(
                        label: 'Description',
                        controller: viewModel.descriptionController,
                        hint: 'Enter habit description',
                        maxLines: 3,
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

                      // Participants selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Participants',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          verticalSpaceSmall,
                          ModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (viewModel.selectedParticipants.isEmpty)
                                  const Text(
                                    'No participants selected',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ...viewModel.selectedParticipants
                                    .where((participant) =>
                                        participant.userId !=
                                        viewModel.currentUserId)
                                    .map(
                                      (participant) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          participant.username,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white),
                                          onPressed: () => viewModel
                                              .removeParticipant(participant),
                                        ),
                                      ),
                                    ),
                                verticalSpaceSmall,
                                PrimaryButton(
                                  text: 'Select Participants',
                                  onPressed: viewModel.selectParticipants,
                                ),
                              ],
                            ),
                          ),
                        ],
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
  EditSharedHabitViewModel viewModelBuilder(BuildContext context) =>
      EditSharedHabitViewModel(habitId: habitId ?? '');
}

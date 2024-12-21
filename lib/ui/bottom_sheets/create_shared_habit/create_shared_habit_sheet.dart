import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/smart_notifications_toggle/smart_notifications_toggle.dart';
import 'package:habitur/ui/widgets/target_goal_selector/target_goal_selector.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'create_shared_habit_sheet_model.dart';

class CreateSharedHabitSheet extends StackedView<CreateSharedHabitSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const CreateSharedHabitSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CreateSharedHabitSheetModel viewModel,
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
            Text(
              'Create Shared Habit',
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
                  FormTextField(
                    label: 'Habit Name',
                    hint: 'Enter habit name',
                    onChanged: viewModel.setHabitName,
                  ),
                  verticalSpaceMedium,
                  FormTextField(
                    label: 'Description',
                    hint: 'Enter habit description',
                    onChanged: viewModel.setHabitDescription,
                    maxLines: 3,
                  ),
                  verticalSpaceMedium,
                  SmartNotificationsToggle(
                      smartNotificationsEnabled: viewModel.smartNotifsEnabled,
                      onSmartNotificationsChanged: viewModel.setSmartNotifs),
                  verticalSpaceMedium,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequency',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      verticalSpaceSmall,
                      ModernCard(
                        child: TargetGoalSelector(
                          targetGoal: viewModel.targetGoal,
                          resetPeriodNoun: viewModel.resetPeriodNoun,
                          onTargetGoalChanged: viewModel.setTargetGoal,
                        ),
                      ),
                      // ModernCard(
                      //   padding: 0,
                      //   child: DropdownButton<String>(
                      //     borderRadius: BorderRadius.circular(15),
                      //     padding: EdgeInsets.all(15),
                      //     value: viewModel.selectedResetPeriod,
                      //     isExpanded: true,
                      //     dropdownColor: kBackgroundColor,
                      //     style: const TextStyle(color: Colors.white),
                      //     underline: Container(),
                      //     items: ['Daily', 'Weekly', 'Monthly']
                      //         .map((frequency) => DropdownMenuItem(
                      //               value: frequency,
                      //               child: Text(frequency),
                      //             ))
                      //         .toList(),
                      //     onChanged: (value) {
                      //       if (value != null) viewModel.setFrequency(value);
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                  verticalSpaceMedium,
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
                            ...viewModel.selectedParticipants.map(
                              (participant) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading:
                                    UserAvatar(username: participant.username),
                                title: Text(
                                  participant.username,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () =>
                                      viewModel.removeParticipant(participant),
                                ),
                              ),
                            ),
                            verticalSpaceSmall,
                            AsideButton(
                              text: 'Select Participants',
                              onPressed: viewModel.selectParticipants,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            verticalSpaceMedium,
            PrimaryButton(
              text: 'Create Shared Habit',
              onPressed: () async {
                final success = await viewModel.createSharedHabit();
                if (success) {
                  completer?.call(SheetResponse(confirmed: true));
                }
              },
              isLoading: viewModel.isBusy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartNotificationsToggle(
      CreateSharedHabitSheetModel model, BuildContext context) {
    return ModernCard(
      color: kFadedGreen,
      opacity: 0.1,
      padding: 10,
      child: SwitchListTile.adaptive(
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: kLightGreenAccent,
              size: 30,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                  screenWidth(context) > 400
                      ? 'Smart Notifications'
                      : 'Smart \n Notifications',
                  textAlign: TextAlign.center,
                  style: kMainDescription.copyWith(fontSize: 16)),
            ),
          ],
        ),
        onChanged: model.setSmartNotifs,
        value: model.smartNotifsEnabled,
      ),
    );
  }

  @override
  CreateSharedHabitSheetModel viewModelBuilder(BuildContext context) =>
      CreateSharedHabitSheetModel();
}

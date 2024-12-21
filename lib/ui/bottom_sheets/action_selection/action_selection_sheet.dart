import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'action_selection_sheet_model.dart';

class ActionSelectionSheet extends StackedView<ActionSelectionSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const ActionSelectionSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ActionSelectionSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          verticalSpaceMedium,

          // Title
          const Text(
            'What would you like to do?',
            style: kSubHeadingTextStyle,
          ),
          verticalSpaceLarge,

          // Action buttons
          _ActionButton(
            icon: Icons.check_circle_outline,
            color: kPrimaryColor,
            title: 'Create Habit',
            subtitle: 'Start tracking a new habit',
            onTap: viewModel.onCreateHabit,
          ),
          verticalSpaceSmall,
          _ActionButton(
            icon: Icons.group,
            color: kLightRedAccent,
            title: 'Create Shared Habit',
            subtitle: 'Start a habit with friends',
            onTap: viewModel.onCreateSharedHabit,
          ),
          verticalSpaceSmall,
          _ActionButton(
            icon: Icons.control_point_outlined,
            color: kDarkGray,
            title: 'Share Activity',
            subtitle: 'Coming soon!!',
            onTap: viewModel.onShareActivity,
          ),
          verticalSpaceMedium,
        ],
      ),
    );
  }

  @override
  ActionSelectionSheetModel viewModelBuilder(BuildContext context) =>
      ActionSelectionSheetModel();
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kFadedBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: kMainDescription),
                    const SizedBox(height: 4),
                    Text(subtitle, style: kSubDescription),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: kGray),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:stacked/stacked.dart';

import 'profile_drawer_button_model.dart';

class ProfileDrawerButton extends StackedView<ProfileDrawerButtonModel> {
  const ProfileDrawerButton({super.key});

  @override
  Widget builder(
    BuildContext context,
    ProfileDrawerButtonModel viewModel,
    Widget? child,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.person_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
        if (viewModel.hasNewFriendRequests)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 10,
                minHeight: 10,
              ),
            ),
          ),
      ],
    );
  }

  @override
  ProfileDrawerButtonModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfileDrawerButtonModel();
}

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'user_avatar_model.dart';

class UserAvatar extends StackedView<UserAvatarModel> {
  const UserAvatar({super.key, required this.username, this.size = 1});
  final String username;
  final double size;

  @override
  Widget builder(
    BuildContext context,
    UserAvatarModel viewModel,
    Widget? child,
  ) {
    return CircleAvatar(
      radius: 20 * size,
      backgroundColor: viewModel.generateColorFromString(username),
      child: Text(
        viewModel.getInitial(username),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16 * size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  UserAvatarModel viewModelBuilder(
    BuildContext context,
  ) =>
      UserAvatarModel();
}

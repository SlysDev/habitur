import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/ui/widgets/dialog/profile_dialog/profile_dialog.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';

import 'sent_friend_request_card_model.dart';

class SentFriendRequestCard extends StackedView<SentFriendRequestCardModel> {
  const SentFriendRequestCard({super.key, required this.request});

  final FriendRequest request;

  @override
  Widget builder(
    BuildContext context,
    SentFriendRequestCardModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () {
        viewModel.showProfileDialog();
      },
      child: Opacity(
        opacity: request.isAccepted || request.isDeclined ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: kFadedBlue.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kFadedBlue.withOpacity(0.6),
              width: 1,
            ),
          ),
          margin: EdgeInsets.all(16),
          child: ListTile(
            leading: UserAvatar(
              username: viewModel.recipient?.username ?? '',
              size: 40.0,
            ),
            title: Text(
              viewModel.recipient?.username ?? '',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Sent ${viewModel.relativeDate}'),
            trailing: request.isAccepted || request.isDeclined
                ? Text(
                    request.isAccepted
                        ? 'Accepted'
                        : request.isDeclined
                            ? 'Declined'
                            : 'Pending',
                    style: TextStyle(
                      color: request.isAccepted
                          ? kLightGreenAccent
                          : request.isDeclined
                              ? kLightRedAccent
                              : null,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.cancel_outlined, color: kLightRedAccent),
                    onPressed: () async {
                      await viewModel.cancelFriendRequest();
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  SentFriendRequestCardModel viewModelBuilder(
    BuildContext context,
  ) {
    final viewModel = SentFriendRequestCardModel();
    viewModel.initialize(request);
    return viewModel;
  }
}

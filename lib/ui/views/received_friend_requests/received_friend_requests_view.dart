import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'received_friend_requests_viewmodel.dart';

class ReceivedFriendRequestsView
    extends StackedView<ReceivedFriendRequestsViewModel> {
  const ReceivedFriendRequestsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ReceivedFriendRequestsViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.friendRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'No received friend requests.',
          style: TextStyle(
            color: kGray,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: viewModel.friendRequests.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final request = viewModel.friendRequests[index];
        final sender = viewModel.requestSenders[request.senderUid];

        if (sender == null) {
          return _buildLoadingTile();
        }

        return _buildRequestTile(context, request, sender, viewModel);
      },
    );
  }

  Widget _buildLoadingTile() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: _buildTileDecoration(),
      child: const ListTile(
        leading: CircularProgressIndicator(),
        title: Text(
          'Loading...',
          style: TextStyle(color: kGray),
        ),
      ),
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    FriendRequest request,
    UserModel sender,
    ReceivedFriendRequestsViewModel viewModel,
  ) {
    final relativeDate = timeago.format(request.dateSent);

    return Container(
      decoration: _buildTileDecoration(),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: UserAvatar(
              username: sender.username,
              size: 40.0,
            ),
            title: Text(
              sender.username,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: request.isAccepted
                ? const Icon(Icons.check_circle, color: kLightGreenAccent)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: Icons.check,
                        color: kLightGreenAccent,
                        onPressed: () => viewModel.acceptRequest(request),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.close,
                        color: kLightRedAccent,
                        onPressed: () => viewModel.declineRequest(request),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 72.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              'Sent $relativeDate',
              style: TextStyle(
                color: kGray.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildTileDecoration() {
    return BoxDecoration(
      color: kFadedBlue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: kFadedBlue.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  @override
  ReceivedFriendRequestsViewModel viewModelBuilder(BuildContext context) =>
      ReceivedFriendRequestsViewModel();
}

import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/ui/widgets/loading_indicator.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';

import 'received_friend_request_card_model.dart';

class ReceivedFriendRequestCard
    extends StackedView<ReceivedFriendRequestCardModel> {
  const ReceivedFriendRequestCard({
    super.key,
    required this.request,
  });

  final FriendRequest request;

  @override
  Widget builder(BuildContext context, ReceivedFriendRequestCardModel viewModel,
      Widget? child) {
    return Container(
      decoration: BoxDecoration(
        color: kFadedBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kFadedBlue.withOpacity(0.6),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(16),
      child: viewModel.isBusy
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingIndicator(
                  size: 32,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: UserAvatar(
                    username: viewModel.sender?.username ?? '',
                    size: 40.0,
                  ),
                  title: Text(
                    viewModel.sender?.username ?? 'User not found',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: request.isAccepted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  viewModel.acceptFriendRequest(request),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  viewModel.declineFriendRequest(request),
                            ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4.0,
                    bottom: 8.0,
                    left: 64.0,
                  ),
                  child: Text(
                    'Sent ${viewModel.getRelativeTime(request.dateSent)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  ReceivedFriendRequestCardModel viewModelBuilder(
    BuildContext context,
  ) {
    final viewModel = ReceivedFriendRequestCardModel();
    viewModel.init(request);
    return viewModel;
  }
}

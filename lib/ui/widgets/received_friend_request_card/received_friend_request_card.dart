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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: request.isAccepted ? 0.5 : 1,
      child: Container(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserAvatar(
                          username: viewModel.sender?.username ?? '',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.sender?.username ?? 'User not found',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!request.isAccepted)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () =>
                                    viewModel.acceptFriendRequest(request),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () =>
                                    viewModel.declineFriendRequest(request),
                              ),
                            ],
                          )
                        else
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      bottom: 8.0,
                    ),
                    child: Center(
                      child: Text(
                        'Sent ${viewModel.getRelativeTime(request.dateSent)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
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

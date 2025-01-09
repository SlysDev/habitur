import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/friend_request.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/loading_indicator.dart';
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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
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
                            username: viewModel.recipient?.username ?? '',
                          ),
                          horizontalSpaceMediumNew,
                          Expanded(
                            child: Text(
                              viewModel.recipient?.username ?? 'User not found',
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!request.isAccepted && !request.isDeclined)
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.cancel_outlined,
                                  color: kLightRedAccent),
                              onPressed: () async {
                                await viewModel.cancelFriendRequest();
                              },
                            )
                          else
                            Text(
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
                            ),
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
                          'Sent ${viewModel.relativeDate}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
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

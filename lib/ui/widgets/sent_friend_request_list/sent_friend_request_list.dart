import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/sent_friend_request_card/sent_friend_request_card.dart';
import 'package:stacked/stacked.dart';

import 'sent_friend_request_list_model.dart';

class SentFriendRequestList extends StackedView<SentFriendRequestListModel> {
  const SentFriendRequestList({super.key});

  @override
  Widget builder(
    BuildContext context,
    SentFriendRequestListModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Text(
          'Error loading friend requests: ${viewModel.error}',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (viewModel.sentRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'No received friend requests.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: viewModel.sentRequests.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final request = viewModel.sentRequests[index];
        return SentFriendRequestCard(
          request: request,
        );
      },
    );
  }

  @override
  SentFriendRequestListModel viewModelBuilder(
    BuildContext context,
  ) =>
      SentFriendRequestListModel();
}

import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/received_friend_request_card/received_friend_request_card.dart';
import 'package:stacked/stacked.dart';

import 'received_friend_requests_list_model.dart';

class ReceivedFriendRequestsList
    extends StackedView<ReceivedFriendRequestsListModel> {
  const ReceivedFriendRequestsList({super.key});

  @override
  Widget builder(
    BuildContext context,
    ReceivedFriendRequestsListModel viewModel,
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

    if (viewModel.receivedRequests.isEmpty) {
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
      itemCount: viewModel.receivedRequests.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final request = viewModel.receivedRequests[index];
        return ReceivedFriendRequestCard(
          request: request,
        );
      },
    );
  }

  @override
  ReceivedFriendRequestsListModel viewModelBuilder(
    BuildContext context,
  ) =>
      ReceivedFriendRequestsListModel();
}

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'sent_friend_requests_list_model.dart';

class SentFriendRequestsList extends StackedView<SentFriendRequestsListModel> {
  const SentFriendRequestsList({super.key});

  @override
  Widget builder(
    BuildContext context,
    SentFriendRequestsListModel viewModel,
    Widget? child,
  ) {
    return const SizedBox.shrink();
  }

  @override
  SentFriendRequestsListModel viewModelBuilder(
    BuildContext context,
  ) =>
      SentFriendRequestsListModel();
}

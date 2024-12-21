import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/ui/common/ui_helpers.dart';
import 'package:habitur/ui/widgets/select_friends/select_friends.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'select_friends_dialog_model.dart';

class SelectFriendsDialog extends StackedView<SelectFriendsDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SelectFriendsDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SelectFriendsDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      backgroundColor: kBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, completer),
            const SizedBox(height: 16),
            Expanded(
              child: SelectFriendsWidget(
                multiSelect: true,
                initialSelectedFriends: viewModel.selectedFriends,
                onSelectedFriendsChanged: (selectedFriends) {
                  viewModel.setSelectedFriends(selectedFriends);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, completer, viewModel.selectedFriends),
          ],
        ),
      ),
    );
  }

  @override
  SelectFriendsDialogModel viewModelBuilder(BuildContext context) {
    final viewModel = SelectFriendsDialogModel();
    viewModel.init(request.data['preSelectedUsers']);
    return viewModel;
  }
}

Widget _buildHeader(BuildContext context, Function completer) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Select Friends',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => completer(DialogResponse(confirmed: false)),
      ),
    ],
  );
}

Widget _buildActionButtons(
    BuildContext context, Function completer, List<UserModel> selectedFriends) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () => completer(DialogResponse(confirmed: false)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kFadedBlue,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          onPressed: selectedFriends.isNotEmpty
              ? () => completer(
                    DialogResponse(
                      confirmed: true,
                      data: selectedFriends,
                    ),
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedFriends.isNotEmpty ? kPrimaryColor : kDarkGray,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Share',
            style: TextStyle(
              color: selectedFriends.isNotEmpty ? kBackgroundColor : kGray,
            ),
          ),
        ),
      ),
    ],
  );
}

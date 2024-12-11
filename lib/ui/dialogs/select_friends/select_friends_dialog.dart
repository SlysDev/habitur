import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/ui/common/app_colors.dart';
import 'package:habitur/ui/widgets/select_friends/select_friends.dart';
import 'package:stacked_services/stacked_services.dart';

class SelectFriendsDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SelectFriendsDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  _SelectFriendsDialogState createState() => _SelectFriendsDialogState();
}

class _SelectFriendsDialogState extends State<SelectFriendsDialog> {
  List<UserModel> _selectedFriends = [];

  @override
  Widget build(BuildContext context) {
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
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: SelectFriendsWidget(
                multiSelect: true,
                onSelectedFriendsChanged: (selectedFriends) {
                  setState(() {
                    _selectedFriends = selectedFriends;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => widget.completer(DialogResponse(confirmed: false)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.completer(DialogResponse(confirmed: false)),
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
            onPressed: _selectedFriends.isNotEmpty
                ? () => widget.completer(
                      DialogResponse(
                        confirmed: true,
                        data: _selectedFriends,
                      ),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedFriends.isNotEmpty ? kPrimaryColor : kDarkGray,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Share',
              style: TextStyle(
                color: _selectedFriends.isNotEmpty ? kBackgroundColor : kGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

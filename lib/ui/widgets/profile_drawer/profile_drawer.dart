import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/modern_alert_dialog.dart';
import 'package:habitur/ui/widgets/received_friend_requests_list/received_friend_requests_list.dart';
import 'package:habitur/ui/widgets/sent_friend_requests_list/sent_friend_requests_list.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:habitur/ui/widgets/dialog/profile_dialog/profile_dialog.dart';
import 'package:habitur/ui/widgets/friends_list/friends_list.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'profile_drawer_model.dart';
// TODO: Implement received/sent friend requests list

class ProfileDrawer extends StackedView<ProfileDrawerModel> {
  const ProfileDrawer({super.key});

  void _showAddFriendDialog(
      BuildContext context, ProfileDrawerModel viewModel) {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ModernAlertDialog(
          title: 'Add Friend',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormTextField(
                label: 'Username',
                hint: 'Enter a username',
                controller: usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
                prefix: Icon(Icons.person_add),
              ),
            ],
          ),
          actions: [
            AsideButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            const SizedBox(width: 10),
            AsideButton(
              text: 'Send Request',
              onPressed: () async {
                if (usernameController.text.isEmpty) return;
                await viewModel.sendFriendRequest(
                    usernameController.text, context);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.dark(primary: color),
      ),
      child: ExpansionTile(
        initiallyExpanded: title == 'Friends',
        leading: Icon(icon, color: color),
        iconColor: color,
        textColor: color,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        children: [child],
      ),
    );
  }

  @override
  Widget builder(
      BuildContext context, ProfileDrawerModel viewModel, Widget? child) {
    return Drawer(
      backgroundColor: kBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              kFadedBlue,
              kBackgroundColor,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => ProfileDialog(
                          uid: viewModel.uid,
                          isFriendProfile: false,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        bottom: 24,
                        left: 24,
                        right: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      kGray,
                                      kGray.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: UserAvatar(
                                  username: viewModel.currentUser.username,
                                  size: 80.0,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: kLightGreenAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.currentUser.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (viewModel.hasEmail)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                viewModel.currentUser.email!,
                                style: const TextStyle(
                                  color: kGray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          if (viewModel.hasBio) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kFadedBlue.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                viewModel.currentUser.bio!,
                                style: const TextStyle(
                                  color: kGray,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildSection(
                          title: 'Friends',
                          icon: Icons.people_outline_rounded,
                          color: kPrimaryColor,
                          child: const FriendsList(),
                        ),
                        _buildSection(
                          title: 'Friend Requests',
                          icon: Icons.person_add_outlined,
                          color: kOrangeAccent,
                          child: Column(
                            children: [
                              Text(
                                'Received',
                                style: kSubHeadingTextStyle,
                              ),
                              const ReceivedFriendRequestsList(),
                              Divider(
                                color: kFadedBlue,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                              Text(
                                'Sent',
                                style: kSubHeadingTextStyle,
                              ),
                              const SentFriendRequestsList(),
                            ],
                          ),
                        ),
                        _buildSection(
                          title: 'Settings',
                          icon: Icons.settings_outlined,
                          color: kLightPrimaryColor,
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_outline,
                              color: kLightPrimaryColor,
                            ),
                            title: const Text(
                              'Profile Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () => viewModel.navigateToSettings(context),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.add_circle_outline,
                            color: kLightGreenAccent,
                          ),
                          title: const Text(
                            'Add Friend',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showAddFriendDialog(context, viewModel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  ProfileDrawerModel viewModelBuilder(BuildContext context) =>
      ProfileDrawerModel();

  @override
  void onViewModelReady(ProfileDrawerModel viewModel) => viewModel.initialize();
}

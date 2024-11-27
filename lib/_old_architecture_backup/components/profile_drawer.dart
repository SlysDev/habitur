import 'package:flutter/material.dart';
import 'package:habitur/components/profile_dialog.dart';
import 'package:habitur/components/user_avatar.dart';
import 'package:habitur/components/received_friend_requests_list.dart';
import 'package:habitur/components/sent_friend_requests_list.dart';
import 'package:habitur/components/friends_list.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/user.dart';
import 'package:habitur/modules/auth_service.dart';
import 'package:habitur/modules/friends_manager.dart';
import 'package:habitur/screens/settings_screen.dart';
import 'package:habitur/util_functions.dart';
import 'package:provider/provider.dart';

import 'aside_button.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({Key? key}) : super(key: key);

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final FriendsManager friendsManager = FriendsManager();

    // Store the navigator context
    final navigatorContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomAlertDialog(
          title: 'Add Friend',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledTextField(
                controller: usernameController,
                hintText: 'Username',
                prefixIcon: Icons.person_add,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          actions: [
            AsideButton(
              text: 'Cancel',
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            SizedBox(width: 10),
            AsideButton(
              text: 'Send Request',
              onPressed: () async {
                if (usernameController.text.isEmpty) return;

                try {
                  await friendsManager.sendFriendRequestByUsername(
                      usernameController.text,
                      navigatorContext // Use the navigator context instead
                      );
                  Navigator.of(dialogContext).pop();
                  if (navigatorContext.mounted) {
                    showSuccess(
                        navigatorContext, 'Friend request sent successfully');
                  }
                } catch (e) {
                  if (navigatorContext.mounted) {
                    showError(navigatorContext, e.toString());
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserLocalStorage>(context).currentUser;

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
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ProfileDialog(
                      uid: AuthService().currentUser!.uid,
                      isFriendProfile: false,
                    );
                  },
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
                          padding: EdgeInsets.all(3),
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
                            username: user.username,
                            size: 80.0,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: kLightGreenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (user.email != null && user.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user.email!,
                          style: TextStyle(
                            color: kGray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: kFadedBlue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.bio!,
                          style: TextStyle(
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
                    child: FriendsList(),
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
                        ReceivedFriendRequestsList(),
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
                        SentFriendRequestsList()
                      ],
                    ),
                  ),
                  _buildSection(
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    color: kLightPrimaryColor,
                    child: ListTile(
                      leading:
                          Icon(Icons.person_outline, color: kLightPrimaryColor),
                      title: Text(
                        'Profile Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen()),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add_circle_outline,
                        color: kLightGreenAccent),
                    title: Text(
                      'Add Friend',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _showAddFriendDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        colorScheme: ColorScheme.dark(
          primary: color,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: title == 'Friends',
        leading: Icon(icon, color: color),
        iconColor: color,
        textColor: color,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        children: [child],
      ),
    );
  }
}

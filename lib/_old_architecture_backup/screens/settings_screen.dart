import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habitur/components/accent_elevated_button.dart';
import 'package:habitur/components/aside_button.dart';
import 'package:habitur/components/custom_alert_dialog.dart';
import 'package:habitur/components/filled_text_field.dart';
import 'package:habitur/components/inactive_elevated_button.dart';
import 'package:habitur/components/loading_overlay_wrapper.dart';
import 'package:habitur/components/multiline_outlined_text_field.dart';
import 'package:habitur/components/navbar.dart';
import 'package:habitur/components/network_indicator.dart';
import 'package:habitur/components/primary_button.dart';
import 'package:habitur/components/static_card.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/data/local/habits_local_storage.dart';
import 'package:habitur/data/local/user_local_storage.dart';
import 'package:habitur/models/habit_visibility.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/models/setting.dart';
import 'package:habitur/models/time_model.dart';
import 'package:habitur/notifications/notification_manager.dart';
import 'package:habitur/notifications/notification_scheduler.dart';
import 'package:habitur/providers/database.dart';
import 'package:habitur/providers/habit_manager.dart';
import 'package:habitur/providers/loading_state_provider.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:habitur/screens/delete_account_login_screen.dart';
import 'package:habitur/screens/login_screen.dart';
import 'package:habitur/screens/splash_screen.dart';
import 'package:habitur/screens/welcome_screen.dart';
import 'package:habitur/data/local/settings_local_storage.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double gap = 20.0;
  bool isVerifyingEmail = false;
  bool hasUpdatedProfile = false;
  bool hasFailed = false;

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController bioController;
  String email = '';
  String bio = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<UserLocalStorage>(context, listen: false).currentUser;
    usernameController = TextEditingController(text: user.username);
    emailController = TextEditingController(text: user.email);
    bioController = TextEditingController(text: user.bio);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: kHeadingTextStyle,
      ),
    );
  }

  Widget _buildPrivacySection() {
    final userStorage = Provider.of<UserLocalStorage>(context);
    final user = userStorage.currentUser;
    final habitManager = Provider.of<HabitManager>(context);
    final Database db = Database();
    if (user == null) return Container();

    void updatePrivacySettings(PrivacySettings newSettings) {
      db.settingsDatabase.updatePrivacySettings(context, newSettings);
    }

    return Card(
      color: kFadedBlue.withOpacity(0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kPrimaryColor.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip_rounded, color: kPrimaryColor, size: 28),
                SizedBox(width: 12),
                Text('Privacy Settings',
                    style: kHeadingTextStyle.copyWith(fontSize: 24)),
              ],
            ),
            SizedBox(height: 25),

            // Stats & Habits Sharing Scope
            _buildSectionHeader('Sharing Scope', Icons.group_rounded),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: kDarkGray.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildScopeDropdown(
                    title: 'Stats Visibility',
                    subtitle: 'Who can see your habit statistics',
                    value: user.privacySettings?.statsScope ??
                        SharingScope.friends,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        final newSettings = user.privacySettings?.copyWith(
                              statsScope: newValue,
                            ) ??
                            PrivacySettings(statsScope: newValue);
                        updatePrivacySettings(newSettings);
                      }
                    },
                  ),
                  Divider(
                      height: 1,
                      thickness: 1,
                      color: kPrimaryColor.withOpacity(0.1)),
                  _buildScopeDropdown(
                    title: 'Habits Visibility',
                    subtitle: 'Who can see your habits',
                    value: user.privacySettings?.habitsScope ??
                        SharingScope.friends,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        final newSettings = user.privacySettings?.copyWith(
                              habitsScope: newValue,
                            ) ??
                            PrivacySettings(habitsScope: newValue);
                        updatePrivacySettings(newSettings);
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Activity Sharing
            _buildSectionHeader(
                'Activity Sharing', Icons.local_activity_rounded),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: kDarkGray.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSwitch(
                    title: 'Share Activities',
                    subtitle: 'Allow friends to see your habit activities',
                    value: user.privacySettings?.shareActivities ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareActivities: value,
                          ) ??
                          PrivacySettings(shareActivities: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    title: 'Share Habit Completions',
                    subtitle: 'Show when you complete habits',
                    value: user.privacySettings?.shareHabitCompletions ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareHabitCompletions: value,
                          ) ??
                          PrivacySettings(shareHabitCompletions: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    title: 'Share Streak Milestones',
                    subtitle: 'Show when you reach streak milestones',
                    value: user.privacySettings?.shareStreakMilestones ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareStreakMilestones: value,
                          ) ??
                          PrivacySettings(shareStreakMilestones: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    title: 'Share New Habits',
                    subtitle: 'Show when you create new habits',
                    value: user.privacySettings?.shareNewHabits ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareNewHabits: value,
                          ) ??
                          PrivacySettings(shareNewHabits: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Stats Sharing
            _buildSectionHeader('Stats Sharing', Icons.bar_chart_rounded),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: kDarkGray.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSwitch(
                    title: 'Share Confidence Level',
                    subtitle: 'Show your habit confidence metrics',
                    value: user.privacySettings?.shareConfidenceLevel ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareConfidenceLevel: value,
                          ) ??
                          PrivacySettings(shareConfidenceLevel: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitch(
                    title: 'Share Consistency Factor',
                    subtitle: 'Show your habit consistency metrics',
                    value: user.privacySettings?.shareConsistencyFactor ?? true,
                    onChanged: (value) {
                      final newSettings = user.privacySettings?.copyWith(
                            shareConsistencyFactor: value,
                          ) ??
                          PrivacySettings(shareConsistencyFactor: value);
                      updatePrivacySettings(newSettings);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Profile Sharing
            _buildSectionHeader('Profile Sharing', Icons.person_rounded),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: kDarkGray.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
              ),
              child: _buildSwitch(
                title: 'Share Profile Picture',
                subtitle: 'Show your profile picture in activities',
                value: user.privacySettings?.shareProfilePicture ?? true,
                onChanged: (value) {
                  final newSettings = user.privacySettings?.copyWith(
                        shareProfilePicture: value,
                      ) ??
                      PrivacySettings(shareProfilePicture: value);
                  updatePrivacySettings(newSettings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: kPrimaryColor.withOpacity(0.1),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: kGray,
          fontSize: 13,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
      inactiveTrackColor: kDarkGray,
    );
  }

  Widget _buildScopeDropdown({
    required String title,
    required String subtitle,
    required SharingScope value,
    required ValueChanged<SharingScope?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: kGray,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kDarkGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SharingScope>(
                value: value,
                items: SharingScope.values.map((scope) {
                  return DropdownMenuItem(
                    value: scope,
                    child: Text(
                      scope.toString().split('.').last,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                dropdownColor: kDarkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitVisibilityTile({
    required Habit habit,
    required ValueChanged<bool?> onChanged,
  }) {
    return _buildAdaptiveCheckbox(
      title: habit.title,
      value: habit.isVisible ?? true,
      onChanged: onChanged,
    );
  }

  Widget _buildAdaptiveCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: kPrimaryColor,
            ),
          ],
        ),
      );
    }

    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryColor,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    SettingsLocalStorage settingsData =
        Provider.of<SettingsLocalStorage>(context, listen: false);
    Database db = Database();
    if (username.isEmpty) {
      username = Provider.of<UserLocalStorage>(context, listen: false)
          .currentUser
          .username;
    }
    if (email.isEmpty) {
      email = Provider.of<UserLocalStorage>(context, listen: false)
          .currentUser
          .email;
    }
    if (bio.isEmpty) {
      bio =
          Provider.of<UserLocalStorage>(context, listen: false).currentUser.bio;
    }
    return LoadingOverlayWrapper(
      child: Scaffold(
        body: FutureBuilder(
          future: settingsData.init(context),
          builder: (context, snapshot) {
            SettingModel dailyReminders =
                Provider.of<SettingsLocalStorage>(context).dailyReminders;
            SettingModel numReminders =
                Provider.of<SettingsLocalStorage>(context).numberOfReminders;
            SettingModel firstReminderTime =
                settingsData.getSettingByName('1st Reminder Time')!;
            SettingModel secondReminderTime =
                settingsData.getSettingByName('2nd Reminder Time')!;
            SettingModel thirdReminderTime =
                settingsData.getSettingByName('3rd Reminder Time')!;
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    _buildSectionTitle('Reminders'),
                    SizedBox(height: gap),
                    StaticCard(
                      child: Provider.of<HabitManager>(context).habits.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    color: kPrimaryColor.withOpacity(0.5),
                                    size: 28,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No habits to remind you about',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Create your first habit to set up reminders',
                                    style: TextStyle(
                                      color: kGray,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: dailyReminders.settingValue
                                          ? gap
                                          : 0),
                                  child: SwitchListTile.adaptive(
                                    activeColor: kPrimaryColor,
                                    inactiveTrackColor: kDarkGray,
                                    visualDensity:
                                        VisualDensity.adaptivePlatformDensity,
                                    value: settingsData
                                        .getSettingByName(
                                            dailyReminders.settingName)!
                                        .settingValue,
                                    selected: dailyReminders.settingValue,
                                    title: Text(
                                      dailyReminders.settingName,
                                      style: kMainDescription.copyWith(
                                          color: Colors.white),
                                    ),
                                    onChanged: (newValue) async {
                                      NotificationManager notificationManager =
                                          NotificationManager();
                                      await settingsData.updateSetting(
                                          dailyReminders.settingName, newValue);
                                      await db.settingsDatabase.updateSetting(
                                          dailyReminders.settingName,
                                          newValue,
                                          context);
                                      settingsData.updateSettings();
                                      await notificationManager
                                          .cancelAllScheduledNotifications();
                                      await Provider.of<HabitManager>(context,
                                              listen: false)
                                          .scheduleSmartHabitNotifs();
                                      if (newValue) {
                                        NotificationScheduler
                                            notificationScheduler =
                                            NotificationScheduler();
                                        await notificationScheduler
                                            .scheduleDefaultTrack(
                                                context,
                                                settingsData.numberOfReminders
                                                    .settingValue);
                                      }
                                    },
                                  ),
                                ),
                                dailyReminders.settingValue
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: gap),
                                        child: ListTile(
                                          title: Text(
                                            numReminders.settingName,
                                            style: kMainDescription.copyWith(
                                                color: Colors.white),
                                          ),
                                          trailing: DropdownButton(
                                              onChanged: (value) async {
                                                NotificationManager
                                                    notificationManager =
                                                    NotificationManager();
                                                NotificationScheduler
                                                    notificationScheduler =
                                                    NotificationScheduler();
                                                await settingsData
                                                    .updateSetting(
                                                        numReminders
                                                            .settingName,
                                                        value);
                                                await db.settingsDatabase
                                                    .updateSetting(
                                                        numReminders
                                                            .settingName,
                                                        value,
                                                        context);
                                                settingsData.updateSettings();
                                                await notificationManager
                                                    .cancelAllScheduledNotifications();
                                                await notificationScheduler
                                                    .scheduleDefaultTrack(
                                                        context,
                                                        settingsData
                                                            .numberOfReminders
                                                            .settingValue);
                                              },
                                              value: numReminders.settingValue,
                                              items: [
                                                DropdownMenuItem(
                                                  value: 1,
                                                  child: Text('1',
                                                      style: kMainDescription
                                                          .copyWith(
                                                              color: Colors
                                                                  .white)),
                                                ),
                                                DropdownMenuItem(
                                                  value: 2,
                                                  child: Text('2',
                                                      style: kMainDescription
                                                          .copyWith(
                                                              color: Colors
                                                                  .white)),
                                                ),
                                                DropdownMenuItem(
                                                  value: 3,
                                                  child: Text('3',
                                                      style: kMainDescription
                                                          .copyWith(
                                                              color: Colors
                                                                  .white)),
                                                ),
                                              ]),
                                        ),
                                      )
                                    : Container(),
                                dailyReminders.settingValue
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: gap),
                                        child: TimeSettingsListTile(
                                            timeSetting: firstReminderTime),
                                      )
                                    : Container(),
                                dailyReminders.settingValue &&
                                        numReminders.settingValue > 1
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: gap),
                                        child: TimeSettingsListTile(
                                            timeSetting: secondReminderTime),
                                      )
                                    : Container(),
                                dailyReminders.settingValue &&
                                        numReminders.settingValue > 2
                                    ? Container(
                                        margin: EdgeInsets.only(bottom: gap),
                                        child: TimeSettingsListTile(
                                            timeSetting: thirdReminderTime),
                                      )
                                    : Container(),
                              ],
                            ),
                    ),
                    SizedBox(height: 40),
                    _buildSectionTitle('Profile'),
                    SizedBox(height: gap),
                    StaticCard(
                      child: Column(
                        children: [
                          !Provider.of<NetworkStateProvider>(context,
                                      listen: false)
                                  .isConnected
                              ? SizedBox(height: 10)
                              : Container(),
                          const NetworkIndicator(),
                          !Provider.of<NetworkStateProvider>(context,
                                      listen: false)
                                  .isConnected
                              ? SizedBox(height: 25)
                              : Container(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SettingRow(
                                title: 'Username',
                                controller: usernameController,
                                enabled:
                                    Provider.of<NetworkStateProvider>(context)
                                        .isConnected,
                                hintText: 'Username',
                                onChanged: (value) {
                                  setState(() {
                                    username = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16.0),
                              SettingRow(
                                title: 'Email',
                                controller: emailController,
                                enabled:
                                    Provider.of<NetworkStateProvider>(context)
                                        .isConnected,
                                hintText: 'Email',
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16.0),
                              SettingRow(
                                title: 'Bio',
                                controller: bioController,
                                multiline: true,
                                enabled:
                                    Provider.of<NetworkStateProvider>(context)
                                        .isConnected,
                                hintText: 'Enter bio here...',
                                onChanged: (value) {
                                  setState(() {
                                    bio = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800),
                            height: isVerifyingEmail ? 52 : 0,
                            curve: Curves.easeInOutSine,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 800),
                                opacity: isVerifyingEmail ? 1 : 0,
                                curve: Curves.easeInOutSine,
                                child: Text(
                                  'A verification email has been sent to $email',
                                  style: kMainDescription.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800),
                            height:
                                hasUpdatedProfile && !isVerifyingEmail ? 40 : 0,
                            curve: Curves.ease,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 800),
                                opacity: hasUpdatedProfile && !isVerifyingEmail
                                    ? 1
                                    : 0,
                                curve: Curves.ease,
                                child: Icon(Icons.check_circle_rounded,
                                    color: kLightGreenAccent, size: 35),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 800),
                            height: hasFailed &&
                                    !Provider.of<NetworkStateProvider>(context)
                                        .isConnected
                                ? 70
                                : hasFailed
                                    ? 40
                                    : 0,
                            curve: Curves.ease,
                            child: Center(
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 800),
                                opacity: hasFailed ? 1 : 0,
                                curve: Curves.ease,
                                child: Text(
                                  'Failed to upload new profile online.' +
                                      (!Provider.of<NetworkStateProvider>(
                                                  context)
                                              .isConnected
                                          ? ' Looks like you\'re offline.'
                                          : ''),
                                  style: kMainDescription.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          auth.currentUser == null ||
                                  Provider.of<NetworkStateProvider>(context,
                                          listen: true)
                                      .isConnected
                              ? PrimaryButton(
                                  text: 'Update Profile',
                                  onPressed: () async {
                                    debugPrint('Current Username: $username');
                                    debugPrint('Current Email: $email');
                                    debugPrint('Current Bio: $bio');
                                    Provider.of<LoadingStateProvider>(context,
                                            listen: false)
                                        .setLoading(true);
                                    if (bio !=
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .currentUser
                                            .bio) {
                                      try {
                                        // Update the bio property in local storage
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .updateUserProperty('bio', bio);

                                        if (auth.currentUser != null) {
                                          // Upload the updated user data to the database
                                          await db.userDatabase
                                              .uploadUserData(context);

                                          // Update the network state to reflect a successful connection
                                          Provider.of<NetworkStateProvider>(
                                                  context,
                                                  listen: false)
                                              .isConnected = true;
                                        }

                                        setState(() {
                                          hasUpdatedProfile = true;
                                        });
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            hasUpdatedProfile = false;
                                          });
                                        });
                                        // Set a delay to simulate verification status UI (like for email verification)
                                      } catch (e) {
                                        // Handle errors and set the network state accordingly
                                        Provider.of<NetworkStateProvider>(
                                                context,
                                                listen: false)
                                            .isConnected = false;

                                        setState(() {
                                          hasFailed = true;
                                        });

                                        // Reset the failure status after a delay
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            hasFailed = false;
                                          });
                                        });
                                      }
                                    }
                                    if (email !=
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .currentUser
                                            .email) {
                                      try {
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .updateUserProperty('email', email);
                                        await auth.currentUser!
                                            .verifyBeforeUpdateEmail(email);
                                        await db.userDatabase
                                            .uploadUserData(context);
                                        Provider.of<NetworkStateProvider>(
                                                context,
                                                listen: false)
                                            .isConnected = true;
                                        setState(() {
                                          isVerifyingEmail = true;
                                        });
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            isVerifyingEmail = false;
                                          });
                                        });
                                      } catch (e) {
                                        Provider.of<NetworkStateProvider>(
                                                context,
                                                listen: false)
                                            .isConnected = false;
                                        setState(() {
                                          hasFailed = true;
                                        });
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            hasFailed = false;
                                          });
                                        });
                                      }
                                    }
                                    if (username !=
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .currentUser
                                            .username) {
                                      try {
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .updateUserProperty(
                                                'username', username);
                                        if (auth.currentUser != null) {
                                          await auth.currentUser!
                                              .updateDisplayName(username);
                                          await db.userDatabase
                                              .uploadUserData(context);
                                          Provider.of<NetworkStateProvider>(
                                                  context,
                                                  listen: false)
                                              .isConnected = true;
                                        }
                                        setState(() {
                                          hasUpdatedProfile = true;
                                        });
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            hasUpdatedProfile = false;
                                          });
                                        });
                                      } catch (e) {
                                        Provider.of<NetworkStateProvider>(
                                                context,
                                                listen: false)
                                            .isConnected = false;
                                        setState(() {
                                          hasFailed = true;
                                        });
                                        Future.delayed(Duration(seconds: 5),
                                            () {
                                          setState(() {
                                            hasFailed = false;
                                          });
                                        });
                                      }
                                    }
                                    await Provider.of<UserLocalStorage>(context,
                                            listen: false)
                                        .saveData(context);
                                    Provider.of<LoadingStateProvider>(context,
                                            listen: false)
                                        .setLoading(false);
                                  },
                                )
                              : InactiveElevatedButton(
                                  child: Text('Update Profile')),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StaticCard(
                                padding: 12,
                                child: db.userDatabase.isLoggedIn
                                    ? AsideButton(
                                        text: 'Log out',
                                        onPressed: () async {
                                          Provider.of<LoadingStateProvider>(
                                                  context,
                                                  listen: false)
                                              .setLoading(true);

                                          late final _auth =
                                              FirebaseAuth.instance;
                                          await _auth.signOut();
                                          Provider.of<UserLocalStorage>(context,
                                                  listen: false)
                                              .updateUserProperty(
                                                  'email', 'N/A');
                                          Provider.of<LoadingStateProvider>(
                                                  context,
                                                  listen: false)
                                              .setLoading(false);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WelcomeScreen()),
                                              (route) => false);
                                          Navigator.popAndPushNamed(
                                              context, 'welcome_screen');
                                        })
                                    : AsideButton(
                                        text: 'Log in',
                                        onPressed: () async {
                                          Navigator.pushNamed(
                                              context, 'login_screen');
                                        }),
                              ),
                              StaticCard(
                                padding: 12,
                                opacity: 0.2,
                                color: kOrangeAccent,
                                child: AsideButton(
                                    text: 'Clear Data',
                                    onPressed: () async {
                                      dynamic result = await showDialog(
                                        context: context,
                                        builder: (context) => CustomAlertDialog(
                                          title: 'Warning',
                                          content: Text(
                                              'Are you sure you want to clear all account data (habits, stats, etc.)? This cannot be undone.'),
                                          actions: [
                                            AsideButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                text: 'Yes'),
                                            SizedBox(width: 10),
                                            AsideButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                text: 'No'),
                                          ],
                                        ),
                                      );
                                      result == null ? result = false : null;
                                      if (result) {
                                        Provider.of<LoadingStateProvider>(
                                                context,
                                                listen: false)
                                            .setLoading(true);
                                        await Provider.of<HabitsLocalStorage>(
                                                context,
                                                listen: false)
                                            .deleteData(context);
                                        Provider.of<UserLocalStorage>(context,
                                                listen: false)
                                            .clearStats();
                                        Provider.of<HabitManager>(context,
                                                listen: false)
                                            .deleteAllHabits(context);
                                        await Provider.of<SettingsLocalStorage>(
                                                context,
                                                listen: false)
                                            .populateDefaultSettingsData();
                                        Provider.of<SettingsLocalStorage>(
                                                context,
                                                listen: false)
                                            .updateSettings();
                                        await db.settingsDatabase
                                            .populateDefaultSettingsData(
                                                context);
                                        if (db.userDatabase.isLoggedIn) {
                                          await db.habitDatabase
                                              .clearHabits(context);
                                          // await db.statsDatabase
                                          //     .clearStatistics(context);
                                          await db.communityChallengeDatabase
                                              .clearUserParticipantData(
                                                  Provider.of<UserLocalStorage>(
                                                          context,
                                                          listen: false)
                                                      .currentUser
                                                      .uid);
                                        }
                                        Provider.of<LoadingStateProvider>(
                                                context,
                                                listen: false)
                                            .setLoading(false);
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SplashScreen()),
                                            (route) => false);
                                      }
                                    }),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StaticCard(
                                padding: 12,
                                opacity: 0.2,
                                color: kLightRedAccent,
                                child: AsideButton(
                                    text: 'Delete Account',
                                    onPressed: () async {
                                      dynamic result = await showDialog(
                                        context: context,
                                        builder: (context) => CustomAlertDialog(
                                          title: 'Warning',
                                          content: Text(
                                              'Are you sure you want to delete your account? This cannot be undone.'),
                                          actions: [
                                            AsideButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                text: 'Yes'),
                                            SizedBox(width: 10),
                                            AsideButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                text: 'No'),
                                          ],
                                        ),
                                      );
                                      result == null ? result = false : null;
                                      if (result) {
                                        try {
                                          Provider.of<LoadingStateProvider>(
                                                  context,
                                                  listen: false)
                                              .setLoading(true);
                                          late final _auth =
                                              FirebaseAuth.instance;
                                          await db.communityChallengeDatabase
                                              .clearUserParticipantData(
                                                  _auth.currentUser!.uid);
                                          await db.userDatabase
                                              .deleteUser(context);
                                          await _auth.currentUser!.delete();
                                          Provider.of<LoadingStateProvider>(
                                                  context,
                                                  listen: false)
                                              .setLoading(false);
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WelcomeScreen()),
                                              (route) => false);
                                          Navigator.popAndPushNamed(
                                              context, 'welcome_screen');
                                        } catch (e) {
                                          debugPrint(e.toString());
                                          Provider.of<LoadingStateProvider>(
                                                  context,
                                                  listen: false)
                                              .setLoading(false);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeleteAcccountLoginScreen()));
                                        }
                                      }
                                    }),
                              ),
                            ],
                          ),
                          Provider.of<UserLocalStorage>(context, listen: false)
                                  .currentUser
                                  .isAdmin
                              ? AsideButton(
                                  text: 'Admin Panel',
                                  onPressed: () {
                                    Navigator.popAndPushNamed(
                                        context, 'admin_screen');
                                  })
                              : Container(),
                        ],
                      ),
                    ),
                    SizedBox(height: gap * 2),
                    _buildSectionTitle('Privacy Settings'),
                    SizedBox(height: gap),
                    _buildPrivacySection(),
                    SizedBox(height: gap * 2),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: NavBar(
          currentPage: 'settings',
        ),
      ),
    );
  }
}

class TimeSettingsListTile extends StatelessWidget {
  SettingModel timeSetting;
  TimeSettingsListTile({super.key, required this.timeSetting});

  @override
  Widget build(BuildContext context) {
    SettingsLocalStorage settingsData =
        Provider.of<SettingsLocalStorage>(context);
    Database db = Database();
    return ListTile(
      title: Text(
        timeSetting.settingName,
        style: kMainDescription.copyWith(color: Colors.white),
      ),
      trailing: GestureDetector(
        onTap: () async {
          NotificationManager notificationManager = NotificationManager();
          NotificationScheduler notificationScheduler = NotificationScheduler();
          TimeOfDay? newTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: timeSetting.settingValue.hour,
                  minute: timeSetting.settingValue.minute));
          TimeModel newTimeFormatted = newTime == null
              ? timeSetting.settingValue
              : TimeModel(hour: newTime.hour, minute: newTime.minute);
          Provider.of<LoadingStateProvider>(context, listen: false)
              .setLoading(true);
          await settingsData.updateSetting(
              timeSetting.settingName, newTimeFormatted);
          await db.settingsDatabase.updateSetting(
              timeSetting.settingName, newTimeFormatted, context);

          await notificationManager.cancelAllScheduledNotifications();
          await notificationScheduler.scheduleDefaultTrack(
              context, settingsData.numberOfReminders.settingValue);
          Provider.of<LoadingStateProvider>(context, listen: false)
              .setLoading(false);
          settingsData.updateSettings();
        },
        child: StaticCard(
          child: Text(
              '${timeSetting.settingValue.hour}:${timeSetting.settingValue.minute > 9 ? timeSetting.settingValue.minute.toString() : '0' + timeSetting.settingValue.minute.toString()}',
              // basically just nicely displays the time
              style:
                  kMainDescription.copyWith(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final bool multiline;
  final void Function(String) onChanged;

  const SettingRow({
    super.key,
    required this.title,
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.onChanged,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: kMainDescription.copyWith(color: Colors.white)),
        SizedBox(
          width: 200,
          child: multiline
              ? MultilineTextField(
                  enabled: enabled,
                  hintText: hintText,
                  controller: controller,
                  onChanged: onChanged,
                )
              : FilledTextField(
                  enabled: enabled,
                  hintText: hintText,
                  controller: controller,
                  onChanged: onChanged,
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/loading_overlay/loading_overlay.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/primary_button.dart';
import 'package:habitur/ui/widgets/text_fields/form_text_field.dart';
import 'package:habitur/ui/widgets/text_fields/primary_text_field.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, SettingsViewModel viewModel, Widget? child) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: LoadingOverlay(
            isLoading: viewModel.isBusy,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Profile Section
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_rounded,
                                color: kPrimaryColor, size: 28),
                            const SizedBox(width: 12),
                            Text('Profile',
                                style:
                                    kHeadingTextStyle.copyWith(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        FormTextField.username(
                          controller: viewModel.usernameController,
                        ),
                        const SizedBox(height: 16),
                        FormTextField.email(
                          controller: viewModel.emailController,
                        ),
                        const SizedBox(height: 16),
                        FormTextField(
                          controller: viewModel.bioController,
                          maxLines: 3,
                          label: 'Bio',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            PrimaryButton(
                                text: 'Update Profile',
                                onPressed: viewModel.updateProfile),
                            if (!viewModel.isEmailVerified)
                              const SizedBox(width: 24),
                            if (!viewModel.isEmailVerified)
                              AsideButton(
                                  text: 'Verify Email',
                                  onPressed: viewModel.verifyEmail),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Privacy Settings
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.privacy_tip_rounded,
                                color: kPrimaryColor, size: 28),
                            const SizedBox(width: 12),
                            Text('Privacy',
                                style:
                                    kHeadingTextStyle.copyWith(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Stats & Habits Visibility
                        _buildSectionHeader(
                            'Sharing Scope', Icons.group_rounded),
                        const SizedBox(height: 15),
                        _buildDropdownTile(
                          title: 'Stats Visibility',
                          subtitle: 'Who can see your habit statistics',
                          value: viewModel.statsScope,
                          onChanged: (SharingScope? value) =>
                              viewModel.updateSetting('statsScope', value),
                        ),
                        const Divider(),
                        _buildDropdownTile(
                          title: 'Habits Visibility',
                          subtitle: 'Who can see your habits',
                          value: viewModel.habitsScope,
                          onChanged: (SharingScope? value) =>
                              viewModel.updateSetting('habitsScope', value),
                        ),

                        const SizedBox(height: 30),

                        // Activity Sharing
                        _buildSectionHeader(
                            'Activity Sharing', Icons.local_activity_rounded),
                        const SizedBox(height: 15),
                        _buildSwitchTile(
                          title: 'Share Activities',
                          subtitle:
                              'Allow friends to see your habit activities',
                          value: viewModel.shareActivities,
                          onChanged: (bool value) async {
                            await viewModel.updateSetting(
                                'shareActivities', value);
                          },
                        ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'Share Habit Completions',
                          subtitle: 'Show when you complete habits',
                          value: viewModel.shareHabitCompletions,
                          onChanged: (bool value) async {
                            await viewModel.updateSetting(
                                'shareHabitCompletions', value);
                          },
                        ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'Share Streak Milestones',
                          subtitle: 'Show when you reach streak milestones',
                          value: viewModel.shareStreakMilestones,
                          onChanged: (bool value) async {
                            await viewModel.updateSetting(
                                'shareStreakMilestones', value);
                          },
                        ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'Share New Habits',
                          subtitle: 'Show when you create new habits',
                          value: viewModel.shareNewHabits,
                          onChanged: (bool value) async {
                            await viewModel.updateSetting(
                                'shareNewHabits', value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // App Settings
                  Card(
                    color: kFadedBlue.withOpacity(0.15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.1), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings_rounded,
                                  color: kPrimaryColor, size: 28),
                              const SizedBox(width: 12),
                              Text('App Settings',
                                  style:
                                      kHeadingTextStyle.copyWith(fontSize: 24)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          _buildSwitchTile(
                            title: 'Notifications',
                            subtitle: 'Enable push notifications',
                            value: viewModel.notificationsEnabled,
                            onChanged: (bool value) =>
                                viewModel.updateSetting('notifications', value),
                          ),
                          const Divider(),
                          _buildSwitchTile(
                            title: 'Community Features',
                            subtitle: 'Enable social features',
                            value: viewModel.communityFeaturesEnabled,
                            onChanged: (bool value) => viewModel.updateSetting(
                                'communityFeatures', value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Account Actions
                  Card(
                    color: kFadedBlue.withOpacity(0.15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.1), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_circle_rounded,
                                  color: kPrimaryColor, size: 28),
                              const SizedBox(width: 12),
                              Text('Account',
                                  style:
                                      kHeadingTextStyle.copyWith(fontSize: 24)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          ListTile(
                            leading:
                                const Icon(Icons.details, color: Colors.orange),
                            title: const Text('Clear Data',
                                style: TextStyle(color: Colors.orange)),
                            onTap: viewModel.clearData,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            onTap: viewModel.logout,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            title: const Text('Delete Account',
                                style: TextStyle(color: Colors.red)),
                            onTap: viewModel.deleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (viewModel.isAdmin) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: kFadedBlue.withOpacity(0.15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: kPrimaryColor.withOpacity(0.1), width: 1),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Admin Panel'),
                        onTap: viewModel.navigateToAdminPanel,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavBar(currentPage: 'settings'),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(width: 8),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
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

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();

  @override
  void onViewModelReady(SettingsViewModel viewModel) => viewModel.initialize();
}

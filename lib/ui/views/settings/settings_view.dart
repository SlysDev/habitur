import 'package:flutter/material.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, SettingsViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Section
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
                          Icon(Icons.person_rounded,
                              color: kPrimaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text('Profile',
                              style: kHeadingTextStyle.copyWith(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: viewModel.usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: viewModel.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: viewModel.bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!viewModel.isEmailVerified)
                        ElevatedButton(
                          onPressed: viewModel.verifyEmail,
                          child: const Text('Verify Email'),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Privacy Settings
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
                          Icon(Icons.privacy_tip_rounded,
                              color: kPrimaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text('Privacy',
                              style: kHeadingTextStyle.copyWith(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Stats & Habits Visibility
                      _buildSectionHeader('Sharing Scope', Icons.group_rounded),
                      const SizedBox(height: 15),
                      _buildDropdownTile(
                        title: 'Stats Visibility',
                        subtitle: 'Who can see your habit statistics',
                        value: viewModel.statsScope,
                        onChanged: viewModel.updateStatsScope,
                      ),
                      const Divider(),
                      _buildDropdownTile(
                        title: 'Habits Visibility',
                        subtitle: 'Who can see your habits',
                        value: viewModel.habitsScope,
                        onChanged: viewModel.updateHabitsScope,
                      ),

                      const SizedBox(height: 30),

                      // Activity Sharing
                      _buildSectionHeader(
                          'Activity Sharing', Icons.local_activity_rounded),
                      const SizedBox(height: 15),
                      _buildSwitchTile(
                        title: 'Share Activities',
                        subtitle: 'Allow friends to see your habit activities',
                        value: viewModel.shareActivities,
                        onChanged: viewModel.updateShareActivities,
                      ),
                      const Divider(),
                      _buildSwitchTile(
                        title: 'Share Habit Completions',
                        subtitle: 'Show when you complete habits',
                        value: viewModel.shareHabitCompletions,
                        onChanged: viewModel.updateShareHabitCompletions,
                      ),
                      const Divider(),
                      _buildSwitchTile(
                        title: 'Share Streak Milestones',
                        subtitle: 'Show when you reach streak milestones',
                        value: viewModel.shareStreakMilestones,
                        onChanged: viewModel.updateShareStreakMilestones,
                      ),
                      const Divider(),
                      _buildSwitchTile(
                        title: 'Share New Habits',
                        subtitle: 'Show when you create new habits',
                        value: viewModel.shareNewHabits,
                        onChanged: viewModel.updateShareNewHabits,
                      ),
                    ],
                  ),
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
                              style: kHeadingTextStyle.copyWith(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildSwitchTile(
                        title: 'Dark Mode',
                        subtitle: 'Enable dark theme',
                        value: viewModel.isDarkMode,
                        onChanged: viewModel.updateDarkMode,
                      ),
                      const Divider(),
                      _buildSwitchTile(
                        title: 'Notifications',
                        subtitle: 'Enable push notifications',
                        value: viewModel.notificationsEnabled,
                        onChanged: viewModel.updateNotifications,
                      ),
                      const Divider(),
                      _buildSwitchTile(
                        title: 'Community Features',
                        subtitle: 'Enable social features',
                        value: viewModel.communityFeaturesEnabled,
                        onChanged: viewModel.updateCommunityFeatures,
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
                              style: kHeadingTextStyle.copyWith(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: viewModel.logout,
                      ),
                      const Divider(),
                      ListTile(
                        leading:
                            const Icon(Icons.delete_forever, color: Colors.red),
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
      bottomNavigationBar: NavBar(currentPage: 'settings'),
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
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: const [
          DropdownMenuItem(value: 'private', child: Text('Private')),
          DropdownMenuItem(value: 'friends', child: Text('Friends')),
          DropdownMenuItem(value: 'public', child: Text('Public')),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();

  @override
  void onViewModelReady(SettingsViewModel viewModel) => viewModel.initialize();
}

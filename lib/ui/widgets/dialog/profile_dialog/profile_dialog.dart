import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:habitur/ui/widgets/visible_habit_list/visible_habit_list.dart';
import 'package:stacked/stacked.dart';

import 'profile_dialog_model.dart';

class ProfileDialog extends StackedView<ProfileDialogModel> {
  const ProfileDialog(
      {super.key,
      required this.uid,
      this.isFriendProfile = false,
      required this.completer});

  final String uid;
  final bool isFriendProfile;
  final dynamic completer;

  @override
  Widget builder(
    BuildContext context,
    ProfileDialogModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: viewModel.closeDialog,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Dialog(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: GestureDetector(
              onTap: () {},
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }

    if (viewModel.userModel == null) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: viewModel.closeDialog,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Dialog(
            backgroundColor: kBackgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User not found',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This user profile could not be found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final userModel = viewModel.userModel!;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: viewModel.closeDialog,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Dialog(
          backgroundColor: kBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.82,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildOverviewTab(viewModel),
                          const SizedBox(height: 30),
                          _buildStatsTab(viewModel),
                          const SizedBox(height: 30),
                          _buildHabitsTab(viewModel),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    // Add further sections like habits or stats as required
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ProfileDialogModel viewModel) {
    if (viewModel.userModel == null) return Container();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          UserAvatar(
            username: viewModel.userModel?.username ?? 'No username found',
          ),
          SizedBox(height: 16),
          Text(
            viewModel.userModel?.username ?? 'No username found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            viewModel.userModel?.bio.isEmpty ?? true
                ? 'No bio available.'
                : viewModel.userModel!.bio,
            style: kMainDescription.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              color: kGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _buildLevelProgressBar(viewModel),
              const SizedBox(width: 20),
              _buildConfidenceIndicator(viewModel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar(ProfileDialogModel viewModel) {
    if (viewModel.userModel == null) return Container();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          child: RoundedProgressBar(
            progress: viewModel.userModel!.userXP /
                viewModel.userModel!.levelUpRequirement,
            color: kPrimaryColor,
            lineHeight: 50.0,
          ),
        ),
        Text(
          viewModel.userModel!.userLevel.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(ProfileDialogModel viewModel) {
    if (viewModel.userModel == null) return Container();

    return StatChip(
      icon: Icons.sentiment_satisfied_rounded,
      label: viewModel.getConfidenceLevel().toStringAsFixed(2),
      color: kLightGreenAccent,
      size: 1.8,
    );
  }

  Widget _buildHabitsTab(ProfileDialogModel viewModel) {
    if (viewModel.userModel == null) return Container();

    return VisibleHabitList(
      userId: uid,
      isFriendProfile: isFriendProfile,
      habitsScope: viewModel.userModel?.privacySettings?.habitsScope,
      habits: viewModel.isCurrentUser ? viewModel.getCurrentUserHabits() : null,
    );
  }

  Widget _buildStatsTab(ProfileDialogModel viewModel) {
    bool userHasChosenToShareStats =
        viewModel.userModel?.privacySettings?.statsScope ==
                SharingScope.everyone ||
            (viewModel.userModel?.privacySettings?.statsScope ==
                    SharingScope.friends &&
                isFriendProfile);
    debugPrint('User model: ${viewModel.userModel?.toString()}');
    debugPrint(
        'Profile dialog: User has ${userHasChosenToShareStats ? '' : 'not '}chosen to share their stats');
    if (viewModel.userModel?.stats?.isEmpty ?? true) {
      return const Center(
        child: Text(
          'No stats to display',
          style: TextStyle(color: kGray),
        ),
      );
    }

    debugPrint(
        'Building stats tab with ${viewModel.userModel?.stats.length} stat points');

    try {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            LineGraph(
              data: viewModel.userModel?.stats ?? [],
              title: 'Confidence Level',
              statName: 'confidenceLevel',
              color: kLightGreenAccent,
            ),
            const SizedBox(height: 20),
            LineGraph(
              data: viewModel.userModel?.stats ?? [],
              title: 'Consistency',
              statName: 'consistencyFactor',
              color: kPrimaryColor,
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      debugPrint('Error building stats tab: $e');
      debugPrint('User model: ${viewModel.userModel?.toString()}');
      return Center(
        child: Text(
          'Error loading stats',
          style: TextStyle(color: kGray),
        ),
      );
    }
  }

  Widget _buildHabitsContent(ProfileDialogModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildHabitsTab(viewModel),
    );
  }

  Widget _buildStatsContent(ProfileDialogModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: _buildStatsTab(viewModel),
    );
  }

  @override
  void onViewModelReady(ProfileDialogModel viewModel) {
    viewModel.loadUserData();
  }

  @override
  ProfileDialogModel viewModelBuilder(
    BuildContext context,
  ) {
    final viewModel = ProfileDialogModel();
    viewModel.initialize(uid, isFriendProfile, completer);
    return viewModel;
  }
}

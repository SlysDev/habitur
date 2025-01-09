import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/models/privacy_settings.dart';
import 'package:habitur/ui/widgets/line_graph/line_graph.dart';
import 'package:habitur/ui/widgets/rounded_progress_bar.dart';
import 'package:habitur/ui/widgets/stat-chips/stat_chip.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:habitur/ui/widgets/visible_habit_list/visible_habit_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'profile_dialog_model.dart';

class ProfileDialog extends StackedView<ProfileDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ProfileDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

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
                        color: kGray,
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
            size: 2,
          ),
          SizedBox(height: 16),
          Text(
            viewModel.userModel?.username ?? 'No username found',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
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
              viewModel.userModel?.bio.isEmpty ?? true
                  ? 'No bio available.'
                  : viewModel.userModel?.bio ?? '...',
              style: const TextStyle(
                color: kGray,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
          width: 100,
          child: RoundedProgressBar(
            progress: viewModel.userModel!.userXP /
                viewModel.userModel!.levelUpRequirement,
            color: kPrimaryColor,
            lineHeight: 45.0,
            width: 100,
          ),
        ),
        Text(
          viewModel.userModel!.userLevel.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
      size: 1.55,
    );
  }

  Widget _buildHabitsTab(ProfileDialogModel viewModel) {
    if (viewModel.userModel == null) return Container();

    return VisibleHabitList(
      userId: request.data?['uid'],
      isFriendProfile: request.data?['isFriendProfile'],
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
                request.data?['isFriendProfile']);
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

  @override
  void onViewModelReady(ProfileDialogModel viewModel) {
    viewModel.loadUserData();
  }

  @override
  ProfileDialogModel viewModelBuilder(BuildContext context) {
    final viewModel = ProfileDialogModel();
    viewModel.initialize(
        request.data?['uid'] ?? '', request.data?['isFriendProfile'] ?? false);
    return viewModel;
  }
}

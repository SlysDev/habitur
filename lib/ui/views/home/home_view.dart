import 'package:flutter/material.dart';
import 'package:habitur/ui/views/social_feed/social_feed.dart';
import 'package:habitur/ui/widgets/aside_button.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
import 'package:habitur/ui/widgets/modern_card.dart';
import 'package:habitur/ui/widgets/navbar/navbar.dart';
import 'package:habitur/ui/widgets/profile_drawer/profile_drawer.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/constants.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: viewModel.refreshData,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeGreetingHeader(),
                        const SizedBox(height: 24),
                        viewModel.communityFeaturesEnabled
                            ? SocialFeed(
                                onRefresh: () async {
                                  await viewModel.refreshData();
                                },
                              )
                            : _buildCommunityDisabledPanel(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      endDrawer: const ProfileDrawer(),
      bottomNavigationBar: const NavBar(
        currentPage: 'home',
      ),
    );
  }

  Widget _buildCommunityDisabledPanel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: kPrimaryColor),
              SizedBox(height: 16),
              Text(
                'Community Features Disabled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You have turned off community features. Enable them in settings to see community challenges and social feeds.',
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
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

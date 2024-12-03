import 'package:flutter/material.dart';
import 'package:habitur/ui/views/social_feed/social_feed.dart';
import 'package:habitur/ui/widgets/habit_card_list/habit_card_list.dart';
import 'package:habitur/ui/widgets/home_greeting_header/home_greeting_header.dart';
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
    // return HomeScreenDesign();
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
                        SocialFeed(
                          onRefresh: () async {
                            await viewModel.refreshData();
                          },
                        ),
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

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}

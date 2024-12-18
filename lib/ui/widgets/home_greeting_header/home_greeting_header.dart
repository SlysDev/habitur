import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/days_of_week_widget/days_of_week_widget.dart';
import 'package:habitur/ui/widgets/network_indicator/network_indicator.dart';
import 'package:habitur/ui/widgets/user_avatar/user_avatar.dart';
import 'package:stacked/stacked.dart';

import 'home_greeting_header_model.dart';

class HomeGreetingHeader extends StackedView<HomeGreetingHeaderModel> {
  const HomeGreetingHeader({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeGreetingHeaderModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            children: [
              // Avatar
              UserAvatar(
                username: viewModel.isBusy ? '...' : viewModel.username,
              ),
              const SizedBox(width: 15),

              // Greeting and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    RichText(
                      text: TextSpan(
                        style: kTitleTextStyle.copyWith(
                          fontSize: 24,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Good ${viewModel.timeOfDay},\n',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          TextSpan(
                            text: viewModel.isBusy ? '...' : viewModel.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      viewModel.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const NetworkIndicator(),
            ],
          ),
          const SizedBox(height: 25),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kFadedBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Level
                Column(
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.level.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Divider
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                // Streak
                Column(
                  children: [
                    Text(
                      'STREAK',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          viewModel.streak.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: kOrangeAccent,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                // Divider
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                // XP Progress
                Column(
                  children: [
                    Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: viewModel.xpProgress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Percentage Text
                          Text(
                            '${(viewModel.xpProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Days of Week
          DaysOfWeekWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  HomeGreetingHeaderModel viewModelBuilder(BuildContext context) {
    final viewModel = HomeGreetingHeaderModel();
    viewModel.initialize();
    return viewModel;
  }
}

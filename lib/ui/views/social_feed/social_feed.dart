import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/ui/widgets/activity_item/activity_item.dart';
import 'package:habitur/ui/widgets/community_habit_list/community-habit-list.dart';
import 'package:stacked/stacked.dart';
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/ui/views/social_feed/social_feed_viewmodel.dart';

class SocialFeed extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const SocialFeed({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SocialFeedViewModel>.reactive(
      viewModelBuilder: () => SocialFeedViewModel(),
      onViewModelReady: (model) => model.refresh(),
      builder: (context, model, child) => RefreshIndicator(
        color: kPrimaryColor,
        backgroundColor: Colors.transparent,
        strokeWidth: 4.0,
        onRefresh: () async {
          await model.refresh();
          await onRefresh();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Habits Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Community Habits',
                style: kSubHeadingTextStyle,
              ),
            ),
            CommunityHabitList(onRefresh: onRefresh),

            // Activity Feed Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Friend Activity',
                style: kSubHeadingTextStyle,
              ),
            ),

            // Activity Stream
            StreamBuilder<List<ActivityEvent>>(
              stream: model.activitiesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: kMainDescription,
                          ),
                          TextButton(
                            onPressed: onRefresh,
                            child: Text(
                              'Try Again',
                              style: kMainDescription.copyWith(
                                  color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Theme.of(context).disabledColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Complete habits or add friends to see activity',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final activities = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: activities.length + (model.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= activities.length) {
                      if (model.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return null;
                    }
                    return ActivityItem(activity: activities[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

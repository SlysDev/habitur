import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/util_functions.dart';
import 'package:stacked/stacked.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:habitur/models/activity_event.dart';
import 'package:habitur/ui/widgets/activity_item/activity_item_viewmodel.dart';

import '../app/app.locator.dart';
import '../enums/activity_type.dart';
import '../enums/reaction_type.dart';
import '../services/auth_service.dart';

class ActivityItem extends StatelessWidget {
  final ActivityEvent activity;
  final _authService = locator<AuthService>();

  ActivityItem({required this.activity});

  final Map<ReactionType, String> reactionIcons = {
    ReactionType.like: '❤️',
    ReactionType.celebrate: '🎉',
    ReactionType.support: '💪',
    ReactionType.inspire: '💡',
  };

  String _getActivityMessage() {
    switch (activity.type) {
      case ActivityType.habitProgress:
        return 'completed "${activity.habitTitle}"';
      case ActivityType.streakMilestone:
        final days = activity.metadata['streakDays'] as int;
        return 'reached a ${days}-day streak on "${activity.habitTitle}"! 🎉';
      case ActivityType.newHabit:
        final frequency = activity.metadata['frequency'] as String;
        final goal = activity.metadata['targetGoal'] as int;
        return 'started a new habit: "${activity.habitTitle}" (${goal}x ${frequency})';
      default:
        return 'did something';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ActivityItemViewModel>.reactive(
      viewModelBuilder: () => ActivityItemViewModel(),
      builder: (context, model, child) => Container(
        decoration: BoxDecoration(
          color: kFadedBlue.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kFadedBlue.withOpacity(0.6),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: activity.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: kPrimaryColor,
                      ),
                    ),
                    TextSpan(text: ' '),
                    TextSpan(
                      text: _getActivityMessage(),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      timeago.format(activity.timestamp),
                      style: TextStyle(
                        fontSize: 13,
                        color: kDarkGray.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              activity.hasLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: activity.hasLiked ? Colors.red : null,
                            ),
                            onPressed: () {
                              if (activity.hasLiked) {
                                model.unlikeActivity(activity.id);
                              } else {
                                model.likeActivity(activity.id);
                              }
                            },
                          ),
                          Text(
                            activity.likeCount.toString(),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      if (activity.userId == _authService.currentUser?.uid)
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () => model.deleteActivity(activity.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: kFadedBlue.withOpacity(0.6),
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          model.showReactionPicker(context, activity.id),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_reaction_outlined,
                                size: 20, color: kPrimaryColor),
                            SizedBox(width: 6),
                            Text(
                              'React',
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
